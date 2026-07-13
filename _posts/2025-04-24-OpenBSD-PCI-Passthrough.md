Datto heatsink

drilled out 5/32"
deburred 13/64"

---
layout: post
title: Passing PCI Devices to OpenBSD VMs from Linux Virtualization Hosts
topic: PCI passthrough to OpenBSD hosts with libvirt and KVM
category: programming
description: With processor and platform support, PCI passthrough allows a guest virtual machine to directly map host PCI resources, keeping them otherwise inaccessible to the host. Linux VM hosts running libvirt and KVM can support PCI passthrough, but there were a few pitfalls when communicating with OpenBSD guests.
image: openbsd.gif
---

We run several virtualized OpenBSD routers and application hosts on Linux-based virtualization hosts. As more of the platforms we use for the virtualization hosts have moved to hardware that supports [VFIO](https://www.kernel.org/doc/html/v5.6/driver-api/vfio.html) (Virtual Function I/O), experiments were performed to switch from bridged interfaces to PCI passthrough.

PCI passthrough uses the [IOMMU](https://en.wikipedia.org/wiki/Input%E2%80%93output_memory_management_unit) functionality of newer platforms to keep the virtualization host kernel from talking to PCI devices configured for VM use, making the passed-through devices appear to the VM as if they were "plugged in" to the VM's PCI bus. This offers several potential advantages:

* Near-native speed for PCI devices
* Better VM/host isolation
* Support for devices which have no direct virtual counterpart

Passthrough is often used with GPUs, to give VMs exclusive, full-speed access to GPU resources. This is perhaps the most common example found on the Internet, in various guides, etc. It can be configured to work with any PCI device, as long as you have enough IOMMU group granularity. We were interested in passing through entire Ethernet devices for both security separation (the virtualization host would have no interaction with packets on the passed-through interface) and performance.

# Virtualization Platform

Experiments were conducted on our "medium virtualization host" platform, which at the time was the [Advantech FWA-3260](https://www.advantech.com/en-us/products/5f790122-c29e-4453-bb73-0da4c95b7eca/fwa-3260/mod_0d8b27c6-4283-4b90-abba-5aa5c5e068bd), which is a 1U router appliance featuring the Xeon D-1500 series processor. It supports Intel VT-d IOMMU functionality for PCI passthrough, and the included Ethernet interfaces have three distinct sets of PCI IDs:

* Two 

With another mystery increase in the monthly pricing for the paid email service that had been used for glitchwrks.com, I decided to switch back to managing my own mail server. In addition to becoming increasingly expensive, the paid service wasn't providing SPF records I could delegate to, or DKIM signing. I had read about OpenBSD's [OpenSMTPd](https://www.opensmtpd.org/) project some time ago, but had never actually installed and configured OpenSMTPd myself, aside from forwarding system accounts via aliases on other OpenBSD projects.

This is not something new or particularly hard to do, but I did find a few areas in which I was left searching through others' documentation looking for answers. This writeup won't be a step-by-step guide, but references to other resources and explanations of snags I hit. I used the following resources, and recommend a read through them first:

* [Official OpenSMTPd FAQ Example](https://www.opensmtpd.org/faq/example1.html)
* [technoquarter's writeup on Dovecot configuration](http://technoquarter.blogspot.com/2015/02/openbsd-mail-server-part-6-dovecot-and.html)
* [frozen-geek.net's writeup on Dovecot configuration](https://frozen-geek.net/openbsd-email-server-1/)

If you will be using Let's Encrypt for SSL/TLS certificates, read the following:

* [acme-client Documentation, for SSL/TLS](http://man.openbsd.org/acme-client.1)
* [httpd manpage](http://man.openbsd.org/httpd.conf.5)
* [atomicobject.com's writeup on using acme-client](https://spin.atomicobject.com/2016/09/20/openbsd-acme-client-lets-encrypt/)

## Installing the Required Packages

My use case is pretty simple, incoming SMTP, authenticated outbound SMTP relaying, and IMAP for client access. I don't currently require virtuals or multiple domain support, but I followed the [Official OpenSMTPd FAQ Example](https://www.opensmtpd.org/faq/example1.html) and planned for it anyway. OpenSMTPd is part of the base OpenBSD distribution, so that's already present, but you'll need to install the following:

* `opensmtpd-extras` for passwd file authentication (not necessary if you're going to use system logins)
* `dovecot` for IMAP access
* `acme-client` if you are on OpenBSD < 6.1 and plan on using Let's Encrypt for SSL/TLS

## SSL/TLS, Let's Encrypt, and acme-client

[Let's Encrypt](https://letsencrypt.org/) is a free, open, and automated SSL/TLS certificate authority formed with the goal of making SSL/TLS certificates free and so easy to obtain that everyone can secure any connection they'd like. No wildcard certs required when they're free! In addition to being automated for certificate generation, certificates can be automatically renewed yearly with a simple `cron` job. There are many clients for handling creation and renewal of SSL/TLS certificates from Let's Encrypt, but `acme-client` now ships with OpenBSD 6.1 and later. If you're on an earlier version, follow the install instructions on the [project's site](https://kristaps.bsd.lv/acme-client/). Once installed, follow the examples in the [acme-client manpage](http://man.openbsd.org/acme-client.1) for configuring `httpd` to host the challenge files (don't forget to open port 80 in `pf` and any external firewalls!).

`acme-client` will give two files, a `foo.com.fullchain.pem` file and `foo.com.key` in the directories you have configured in [acme-client.conf](http://man.openbsd.org/acme-client.conf.5). The PEM file is your public certificate with full chain, and the key file is your secret private key. When generating keys for OpenSMTPd and Dovecot, generate them for the address that your mail clients will be connecting to. For example, if clients connect to a `CNAME` of `mail.foo.com` which points to `realserver.foo.com`, generate the certificates for `mail.foo.com`.

## Shared Passwd File Authentication

The [Official OpenSMTPd FAQ Example](https://www.opensmtpd.org/faq/example1.html) uses `passwd` file authentication, with a shared file between both OpenSMTPd and Dovecot. I found it unclear on how to generate entries for this file. They're done by hand, with the encrypted password hash being generated with `smtpctl encrypt` -- you can provide the string you wish to encrypt afterwards, but beware that this will be visible in the system process list! Invoking `smtpctl encrypt` with no other options will put you in an encryption shell where each line entered will be encrypted on hitting enter. Type `CTRL+C` to exit.

If you have accounts that will not ever receive email (an account for your site's contact form mailer, for example), you can provide a username in the `passwd` file that does not include the domain portion of an email. For instance, a contact mailer entry could use the username `contactmailer` rather than `contactmailer@foo.com`.

## Dovecot Configuration

Dovecot's configuration is complicated by the fact that it is spread across many files in a `conf.d` directory. In particular, I couldn't immediately figure out where to put the configuration for the shared `passwd` file. I ended up putting it in `10-auth.conf`, at the very end, and commenting out all of the other authentication options. At some point I will probably compact the Dovecot configuration directory down into a single file, since my configuration is rather simple.

After starting Dovecot for the first time with SSL/TLS enabled, generation of the Diffie-Hellman parameters (dhparams) takes quite some time, especially if you've set it to a large value. This caused SSL/TLS connections to fail at first with no clear error message from the Dovecot logs. `tail` the log file and wait for a message indicating completion of dhparams generation before trying to connect over SSL/TLS.

When connecting with [Sylpheed email client](http://sylpheed.sraoss.jp/en/) I had to check the option to use non-blocking SSL. Apparently Dovecot doesn't support it. I didn't test with only sending through OpenSMTPd, though it's hardly relevant since you can't enable it for SMTP and not for IMAP. Of course, if you're connecting on SSL/TLS specific ports (`587` for SMTP, `993` for IMAP) then you want to connect with SSL, not STARTTLS.

## Future Improvements

With basic configuration complete, I'm in the process of switching over to the new server and getting everything checked out before my next monthly bill! Future plans for this mail server include adding DKIM support with `dkimproxy`, automatic filtering of listserv traffic with `dovecot-pigeonhole`, and spammer annoyance with `spamd`.

The overall experience with OpenSMTPd was very good, it will be replacing `postfix` as my MTA of choice for future projects.

{% counter :id => 'opensmtpd', :text => 'emails bounced' %}
