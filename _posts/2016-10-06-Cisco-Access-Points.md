---
layout: post
title: Cisco Aironet Access Points
topic: Getting Cisco APs Up and Running
category: network
description: I picked up some used Cisco 802.11 access points a few months ago, and finally got around to hacking on them. They're available for cheap as used equipment, especially if they're loaded with LWAPP firmware. This is my experience with getting them up and going in autonomous mode.
image: lego_logo-icon.jpg
---

A few months ago, I picked up a box of Cisco 802.11 wireless access points at auction, a mixed box of 1200 and 1130 series APs in unknown condition. These little APs provide varying levels of 802.11 wireless service: 2.4 GHz B-only, 2.4 GHz B/G, and dual band A/B/G, depending on the model and the supplied radio(s). These seemed like they might be a good alternative to either running an AP on a wireless card in an existing router, or using a consumer AP/router as an access point. I finally got around to hacking on them and figuring out what they can do, and how to make them work as standalone units with my network. I've since purchased some 1140 series Wireless-N access points from the same auction, and will cover those as well.

## Test Network

I wanted to use the following layout for a test network, it's similar to what I ended up with for my home/office network:

* VLAN 10 for LAN traffic
* VLAN 11 for Wireless traffic
* VLAN 20 for management traffic
* Access to everything from LAN
* Access to Internet and a few select LAN devices for Wireless
* IPv6 on all VLANs

The above VLAN numbering will be used in examples, below.

## Powering the Access Point

