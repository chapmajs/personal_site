---
layout: post
title: Slot 8 Support on XT-IDE rev 2
topic: Adding slot 8 support to the XT-IDE rev 2
category: xtide
description: Part of the purpose in provinding Slot 8 Support as an optional daughterboard was to allow it to be added to other revisions of the XT-IDE. Installation on XT-IDE rev 2 is almost as simple as with later rev 3 boards, and works with all of the rev 2 features -- ROM, IDE, and serial port.
image: rev_2_slot_8_icon.png
---

## Quick Links

* [GitHub Repository](https://github.com/glitchwrks/xt_ide_slot_8_support/)
* [Build Thread on VC Forums](http://www.vcfed.org/forum/showthread.php?54048)
* [XT-IDE rev 3 Installation Writeup](/~glitch/2017/02/03/slot-8-support)
* [Slot 8 Support on Glitch Works Tindie Store](https://www.tindie.com/products/10590/)

Part of the purpose in doing [XT-IDE Slot 8 Support](/~glitch/2017/02/03/slot-8-support) as a daughterboard module was to make Slot 8 Support available for older revisions of the XT-IDE board. It's usable on any previous board that has ISA pin `B8` present on the edge connector. Many of the rev 1 production run boards had this pin removed to save on plating costs, so the Slot 8 Support board won't work there. It does, however, work with the XT-IDE rev 2 boards, and allows use of ROM, IDE, and even the onboard serial port when the board is installed in Slot 8.

For this installation, I used an earlier prototype from [OSH Park](https://oshpark.com) -- this one uses silkscreen, which was removed in a later revision to allow the board to be produced for less. I went ahead and labeled a few of the ICs on my XT-IDE rev 2 board, and marked the pins we'd be soldering to with small arrows. I used a permanent marker, which will usually erase from the board with isopropyl alcohol.

Installation is the same basic process as with the XT-IDE rev 3: start by removing the solder from pins 14, 20, 22, and 28 of the EEPROM. You only need to remove solder so that the pad is flat, it's not necessary to remove it from the through-hole. Orient the Slot 8 Support module with the capacitor toward the IDE connector end of the XT-IDE. Mount the Slot 8 Support module using its four tabs, soldering them down and keeping the Slot 8 Support module as close to the XT-IDE circuit board as possible:

{% linked_image :file => 'mounted.jpg', :alt_text => 'Slot 8 Support mounted' %}

Since there are no spare jumper or switch positions on the XT-IDE rev 2, I initially installed the module permanently, with no way to disable Slot 8 Support:

{% linked_image :file => 'direct_install.jpg', :alt_text => 'Direct install method' %}

## Hacking in Jumperable Slot 8 Support

One of the VCForums members requested [a way to disable Slot 8 on rev 2 boards](http://www.vcfed.org/forum/showthread.php?54048-Slot-8-Support-Daughterboard-for-XT-IDE&p=437609#post437609), so I came up with the following hack. Jumper K3 on the XT-IDE rev 2 supplies +5V and GND through a three-pin, 0.1" spaced header near the IDE connector. I'm not sure what, if anything, actually uses this feature. Here's K3 on a bare rev 2 board:

{% linked_image :file => 'k3_location.jpg', :alt_text => 'Location of jumper K3' %}

Since this is the end of the line for the +5V trace that goes to K3, and the center pin is left unconnected, we can repurpose K3 as a Slot 8 Support enable/disable jumper. Start by cutting the +5V trace on the component side of the XT-IDE, between K3 and P9:

{% linked_image :file => 'k3_trace_cut.jpg', :alt_text => 'K3 trace cut' %}

As you can see, I like to remove a lot of trace when I make a cut! With the trace cut, snip off the uppermost pin of K3, the pin nearest the IDE connector:

{% linked_image :file => 'k3_pin_cut.jpg', :alt_text => 'K3 pin cut' %}

Route `TP1` from the Slot 8 Support module through the remaining two pins of K3, and down to ISA pin `B8`:

{% linked_image :file => 'k3_mod_installed.jpg', :alt_text => 'K3 modification installed' %}

That's it! If you performed the K3 modification, put a jumper shunt on K3 to enable Slot 8 support, and remove it for use in regular slots. If you're interested in ordering a bare board, parts kit, or assembled module, please {% contact :text => 'use the contact form' %} to make your order. If you have an XT-IDE rev 3 card, here's the [installation writeup](/~glitch/2017/02/03/slot-8-support).

{% counter :id => 'slot_8_support', :text => 'XT Slot 8s Utilized' %}
