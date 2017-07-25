---
layout: post
title: A Universal RAM Board for OSI, GW-OSI-RAM1
topic: Designing and testing the GW-OSI-RAM1
category: osi
description: A common issue when restoring, repairing, or building up an Ohio Scientific system is a lack of dense, reliable RAM. OSI boards do exist that provide 64K of static RAM on a single low-power board, but these are rare. There are even fewer options if you want 12-bit support for the 560Z Processor Lab in PDP-8 mode. With two prototype RAM boards built, I decided to lay out a universal OSI RAM board to meet the needs of as many OSI systems as possible.
image: GW-OSI-RAM1_icon.jpg
---

## Quick Links

* [osiweb.org Forum Build Thread](http://www.osiweb.org/osiforum/viewtopic.php?f=3&t=332&p=2130)
* [32K Prototype Build](/2016/04/23/32k-ram-for-osi)
* [32K -> 64K Prototype Expansion](/2016/05/17/64k-ram-for-osi)
* [560Z Build, including 12-bit RAM](/2017/02/26/osi-560z-build)

## Introduction

Reliable, dense, low-power RAM is often a problem with Ohio Scientific systems: many original OSI RAM boards are fairly low density and/or power hungry. More modern boards using 6116 static RAMs do exist, but are uncommon and very desirable, since they eliminate many issues with older OSI RAM boards. Indeed, the main motivation behind [cloning the OSI 495 protoboard](/2016/04/22/cloning-the-495) was to have a protoboard on which to build a better RAM board!

The situation is worse with the [560Z Processor Lab](/2017/02/26/osi-560z-build), as it requires 12-bit RAM for PDP-8 operation. The only OSI board that provides 12-bit RAM is the OSI 420, an early board using 2102 static RAMs. 2102s are both power hungry and hard to find, and the 420 board is limisted to 4K. With two prototype RAM boards built, I wanted to lay out a proper PC board to make building RAM boards less time consuming for both myself and other OSI hackers. Building on the [32K prototype](/2016/04/23/32k-ram-for-osi) (later [expanded to 64K](/2016/05/17/64k-ram-for-osi)) and the 12-bit prototype built specifically for the [560Z Processor Lab project](/2017/02/26/osi-560z-build), I came up with a set of goals and features for a universal OSI RAM board.

## Design Goals and Features

In my mind, a universal RAM board needed the following:

* Fully static operation
* No expensive/hard-to-get components (8T26 buffers, et c.)
* 8- and 12-bit support
* Support for inverted and non-inverted data bus
* Optional bank switching
* Possible ROM support
* Ability to be mapped around existing RAM, ROM, and I/O

The original RAM prototype met many of these goals, using 62256 32K x 8 SRAMs which could be enabled in 4K increments on any 4K boundary in address space. The prototype built for the 560Z project went further, replacing 8T26 buffers with common 74LS240 buffers, and adding a lamp register for diagnostic pruposes. Bank switching/memory management support was still missing, but the prototype circuits had been designed in such a way to allow easy memory management with little modification.

## Layout and Testing

The board was laid out in [KiCad](http://kicad-pcb.org/), a completely free and open source CAD package. KiCad has a 3D rendering mode, so before production boards were actually ordered, it was possible to get an idea as to what the prototype would look like:

{:.center}
[![GW-OSI-RAM1 3D Rendering](/images/osi/gw_osi_ram1/scaled/osi_ram_3d_20170406.png)](/images/osi/gw_osi_ram1/osi_ram_3d_20170406.png) [![3D Rendering with Components](/images/osi/gw_osi_ram1/scaled/osi_ram_3d_20170406_components.png)](/images/osi/gw_osi_ram1/osi_ram_3d_20170406_components.png)

I was at first dismissive of KiCad's 3D rendering features, but it was actually very helpful in final design checks and getting a feel for how the layout was progressing. Plus, it was something to show other hobbyists! The GW-OSI-RAM1 was laid out to be run with a board house that has very good pricing on large boards, but uses an awful inkjet/v-jet silkscreen process. As such, all text and symbols were done as copper/solder mask relief. Here's a shot of the segment select switch legends:

{:.center}
[![Segment Select Switches](/images/osi/gw_osi_ram1/scaled/bank_switches.jpg)](/images/osi/gw_osi_ram1/bank_switches.jpg)

The 560Z specific RAM prototype included a lamp register for debug purposes. This was omitted from the main GW-OSI-RAM1 board in favor for a large prototype area and mezzanine connector. Breaking the lamp register out as a mezzanine board allows for octal or hex grouping of the LEDs with only one (large and expensive!) base board. Having the lamp register on a separate board also allows it to be mounted remotely with a ribbon cable, such as on a front panel. The mezzanine connector and standoffs were placed on 0.1" centers to allow mezzanine boards to be built from standard perfboard. Address decode is provided on the GW-OSI-RAM1. If a lamp register is not desired, the prototype area can be used with the mezzanine connector without the need to bring up the data bus from elsewhere on the board. Here's the prototype run board with and without a perfboard mezzanine installed:

{:.center}
[![GW-OSI-RAM1 Without Mezzanine](/images/osi/gw_osi_ram1/scaled/mezzanine_removed.jpg)](/images/osi/gw_osi_ram1/mezzanine_removed.jpg) [![Mezzanine Installed](/images/osi/gw_osi_ram1/scaled/full_board.jpg)](/images/osi/gw_osi_ram1/full_board.jpg)

Initial debugging was done with my [OSI Challenger 3](/2016/04/20/challenger-3-cleanup). Unfortunately, I was set to leave on a business trip the day that the prototype boards arrived. As luck would have it, I was visiting a friend who had a Challenger 2P up and running. We installed the GW-OSI-RAM1 in his 2P with a single 32K SRAM installed, with all but the first 4K segment enabled (the 2P has 4K on the CPU board). As seen in the screenshot below, this raised the RAM available to the user in BASIC to nearly a full 32K. Success!

{:.center}
[![GW-OSI-RAM1 in Challenger 2P](/images/osi/gw_osi_ram1/scaled/2p_installed.jpg)](/images/osi/gw_osi_ram1/2p_installed.jpg) [![Challenger 2P RAM Size](/images/osi/gw_osi_ram1/scaled/2p_memsize.jpg)](/images/osi/gw_osi_ram1/2p_memsize.jpg)

## Prototyping a Mezzanine Board

With the basic RAM board proved out, I needed to build a mezzanine to test the address decode functionality. Since the connector and mounting holes are on 0.1" centers, it's possible to cut down a piece of protoboard and build a mezzanine board. My first prototype is just a lamp register with the LEDs in octal grouping:

{:.center}
[![Mezzanine Front](/images/osi/gw_osi_ram1/scaled/mezzanine_front.jpg)](/images/osi/gw_osi_ram1/mezzanine_front.jpg) [![Mezzanine Back](/images/osi/gw_osi_ram1/scaled/mezzanine_back.jpg)](/images/osi/gw_osi_ram1/mezzanine_back.jpg)

Wire colors follow the same general code as other builds:

* Yellow is data bus
* Green is control signalling
* Red is latch output to lamps
* Gray is ground

The mezzanine board was first tested on the main OSI bus in my Challenger 3, under control of the 6502. The following images show `0x00` and `0x55` loaded into the lamp register. The high four bits are floating on the OSI bus and display random values.

{:.center}
[![Displaying 0x00](/images/osi/gw_osi_ram1/scaled/all_zero.jpg)](/images/osi/gw_osi_ram1/all_zero.jpg) [![Displaying 0x55](/images/osi/gw_osi_ram1/scaled/0x55.jpg)](/images/osi/gw_osi_ram1/0x55.jpg)

## Testing with the 560Z and IM6100

A 12-bit RAM board isn't very useful if not tested to work with 12-bit systems, so it was time to test with my reproduction 560Z board. I loaded values into the lamp register from the OSI 560Z driver, which is [discussed in the 560Z writeup](/2017/02/26/osi-560z-build). This worked fine:

{:.center}
[![560Z Lamp Register](/images/osi/gw_osi_ram1/scaled/560z_control.jpg)](/images/osi/gw_osi_ram1/560z_control.jpg)

The next test was to actually run some PDP-8 code in the RAM present on the GW-OSI-RAM1. I used the short program I'd written earlier that does an up-count and displays it on the lamp register. At full speed, activity is only visible on the higest bits of the lamp register. Issuing a `R0100` command in the OSI driver slow-clocks the IM6100, producing a slow, visible up-count. Here's a quick video of the up-count using the GW-OSI-RAM1 for both lamp register and 12-bit RAM:

<div class="center"><iframe width="560" height="315" src="https://www.youtube.com/embed/0qyRsEWBsg8" frameborder="0" allowfullscreen></iframe></div>

If you're interested in purchasing a GW-OSI-RAM1 Universal RAM board, parts kit, or assembled/tested unit, please use the [contact form](https://services.theglitchworks.net/ng/messages/new).

{% counter :id => 'gw_osi_ram1', :text => 'RAM boards replaced' %}