All of the APs discussed will operate on [Power over Ethernet](https://en.wikipedia.org/wiki/Power_over_Ethernet). Cisco claims 802.3af compliance, which is a protocol whereby the power supply negotiates power with the powered device (PD), rather than just putting DC on unused pairs in the Ethernet cable. Additionally, the APs tested have a jack for an external power supply. I chose to power them with Power over Ethernet since I've got a few PoE injectors and switches.

If you don't have an injector or a switch that provides 802.3af PoE capability, you have many options for injectors. For test setups, I have a few Proxim AE Model 4301 power injectors. These injectors use only the spare pairs in a 10/100 mbit Ethernet connection for power and will work with many well-behaved 802.3af PDs including Cisco APs. They're a small, self-contained unit with the power supply built into the unit, so no external wall wart or line lump is required, just an IEC power cable. They won't destroy non-PoE gear plugged into the power output port, which is apparently a problem with some cheaper PoE injectors.

**WARNING** Do not buy a "passive" injector or any power source which does not explicitly state 802.3af compliance. You can destroy your AP, the injector, or both.

It seems there's a lot of misunderstanding and mis-marketing for "802.3af Compliant" devices! The standard states that power can be provided either on the "spare" pairs (unused with 10/100 mbit Ethernet), or on the active pairs. In the case of Gigabit Ethernet, there are no spare pairs. In testing with both the Proxim injectors and a Foundry/Brocade FastIron PoE switch, it was discovered that the Cisco 1200 and 1140 series APs appeared to be "fully compliant," while the Cisco 1130 APs appeared to only accept power on the "spare" pairs. Keep that in mind if you already have a PoE capable switch.

## Firmware Updates

The first step in getting APs up and going is to make sure you have the proper firmware loaded. Many Cisco APs purchased used will be loaded with the LWAPP (LightWeight Access Point Protocol) firmware, which is intended for use with a centralized AP controller. All of the APs discussed here can be loaded with either the LWAPP firmware, or the "Autonomous AP" firmware. For the 1200 series APs, there's also a vxWorks based firmware, which won't be discussed. For standalone use, the Autonomous IOS image is what you'll want. Even APs shipped with factory LWAPP firmware (AIR-LAPxxxx model numbers) can be upgraded to Autonomous mode.

Obtaining the firmware is an exercise left to the reader: a free Cisco support account will get you some firmware options, but not all. Only the "IP Base" level firmware will be discussed -- that is, no features requiring a higher level of licensing will be used.

It helps to have a Cisco console cable and USB -> RS-232 adapter when doing firmware updates. It's possible to do them without a console cable, using only the indicator LEDs on the AP to determine what's going on. Cables are cheaply available online, and can be purchased with built-in USB converters, if desired. I've got the old style RJ-45 rollover cable, a RJ-45 to DB9 converter, and a Prolific based USB converter, so I can't comment on any of the current all-in-one offerings.

I followed [this guide](https://paulbeyer.wordpress.com/2010/01/16/converting-a-cisco-ap-from-lwapp-to-autonomous-mode/) for reloading the firmware on my APs. You don't need to know the current password(s) for the AP, in the event that you've purchased a used unit that hasn't been reset. I used the `in.tftpd` server bundled with [Slackware Linux](http://www.slackware.com), storing the firmware files in `/srv/tftp/`. Make sure permissions are correct, and run the TFTP daemon:

{% highlight bash %}
in.tftpd -L -a 255.255.255.255 -s /srv/tftp
{% endhighlight %}

You need to tell `in.tftpd` to listen on the broadcast address, `255.255.255.255`, with the `-a` switch. This was missing from the linked guides, and all others I found. By default, `in.tftpd` binds to any available address, but won't respond to broadcast requests unless you tell it to. Took about an hour and a half of head-desk to figure that out!

## Initial Configuration

After a firmware reload, the AP will come up in Autonomous IOS and try to pull an IP from DHCP on the Ethernet interface. If you've got the console cable connected, you'll see the IP assignment. You can connect to a HTTP configuration app on the AP's address, or Telnet to it. The default username/password is Cisco/Cisco, and the enable password is Cisco as well. If you're going to set up managment VLANs (as below), you'll need to either do that configuration from the serial console, or upload a configuration and wait for the network to reconfigure itself.

If you list interfaces, you'll see that the IP is assigned to BVI1, not `FastEthernet0` or `GigabitEthernet0` as you might have expected. That brings us to...

## What is the BVI, Anyway?

There seems to be a lot of confusion about this, from forum posts to Cisco documentation, to what appears to be semi-official Cisco writeups by CCIEs or something. You see a lot of posts voted as "correct answer" on the usual community help forums suggesting that BVI interfaces are some special sort of routing interface, that you'll need to use DHCP relays on them because they're a separate Layer 2 broadcast domain, et c. Incorrect.

The BVI is the Bridge Virtual Interface. It's analogous to the various VLAN interfaces you can have on e.g. Catalyst switches running IOS. `BVI1` is a special case, at least on Aironet APs running IOS, in that it's always tied to IRB `bridge-group 1`. You can't define a different `bridge-group`, and it's kind of unclear as to whether you can create more BVI interfaces. A `bridge-group` is a way of bridging interfaces together in a Layer 2 bridge, just like a switch does. It's analogous to using `bridge-utils` in Linux or adding interfaces to `bridge0` in OpenBSD. As such, the BVI is just a virtual interface that's bridged in.

Typical application would be to "tap in" on a bridge between one or more other interfaces; say, `FastEthernet0` and `Dot11Radio0` on an AP. You leave both `fa0` and `dot0` without IP addresses, bridge in `BVI1`, and assign the IP there. All three are part of the same `bridge-group` (you assign `bridge-group 1` on `fa0` and `dot0`, it's implied on `BVI1`) and act just like three separate things plugged into an access switch. I guess the confusion stems from the implied association between `BVI1` and `bridge-group 1`.

With Cisco IOS 12, you can coerce IOS into putting `BVI1` on a VLAN other than the default/native VLAN for the Ethernet interface. This doesn't seem to be possible with IOS 15.

## Separate Management VLAN With IOS 12

If you don't want to associate `BVI1` with the native VLAN on the APs Ethernet interface, you can coerce IOS into using a VLAN with IOS 12. Configuration is a little unintuitive, and it seems that Cisco doesn't really want APs configured in this way. The following is an example configuration from the Catalyst 2940 switch on my test network, which provides the VLAN trunk port to the AP under test:

{% highlight ios %}
interface FastEthernet0/5
 switchport trunk native vlan 99
 switchport trunk allowed vlan 11,20
 switchport mode trunk
 switchport nonegotiate
{% endhighlight %}

Setting the native VLAN to 99 effectively blackholes any untagged traffic coming into the port, provided nothing is using VLAN 99. No untagged traffic will leave the port, since VLAN 99 isn't used for anything other than a blackhole in my configuration. This is typically a good idea as an additional layer in securing your network. We're going to allow tagged packets for VLAN 11 (Wireless subnet) and VLAN 20 (management subnet) across the trunk.

Basically, we want to assign `bridge-group 1` to something other than `FastEthernet0` or `GigabitEthernet0`, but IOS won't let you do

{% highlight ios %}
conf ter
inter fa0
no bridge-group 1
{% endhighlight %}

And, you can't add a subinterface to `bridge-group 1` without removing the parent interface! The following snippet will force `FastEthernet0` out of `bridge-group 1`:

{% highlight ios %}
conf ter
inter fa0
bridge-group 2
no bridge-group 2
{% endhighlight %}

With that taken care of, you can now create a subinterface for VLAN 20 and assign it to `bridge-group 1`. The following configuration will put managment on VLAN 20:

{% highlight ios %}
interface FastEthernet0
    no ip address
    no ip route-cache
    duplex auto
    speed auto

interface FastEthernet0.20
    encapsulation dot1Q 20
    no ip route-cache
    bridge-group 1
    no bridge-group 1 source-learning
    bridge-group 1 spanning-disabled

interface BVI1
    ip address dhcp client-id FastEthernet0
    no ip route cache
{% endhighlight %}

From this point, configure the AP as you normally would. There are many good guides for configuring IOS APs from the command line. I don't personally use the web interface, so I can't say whether it will work properly with a non-native management VLAN.

## IOS 15 and VLAN Issues

IOS 15 is quite resistant to having `BVI1` sit on anything other than the native VLAN. It'll lie to you about what's going on. You can't use the `bridge-group` swap as mentioned above to get `bridge-group 1` off of `GigabitEthernet0`. You can upload a configuration from e.g. TFTP with `bridge-group 1` assigned to a different interface, but you'll have to copy it to `startup-config` and reboot. You can also do the following:

{% highlight ios %}
conf ter
inter gi0.10
encap dot1q 10 native
inter gi0
bridge-group 2
inter gi0.10
no encap dot1q 10 native
encap dot1q 10
{% endhighlight %}

Now, if you put a port into monitor mode (port mirroring), at least on a Cisco switch (I used a little Catalyst 2940), and you have Dot1Q encapsulation turned on for the destination port, THE SWITCH WILL ADD VLAN HEADERS BACK! You'll see traffic moving around with VLAN 10 tags. I guess this is some sort of diagnostic translation where the monitor session is automatically assigning the switchport's native VLAN header to packets that are really untagged.

So how do we actually know these are untagged, when everything is pointing to them being tagged? Well, for one, that's how `switchport trunk native vlan 10` works. Also, you can break out your trusty 10baseT hub (not a switch, a hub -- multiport repeater) and use *that* to mirror traffic to your packet sniffer. Being dumb repeater devices, hubs won't mess with any of your traffic, and you'll see untagged packets flying back and forth that you might have expected to be tagged as VLAN 10.

Just for completeness, the same setup was tried with the same AP running IOS 12 and the above configuration tricks. `BVI1` traffic is indeed encapsulated with the proper VLAN headers under IOS 12.

{:.center}
<span><script language="javascript" src="https://services.theglitchworks.net/counters/cisco_aps"></script> WRT54Gs replaced</span>