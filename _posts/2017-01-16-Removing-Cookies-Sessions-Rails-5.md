---
layout: post
title: Removing Cookies and Sessions from Rails 5
topic: Stripping cookies and sessions out of Rails 5
category: programming
description: In transitioning from Sinatra to Rails for site services, I ended up removing pieces of Rails 5 that were not relevant to my project. This post covers removing cookies and sessions and their related configuration options, and what can and cannot be removed.
image: rails.png
---

{% danger :add_break => true %}
Stripping out part of Rails' security features is often a [Bad Thing](http://www.catb.org/jargon/html/B/Bad-Thing.html) and shouldn't be done unless you're really sure you don't need them. *Rails' default configuration is sane and promotes security for most uses.* Don't follow the advice in this article blindly!
{% enddanger %}

This site's dynamic functions started out as being provided by a small [Sinatra](http://www.sinatrarb.com/) application. You can view that project [on GitHub](https://github.com/chapmajs/site_services.git). It started out with counters, then got a `POST` endpoint for a contact form bolted on, and eventually ended up supporting part of my preorder system. I had included [ActiveRecord](https://rubygems.org/gems/activerecord) from the start, but as the application started needing email templates, better user-facing error reporting, et c. it became clear that I should just tranisition to [Ruby on Rails](http://rubyonrails.org/) rather than slowly bringing in all of the bits of Rails, one at a time.

In converting to Rails, I sought to disable cookies from all parts of the application where they weren't required -- there was nothing that needed cookies, so why bother sending one? By default, that means losing session support with Rails. Many applications pass around a `SESSION_ID` parameter from page to page, but this isn't something that Rails supports without custom or third-party code. No big deal, we don't need a session since everything is stateless in this application.

Turning Off Cookies and Sessions
--------------------------------

In `config/application.rb`, we remove the middleware responsible for both cookies and the cookie-based session store:

{% codeblock :language => 'ruby', :title => 'Disable Cookies in Rails 5' %}
# Disable cookies, we don't use them here
config.middleware.delete ActionDispatch::Cookies
config.middleware.delete ActionDispatch::Session::CookieStore
{% endcodeblock %}

Since that effectively breaks sessions, we'll turn those off, too. We're doing this in `config/initializers/session_store.rb`:

{% codeblock :language => 'ruby', :title => 'Disable Cookies in Rails 5' %}
# Not using sessions here
Rails.application.config.session_store :disabled
{% endcodeblock %}

If you still want to use flash messages, you'll need to manually include them in `config/application.rb`:

{% codeblock :language => 'ruby', :title => 'Disable Cookies in Rails 5' %}
# Enable flash messages, these will be on the request since we're not using sessions
config.middleware.use ActionDispatch::Flash
{% endcodeblock %}

Flash messages still work, they will just come from the request rather than the session.

Disabling CSRF Protection
-------------------------

With sessions disabled, [CSRF](https://en.wikipedia.org/wiki/Cross-site_request_forgery) protection is effectively also broken. Running your Rails app as configured will produce warnings in the log concerning unverifiable CSRF tokens. Again, unless you're going to use custom or third-party code, CSRF will be effectively broken and should also be turned off. There's a few steps to this. First, go ahead and remove `protect_from_forgery` from your base controller class (whatever class extends `ApplicationController::Base`, often `app/controllers/application_controller.rb`). This will stop Rails from warning you about unverifiable CSRF tokens. 

To reduce noise, you can also remove the `csrf_meta_tags` include from your base `ApplicationLayout` (often `app/views/layouts/application.html.erb`). This will prevent meta tags containing the CSRF token from being inserted in responses. We can also tell Rails to stop inserting hidden CSRF token fields into forms -- these will show up as a hidden field called `authenticity_token` by default. Leaving them in, like `csrf_meta_tags`, doesn't hurt anything, but it's another parameter that will come in with every form. Disable it by adding the following to your application config:

{% codeblock :language => 'ruby', :title => 'Disable CSRF Protection in Rails 5' %}
# No session, so don't bother with CSRF tokens
config.action_controller.allow_forgery_protection = false
{% endcodeblock %}

This application-wide setting will stop `form_tag`, `form_for`, and things that extend Rails' form support, like the [simple_form gem](https://github.com/plataformatec/simple_form), from inserting `authenticity_token` fields into your forms.

secret_key_base Still Required
------------------------------

After removing cookies and sessions from my Rails application, I incorrectly assumed that I could omit the `secret_key_base` from `config/secrets.yml`. Configuration guides state that the key is used to cryptographically sign cookies which contain a session ID, as well as for encrypting the entire session when an application is using Rails' [cookie-based session store](http://api.rubyonrails.org/classes/ActionDispatch/Session/CookieStore.html). Omitting the key from the secrets file results in a number of warnings and errors. I tried monkey-patching around them, only to find more errors. A [search through the GitHub repo](https://github.com/rails/rails/search?utf8=%E2%9C%93&q=key_generator) turns up several uses of `key_generator` that have no relation to cookies or sessions, so it seems the `secret_base_key` (or `secret_token` if you like deprecation warnings) is always required for various internal bits of Rails.

Security Implications
---------------------

As the warning at the top of the page notes, this isn't something that most people should be doing to their Rails applications. In this specific case, the application has no concept of users or sessions. Everything is a stateless action coming from an unidentified, unauthenticated end user. The few benefits against scripted DoS attacks afforded by a CSRF token are easily nullified by the attacker doing a `GET` to the endpoing that supplies the form (and authenticity token!) before doing their malicious `POST`. 

Removing cookie and session support reduces the available attack surface of the application -- there is no persistent data between requests, except what's in the database and the temporary storage of the request's flash message(s).

{% counter :id => 'rails_cookies', :text => 'sessions hijacked' %}
