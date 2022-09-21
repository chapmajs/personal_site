---
layout: post
title: Configuring an access log for Dropwizard projects
topic: Configuring an access log for Dropwizard projects
category: coding
description: One would think that access logging would be a common task for any application, but getting here took half a day of digging through incorrect documentation.
image: dropwizard.png
---

[Dropwizard](http://www.dropwizard.io) is a collection of Java tools that relies on sane defaults to simplify the creation of RESTful applications serving content over a HTTP API. We're using it as part of an effort to break a monolithic app into smaller microservices. Most of its configuration is straightforward and well-documented; however, figuring out how to log HTTP access to a file was a pain. It's not that the configuration changes are particularly difficult, just that there's a ton of outdated or just plain wrong documentation out there!

We added the following to our YAML configuration file:

{% codeblock :language => 'yaml', :title => 'DropWizard Configuration' %}
server:
  requestLog:
    appenders:
      - type: file
        currentLogFilename: /var/log/our-app/access.log
        archivedLogFilenamePattern: /var/log/our-app/accedd-%d.log.gz
{% endcodeblock %}

This will store [Common Log Format](http://en.wikipedia.org/wiki/Common_Log_Format) entries in `/var/log/our-app/access.log`, mirroring the entries you'd typically see in your console when running Dropwizard in development mode. Not difficult, just often incorrectly documented!

