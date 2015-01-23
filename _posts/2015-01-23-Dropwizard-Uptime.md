---
layout: post
title: Reporting Dropwizard Uptime via Metrics
topic: Configuring uptime reporting in Dropwizard
category: coding
description: Another simple configuration task with insufficient documentation! Get your actual application uptime from Dropwizard's metrics.
image: dropwizard.png
---

During A/B testing in our application rewrite project, we discovered default [Dropwizard](http://www.dropwizard.io) metrics didn't provide actual application uptime. This becomes important when you've got an automated build/deploy environment that includes periodic health checks and the ability to restart only the application instance, rather than the entire application server. System uptime is not necessarily representative of application instance runtime.

Dropwizard includes [Coda Hale Metrics](https://github.com/dropwizard/metrics) in its default collection of Java tools. This allows easy collection of application metrics, both from a set of default included metrics sources and custom metrics. The default set of metrics includes many useful things you'd want to know about a Java application: memory usage, thread statistics, and garbage collector stats, for example. 

While uptime isn't included in the default set of provided metrics, an uptime metric [seemed to be available](https://github.com/dropwizard/metrics/blob/master/metrics-core/src/main/java/com/codahale/metrics/JvmAttributeGaugeSet.java) as part of the metrics package. I couldn't find any documentation on using or registering these metrics, which turns out to be very simple. Add the following to your Dropwizard application class:

{% highlight groovy %}
import com.codahale.metrics.JvmAttributeGaugeSet

class YourApplication extends Application<YourApplicationConfiguration> {

    @Override
    void run (YourApplicationConfiguration configuration, Environment environment) throws Exception {
        /* Other application initialization */
        environment.metrics().registerAll(new JvmAttributeGaugeSet())   
    }
}
{% endhighlight %}

Dropwizard Metrics will now report uptime, in milliseconds, in the gauges section of the metrics report. The gauge is registered with the key `uptime`. Since this method brings in the entire `JvmAttributeGaugeSet`, you'll also get metrics for the name (pid@hostname) and JVM vendor.
