---
layout: post
title: Deploying Sinatra Ruby Applications on OpenBSD in 2025
topic: Sinatra microservices on OpenBSD 7.6
category: programming
description: We're reprovisioning some of our application servers, which all run OpenBSD. As part of the modernization effort, we're using as much functionality baked into OpenBSD as possible. Ruby web applications in general, and Sinatra in particular, work well with this setup. 
image: rubyonopenbsd.png
---

We've finally upgraded to a full rack at [iNOC](https://inoc.net/) and as part of the upgrade, we're reprovisioning our application servers, rather than migrating their VMs to newer hardware. Part of that process includes moving the [counters microservice](https://github.com/glitchwrks/counters) to one of the new application servers -- it's a small Sinatra microservice that provides simple hit counters for glitchwrks.com. It's been deployed on OpenBSD for a long time, but was deployed in a somewhat "un-OpenBSD-like" way:

* Ruby version and gemset managed with [RVM](https://rvm.io)
* Reverse proxying and TLS wrapping handled by `nginx`
* Microservice start/stop managed by Capistrano

Additionally, the OpenBSD application server on which it was deployed predated our adoption of [Ansible](https://www.redhat.com/en/ansible-collaborative). The host was managed with a bunch of homegrown scripts and configuration files.

The counters microservice had also been running on Unicorn, which was the popular way to serve Rack applications when it was created. We wanted to switch it over to Puma as part of the upgrade.

### New Application Server

The new application server runs OpenBSD 7.6, and we wanted to use it as an experiment for the following:

* Going back to Ruby version management through the OS package manager
* Reverse proxying and TLS wrapping using [relayd](https://man.openbsd.org/relayd.8)
* Per-application deploy users
* Per-application database users
* Better logging, with not-custom log rotation
* Microservice management with rc-scripts

The application would be otherwise unchanged, other than the Unicorn => Puma switch and various gem updates.

There are actually two application servers, just as with the old deployment configuration: production and staging. Unlike the old setup, Ansible makes it easy to keep both essentially identical in configuration.

### Ansible Provisioning of the Base Application Server

Ansible playbooks were split into two parts: an OpenBSD application server playbook, which sets up the basic OpenBSD appserver features required of most of our deployed applications, and `counters_app.yml`, which handles all of the configuration specific to the counters microservice.

The base OpenBSD application server is provisioned with the following playbook:

{% codeblock :language => 'yaml', :title => 'openbsd_application_server.yml' %}
{% raw %}
---
- name: Configure OpenBSD application servers
  hosts: staging.bee.glitchworks.net,appserv1.alb.glitchworks.net
  become: yes
  become_method: doas

  vars:
    ansible_doas_pass: "{{ ansible_user_password }}"

  roles:
    - openbsd_handlers
    - glitchworks_managed
    - static_ip
    - static_dns
    - managed_pf
    - ntp_client
    - munin_node
    - no_sound

  tasks:
    - name: Copy acme-client configuration
      copy:
        src: "{{ inventory_hostname }}/acme-client.conf"
        dest: /etc/acme-client.conf
        owner: root
        group: wheel
        mode: '0644'

    - name: Add acme-client cronjobs
      cron:
        name: "acme-client update for {{ item }}"
        minute: 0
        hour: 0
        user: root
        job: "acme-client {{ item }} && rcctl restart relayd"
      with_items: "{{ hosted_application_hostnames }}"

    - name: Configure httpd
      copy:
        src: "{{ inventory_hostname }}/httpd.conf"
        dest: /etc/httpd.conf
        owner: root
        group: wheel
        mode: '0640'

    - name: Enable and restart httpd
      service:
        name: httpd
        state: restarted
        enabled: true

    - name: Ensure acme-client TLS files have been generated for configured hostnames
      shell: "acme-client {{ item }}"
      args:
        creates: "/etc/ssl/{{ item }}.crt"
      with_items: "{{ hosted_application_hostnames }}"

    - name: Configure relayd
      copy:
        src: "{{ inventory_hostname }}/relayd.conf"
        dest: /etc/relayd.conf
        owner: root
        group: wheel
        mode: '0640'

    - name: Enable and restart relayd
      service:
        name: relayd
        state: restarted
        enabled: true
{% endraw %}
{% endcodeblock %}

Basically, this just does our standard host setup, then configures `acme-client` and `httpd` to serve LetsEncrypt challenge files, puts in the `acme-client` cronjobs, and configures `relayd`. For `relayd` to provide the full cert chain, we need to make sure that `/etc/ssl/app.example.com.crt` is the full chain -- by default, it's *just the server certificate.* Here's a config snippet:

{% codeblock :language => 'conf', :title => '/etc/acme-client.conf' %}
domain counters.glitchworks.net {
        domain key "/etc/ssl/private/counters.glitchworks.net.key"
        domain certificate "/etc/ssl/counters.glitchworks.net_certonly.crt"
        domain full chain certificate "/etc/ssl/counters.glitchworks.net.crt"
        sign with letsencrypt
}
{% endcodeblock %}

So, `/etc/ssl/counters.glitchworks.net.crt` ends up being the full cert chain, at the filename that `relayd` expects. The server-only certificate is also saved at `/etc/ssl/counters.glitchworks.net_certonly.crt` just in case we'd need it for some reason.

### relayd Configuration

We've been using [relayd](https://man.openbsd.org/relayd.8) more and more for various tasks, and wanted to try replacing `nginx` with `relayd` as the reverse proxy for this microservice. Briefly, `relayd` does its work through a mix of application level code and firewall rules through OpenBSD's excellent `pf`. `relayd` can perform reverse proxying, transparent proxying, TLS/SSL wrapping, and load balancing.

I used [this writeup](https://github.com/basicfeatures/openbsd-rails) to get going with my `relayd` configuration. Here's an abbreviated `relayd` configuration for the application server, including just the bits for the counters microservice:

{% codeblock :language => 'conf', :title => '/etc/relayd.conf' %}
# Managed by Ansible, DO NOT HAND-EDIT!
# relayd.conf for appserv1.alb.glitchworks.net

table <counters> { lo0 }
counters_port="8080"

table <httpd> { lo0 }
httpd_port="80"

http protocol "http" {
  match request header set "Connection" value "close"
  match response header remove "Server"
}

http protocol "https" {
  pass request header "Host" value "counters.glitchworks.net" forward to <counters>
  tls keypair "counters.glitchworks.net"

  # Preserve address headers
  match request header append "X-Forwarded-For" value "$REMOTE_ADDR"
  match request header append "X-Forwarded-Port" value "$REMOTE_PORT"
  match request header append "X-Forwaded-By" value "$SERVER_ADDR:$SERVER_PORT"

  match request header set "Connection" value "close"

  match response header remove "Server"

  # Best practice security headers
  # https://securityheaders.com/
  match response header append "Strict-Transport-Security" value "max-age=31536000; includeSubDomains"
  match response header append "X-Frame-Options" value SAMEORIGIN
  match response header append "X-XSS-Protection" value "1; mode=block"
  match response header append "X-Content-Type-Options" value nosniff
  match response header append "Referrer-Policy" value strict-origin
  match response header append "Feature-Policy" value "accelerometer 'none'; camera 'none'; geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; payment 'none'; usb 'none'"
}

relay "http" {
  listen on vio0 port http

  protocol "http"

  forward to <httpd> port $httpd_port
}

relay "httpsv4" {
  listen on 0.0.0.0 port https tls

  protocol "https"

  forward to <httpd> port $httpd_port
  forward to <counters> port $counters_port
}

relay "httpsv6" {
  listen on ::0 port https tls

  protocol "https"

  forward to <httpd> port $httpd_port
  forward to <counters> port $counters_port
}
{% endcodeblock %}

Notice there are two `relay` blocks for HTTPS serving: this is due to an [apparently longstanding problem](https://www.mail-archive.com/misc@openbsd.org/msg169079.html) in which multiple `listen` statements don't work with TLS keypairs! This silently fails, and if you've specified an interface instead of an IP (as with the plain HTTP relay's `listen on vio0 port http`), `relayd` will grab only one address from it. Catching this bug, which would result in intermittent IPv4-only and IPv6-only operation, was quite the pain!

It's also worth mentioning that `relayd` can listen on port 80 and redirect traffic to it for `httpd` despite `httpd` already listening on port 80. This is possible due to `relayd` interacting with the `pf` firewall, rerouting traffic in part based on firewall rules rather than having to run a server bound to port 80.

### Ruby Deployment Environment

Unlike many other OS distributions, it's not necessary or desirable to use a manager like [RVM](https://rvm.io) or [rbenv](https://github.com/rbenv/rbenv) to manage an application's Ruby version or gemset. OpenBSD provides up-to-date MRI Rubies, as well as JRubies and Mrubies. We're deploying on MRI 3.3, and at the time of writing, OpenBSD 7.6 has `ruby-3.3.5` in binary packages. Using binary packages provided by the OS distribution means they'll get updated along with the rest of packages during OS updates, removing yet another maintenance headache.

This approach does limit the available minor Ruby versions for an application. Our approach has been to use whatever the current MRI Ruby OpenBSD packages, and to specify the same version for development environments.

OpenBSD also provides the `ruby-shims` package, which will select the correct Ruby binary based on several mechanisms. We're using `.ruby-version` files in deployment, as we use them in development with RVM. `ruby-shims` works by symlinking various Ruby components to its own executables; for example, `/usr/local/bin/ruby` is symlinked to `/usr/local/libexec/rubyshim`.

Gemset management is handled by Bundler and Capistrano, so we don't need per-application gemsets managed by another tool.

Using `ruby-shims` and an OS distribution binary Ruby package means that there are no special environment requirements for the deploy user: on previous application servers, we'd set up the deploy user(s) to use `bash`, as that was the simplest way to make RVM behave. Now, the deploy user can use `/bin/ksh` or any other interactive shell.

### Counters Application Server

The microservice-specific setup is handled by another playbook, `counters_app.yml`:

{% codeblock :language => 'yaml', :title => 'counters_app.yml' %}
{% raw %}
---
- name: Configure Sinatra counters application hosts
  hosts: staging.bee.glitchworks.net,appserv1.alb.glitchworks.net
  become: yes

  vars:
    ansible_doas_pass: "{{ ansible_user_password }}"
    application_path: /home/counters/counters
    shared_db_config: "{{ application_path }}/shared/config/database.yml"

  roles:
    - mariadb_server
    - role: sinatra_apphost
      application_name: counters
      deploy_user: counters
      syslog_facility: local0

  tasks:
    - name: Create counters database
      mysql_db:
        name: counters
        login_user: root
        login_password: "{{ mariadb_root_password }}"
        state: present

    - name: Create counters DB user and grant permissions
      mysql_user:
        name: counters
        password: "{{ counters_db_password }}"
        priv: 'counters.*:ALL'
        login_user: root
        login_password: "{{ mariadb_root_password }}"
        state: present

    - name: Ensure shared configuration directory exists
      file:
        path: "{{ shared_db_config | dirname }}"
        state: directory
        owner: counters

    - name: Populate shared database.yml
      template:
        src: "{{ inventory_hostname }}/counters_database.yml.j2"
        dest: "{{ shared_db_config }}"
        owner: counters
        mode: '0600'
{% endraw %}
{% endcodeblock %}

This playbook sets up the MariaDB database for the microservice and grants permissions. It then drops a populated `database.yml` in, filled out with the correct database username and password for the server.

Most of the other configuration is handled in the role delegation to the `sinatra_apphost` role. A condensed section of it follows:

{% codeblock :language => 'yaml', :title => 'Sinatra Apphost Role' %}
{% raw %}
- name: Install Ruby 3.3 and ruby-shims
  package:
    name: ruby-3.3.5,ruby-shims

- name: Ensure git is installed
  package:
    name: git
    state: present

- name: "Create deploy user: {{ deploy_user }}"
  user:
    name: "{{ deploy_user }}"
    comment: "{{ application_name }} deploy user"
    shell: /bin/ksh

- name: "Create rc-script for {{ application_name }}"
  template:
    src: openbsd_service.j2
    dest: "/etc/rc.d/{{ application_name }}"
    owner: root
    group: wheel
    mode: '0555'

- name: "Enable rc-script for {{ application_name }}"
  service:
    name: "{{ application_name }}"
    enabled: true

- name: Check for syslog facility conflict
  replace:
    path: /etc/syslog.conf
    regexp: '^({{ syslog_facility }}.*\s+)(\/.*)$'
    replace: '\1/var/log/{{ application_name }}'
  check_mode: true
  register: syslog_facility_presence

- name: Throw error if the specified syslog facility is already configured
  fail:
    msg: "ERROR: syslog facility '{{ syslog_facility }}' is already in use by another application."
  when: syslog_facility_presence.changed

- name: "Configure syslogging for {{ application_name }}"
  lineinfile:
    dest: /etc/syslog.conf
    line: "{{ syslog_facility }}.*            /var/log/{{ application_name }}"
    regexp: "^{{ syslog_facility }}.*"
    state: present
  notify: Restart syslog daemon

- name: "Touch syslog file for {{ application_name }}"
  copy:
    content: ""
    dest: "/var/log/{{ application_name }}"
    force: false
    owner: root
    group: wheel
    mode: '0644'
  notify: Restart syslog daemon

- name: Configure log rotation
  blockinfile:
    path: /etc/newsyslog.conf
    marker: "# {mark} Ansible-managed block for {{ application_name }} logs"
    block: |
      /var/log/{{ application_name }}     644  4     *    $W0   Z

- name: Grant doas permission for deploy user on rc-script
  blockinfile:
    path: /etc/doas.conf
    marker: "# {mark} Ansible-managed block for {{ application_name }} deploy user"
    block: |
      permit nopass {{ deploy_user }} cmd /etc/rc.d/{{ application_name }}
    validate: doas -C %s

- name: Generate SSH key for deploy user if none exists
  user:
    name: "{{ deploy_user }}"
    generate_ssh_key: yes
    ssh_key_type: ed25519
    ssh_key_comment: "{{ deploy_user }}@{{ inventory_hostname }}"
    force: no

- name: Add Glitch Works, LLC authorized SSH keys
  authorized_key:
    user: "{{ deploy_user }}"
    state: present
    key: "{{ lookup('file', item) }}"
  with_fileglob:
    - "credentials/ssh_pubkeys/*.pub"

{% endraw %}
{% endcodeblock %}

The `sinatra_apphost` role is responsible for installing Ruby, the `ruby-shims` package, making sure Git is installed, and setting up the deploy user. It then created a rc-script from a template for the microservice, and sets up syslog facilities for it. `doas` (OpenBSD's `sudo` replacement) entries are created to allow the deploy user to manage the Puma processes through the rc-script. Finally, a deploy key is generated for the deploy user, and SSH authorized keys for the workstations that may deploy the application are installed.

### Managing Puma with rc-scripts

One of the big changes with this deployment was the management of the microservice's HTTP server using rc-scripts. Prior deploys relied on Capistrano tasks, such as `cap production unicorn:start` to manage it, and did not run automatically on the server. This resulted in situations where one had to remember to restart *all of the applications on a given server* if it was restarted for some reason.

OpenBSD handily provides everything we need to write simple, effective rc-scripts. Here's the rc-script for the counters microservice:

{% codeblock :language => 'shell', :title => '/etc/rc.d/counters' %}
#!/bin/ksh

# Managed by Ansible, DO NOT HAND-EDIT!

# Sinatra/Puma startup script for counters

daemon_execdir="/home/counters/counters/current/"
daemon="RACK_ENV=production bundle exec pumactl start"
daemon_user="counters"
daemon_logger="local0.info"

# Run in background
rc_bg=YES

. /etc/rc.d/rc.subr

rc_check() {
        cd /home/counters/counters/current/
        RACK_ENV=production bundle exec pumactl status
}

rc_restart() {
        cd /home/counters/counters/current/
        RACK_ENV=production bundle exec pumactl phased-restart
}

rc_stop() {
        cd /home/counters/counters/current/
        RACK_ENV=production bundle exec pumactl stop
}

rc_cmd "$1"
{% endcodeblock %}

The above lets us accomplish everything we wanted with microservice management: we can now control it with an rc-script that can be set to start/stop automatically as the system is brought up or shut down, it drops to an unpriviledged user, and it logs. Logging is via `syslog` facilities. In the above example, we're using `local0`, which is specified when the `sinatra_apphost` role is brought in. `/etc/syslog.conf` is also configured to put all messages at level `info` or higher into `/var/log/counters`, which is rotated by `newsyslog`.

My rc-script departs from some of the other examples I'd seen online in that it fully uses built-in OpenBSD rc-script facilities, such as `daemon_user` and `daemon_logger`.

Do note that Puma had to be configured to drop its PID file at `/home/counters/counters.pid` to avoid issues with Capistrano deployments overwriting it.

### Capistrano Tasks

I added a custom Capistrano task to start/restart the Puma server in `config/deploy.rb`:

{% codeblock :language => 'ruby', :title => 'config/deploy.rb' %}
# config valid only for current version of Capistrano
lock '3.19.2'

set :application, 'counters'
set :repo_url, 'git@github.com:glitchwrks/counters.git'
set :deploy_to, '/home/counters/counters'
set :keep_releases, 2

namespace :puma do
  desc 'Restart Puma via rc-script' 
  task :restart do  
    on roles(:web) do
      execute 'doas /etc/rc.d/counters restart'
    end  
  end
end
{% endcodeblock %}

This allows us to run `cap production puma:restart` from the command line, or have deploy scripts automatically restart Puma once the deploy is finished. There's a `capistrano3-puma` gem available, but it seems to be applicable only to deployments on platforms running `systemd` which we're obviously not doing on OpenBSD!

The Capistrano task does depend on `doas` being configured to allow passwordless invocation of `/etc/rc.d/counters` by the deploy user. One should not give `doas` permission to call `/usr/sbin/rcctl` -- that would allow the deploy user to *restart any running process on the system* which is definitely not desirable!

### Conclusion

Well, that's basically it! I think writing the Ansible playbooks and getting them just right took more time than anything OpenBSD-specific, including having to find that weird `relayd` bug concerning `listen` directives. Next, we'll be working on playbooks for deploying Rails applications in the same manner. In the meantime, the counter below is being served to you by essentially the above:

{% counter :text => 'applications hosted on OpenBSD' %}