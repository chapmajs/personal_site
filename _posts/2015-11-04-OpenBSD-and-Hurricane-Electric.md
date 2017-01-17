---
layout: post
title: OpenBSD, Hurricane Electric, and Dynamic IPs
topic: Keeping your Hurricane Electric IPv6 tunnel up with dynamic IPs
category: coding
description: Hurricane Electric allows dynamic updates for your end of the IPv6 tunnel, but OpenBSD needs to be made aware of the changes too. Here's a simple script to accomplish that.
image: openbsd.gif
---

I've recently replaced my aging home router with a plain install of [OpenBSD](http://www.openbsd.org). This means taking care of some of the nice automatic features pfSense provided by hand. This one wasn't particularly difficult, but there exist several incomplete or incorrect guides on how to solve it.

[Hurricane Electric](https://www.he.net) provides free IPv6 tunnels through their [tunnelbroker.net](https://www.tunnelbroker.net) service. This allows those of use whose ISPs *still* don't have native IPv6 to easily obtain IPv6 connectivity with zero cost. Their service allows for tunnels with DHCP IPv4 addresses, which of course are common with both residential and small business Internet connections. A tunnel's IPv4 address can be updated by providing information to a [Dyn-compatible endpoint](https://help.dyn.com/remote-access-api/) in a HTTP GET. Existing tools, such as [ddupdate](https://code.google.com/p/umonkey-tools/wiki/ddupdate), can be configured to work with Hurricane Electric's endpoint.

That still leaves the problem of updating the [gif](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man4/gif.4) tunnel on your end. pfSense handles this with a "HE.net Tunnelbroker" type through DynDNS services. It's an exercise left to the reader for OpenBSD. My solution can be found [in my GitHub repository](https://github.com/chapmajs/Examples/blob/master/openbsd/update_he.sh). Here's an explanation of how it works:

Local gif Interface
-------------------

Fairly straightforward, here `hostname.gif0` is written using `ifconfig` and `awk` to figure out the IPv4 address of the egress interface. This gets used to dynamically set the local tunnel endpoint. For this to work, the egress interface must be up before `gif0` gets created.

Hurricane Electric Endpoint
---------------------------

Hurricane Electric's Dyn-compliant endpoint will automatically update your tunnel endpoint (and optionally, a DNS A record, if you're using [dns.he.net](https://dns.he.net) for your DNS) through a HTTP GET. [This page](https://forums.he.net/index.php?topic=1994.0) describes the basics of what you need to send to their endpoint:

* Username - your tunnelbroker.net username
* Password - tunnel-specific auth key *or* your tunnelbroker.net password
* Hostname - several options, I chose the numeric tunnel ID
* IP Address - you can optionall send the IP you want to assign

The last parameter -- IP Address -- is optional. If omitted, the endpoint will use the IP that the request comes in on. This is fine as long as you're not load balancing across two or more public IPv4 addresses. This is the method my script uses, since it allows for one less step in updating the tunnel configuration.

Making a HTTP GET request to the HE.net endpoint results in one of several return codes, [specified in the Dyn API](https://help.dyn.com/remote-access-api/return-codes/). We'll take advantage of those to determine if our update was successful, and the IP to which we are bound. Important return codes:

* `nochg X.X.X.X` will be returned if the tunnel endpoint is already set to your current IP
* `good X.X.X.X` will be returned if the tunnel endpoint was updated with a new address
* `good 127.0.0.1` will be returned, unintuitively, if there's something wrong with the request (unless you really supplied `127.0.0.1`)

All other return codes are an error condition. This makes it fairly easy to parse good results from the request, and log problems.

In addition to the return status, `nochg` and `good` updates return the IP address currently assigned to the endpoint. For a `good` update that doesn't include `127.0.0.1` as the IP address, we now have our public IP with no additional work. We can then use that information to reconfigure the `gif` tunnel.

Caveats, Shortcomings, et c.
----------------------------

[Shawn Webb](http://0xfeedface.org) pointed out that, using this method, the tunnel password will be visible during the `curl` call in the system process list. Perhaps not an issue on a router, where the only users viewing the process list should be authenticated, but definitely a problem on a multiuser system!

Too many requests of a certain type can be considered "abusive" for Dyn-compliant updates. I ran into this while testing the script -- it seems that HE.net will quickly generate an "abuse" reply after a small number of queries that result in `good 127.0.0.1`, such as trying to set your IP to `1.2.3.4` or `8.8.4.4`. Additionally, the script consumes more bandwidth than necessary, since it's running as a periodic cron task and making a HTTP GET whether it needs to update the tunnel endpoint or not (it doesn't keep state).