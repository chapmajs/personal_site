---
layout: post
title: Graphing 95th Percentile in Munin
topic: Adding 95th percentile graphing to Munin graphs
category: coding
description: Like many ISPs, my colocation ISP bills bandwidth usage as 95th percentile. The ISP sends weekly and monthly bandwidth graphs to help in planning for bandwidth costs. While this is a common thing, it's not something that Munin supports out of the box, though rrdtool does.
image: munin.png
---

I use [Munin](http://munin-monitoring.org) for monitoring several critical aspects of VMs, applications running in VMs, and the hypervisors themselves. Having historical time-series data helps in planning for hardware upgrades/expansion, gives warning before disks fill up, and helps target which parts of a complex application are causing the most end-user slowdown pain. Bandwidth utilization is monitored on every single VM, since my colocation ISP bills based on usage.

This particular ISP bills on 95th percentile usage, meaning that the top 5% of traffic over a given period is dropped. This allows for large spikes in bandwidth utilization on a lower tier of service, without having to restrict the overall connection to the typical tier of service used. For example, one of my smaller VMs is on a 1 Mbit/s 95th percentile service, but can spike up to the actual interface cap on the ISPs router. Thus, events that require a large amount of bandwidth, like nightly backups, can saturate the connection without forcing the VM into a higher tier of service.

Out of the box, Munin does not chart 95th percentile usage. [This support ticket](http://munin-monitoring.org/ticket/443) requested the feature in 2006. A not-so-great patch was provided as an answer. Since then, Robin Johnson (robbat2) wrote [this writeup](http://robbat2.livejournal.com/240766.html) on adding 95th percentile data to existing graphs using `graph_args_after` which allows for modifying graphs through configuration rather than source code change. This is the guide I followed; however, figuring out where to put the code and how to use it is an exercise left to the reader!

{% codeblock :language => 'ruby', :title => '_plugins/glitchworks_tag.rb' %}

{% endcodeblock %}

{% counter :text => 'bandwidth overcharges avoided' %}
