---
layout: post
title: IBM XT Slot 8 Support for XT-IDE
topic: Adding slot 8 support to the XT-IDEs
category: xtide
description: The IBM 5160 PC/XT has eight ISA expansion slots, but slot 8 has slightly different electrical requirements. As a result, many boards do not work in slot 8, and those that do usually require a jumper to enable/disable slot 8 support. While the XT-IDE rev 3 was designed with slot 8 support omitted, I decided to design a daughterboard to provide it. In the course of designing it, I was also able to apply it to the earlier XT-IDE designs!
image: slot_8_support_icon.png
---

## Quick Links

* [GitHub Repository](https://github.com/glitchwrks/xt_ide_slot_8_support/)
* [Build Thread on VC Forums](http://www.vcfed.org/forum/showthread.php?54048)
* [XT-IDE rev 2 Installation Writeup](/~glitch/2017/02/05/slot-8-xt-ide-rev2)
* [Slot 8 Support on Glitch Works Tindie Store](https://www.tindie.com/products/10590/)

With the IBM 5160 PC/XT motherboard, ISA slot 8 is a special case. [modem7 provides an excellent write-up](http://www.minuszerodegrees.net/5160/misc/5160_slot_8.htm) on slot 8 and its requirements. Basically, there's a `/CARDSEL` line that needs to be pulled low when a card in slot 8 wants to respond to a read operation. Many cards don't support this feature. Those that do usually have a jumper to specifically enable slot 8 compatibility.

When working on the [XT-IDE rev 3 design](/~glitch/2016/07/06/xt-ide-rev3), I decided not to include support for slot 8 on the card. It barely cleared the floppy drive in my XT, when installed in slot 8, and adding any length to the card to accomodate the open collector driver for `/CARDSEL` would've made it not fit at all. I asked about the need for slot 8, and very few people expressed interest. It was decided that a guide for "dead bug" modification, or a small daughterboard, would be designed for those needing slot 8 support.

Basically, we want to assert `/CARDSEL` any time the EEPROM or the IDE interface is read from. This means we should respond to both memory and I/O reads. For the EEPROM, this means we want to enable `/CARDSEL` when the EEPROM's `/RD` and `/CS` are both low. For the IDE interface, we'll enable `/CARDSEL` when `/CS_IDE` and the ISA `/IOR` (I/O read) lines are low:

{% image :file => 'cardsel.png', :alt_text => 'Slot 8 /CARDEL circuit' %}

I laid this mod circuit out as a small daughterboard. Rather than mounting the daughterboard and running all connections via jumper wires, it came to life as a console mod chip inspired board, with tabs for Vcc, GND, and the two EEPROM control signals. The board is intended to mount to the back of the XT-IDE, within the footprint of the EEPROM socket. Tabs provide both electrical connections and secure mechanical mounting:

{% image :file => 'gerber.png', :alt_text => 'Slot 8 Support Gerber' %}

All components are surface mount, and the board is single-sided. This means no worries about component leads or back-layer traces shorting against the XT-IDE board, even if the Slot 8 Support board is made at home, using toner transfer. I used the largest surface mount components possible -- standard SOIC for the 74LS33, and 1206 packages for the resistors and capacitors. This, along with the use of KiCad's "hand solder" footprints, should make the board as easy as possible for hobbyist hand assembly. For those unwilling or unable to try surface mount soldering, I'm also offering the modules pre-assembled.

## Assembling the Slot 8 Support Module

Assembly is straightforward: I installed the 74LS33 first, then the resistors, and finally the decoupling capacitor. First-run prototype boards were through [OSH Park](https://oshpark.com) and contained a couple issues. First, I didn't supply a solder mask layer for the back of the board, which results in everything getting coated in solder mask -- this means it gets in the through-holes! Second, I didn't have OSH Park score/route the ends of the tabs. It's not strictly necessary, but filing the ends off of the tabs (leaving a half-pad, pictured below) makes installation easier. Finally, the text was done as solder mask relief, and the label for R1 is cut by the gap from track to ground plane. None of these issues prevent the prototype boards from working, and two other hobbyists have successfully built and installed them.

I used my [Stickvise](http://store.hackaday.com/products/stickvise) to assemble the boards -- it's a neat little board holding tool that started as a hackaday.io project. Hack a Day liked it and now sells it in their store. Here's the module, ready for soldering, and with all components installed:

{% linked_images :files => ['bare.jpg', 'assembled.jpg'], :alt_texts => ['Slot 8 Support module', 'Components installed'] %}

I use Kester organic core solder and Superior #30 liquid flux for assembly, which are water clean products. Note that you *must* clean the board when using these products, as they will, over time, form resistive and/or capacitive shorts! Here's the module after washing with warm water and dish soap, and a run through the drying cabinet:

{% linked_image :file => 'cleaned.jpg', :alt_text => 'Slot 8 Support module after cleaning' %}

## Installation on the XT-IDE rev 3

As mentioned, this support board attached to the back of the XT-IDE, within the footpring of the EEPROM. To make installation easier, it helps to first remove solder from pins 14, 20, 22, and 28. You can use solder wick or a sucker, it's only necessary to remove solder to the point where the pad on the circuit board is flat -- you don't need to extract it from the through-hole:

{% linked_image :file => 'rev3_desoldered.jpg', :alt_text => 'XT-IDE rev 3 prepared' %}

Position the Slot 8 Support board with the capacitor toward the top of the XT-IDE rev 3 board. Solder down the four tabs, making sure the Slot 8 Support module is as close to the XT-IDE circuit board as possible. The solder should flow up the through-holes, connecting the tops of the XT-IDE's pads to the tops of the Slot 8 Support module's pads:

{% linked_image :file => 'mounted.jpg', :alt_text => 'Slot 8 Support mounted' %}

Next, install two jumper wires for the `/CARDSEL` output. This output is `TP1` on the Slot 8 Support module, and it should be jumpered to ISA pin `B8`. On production XT-IDE rev 3 boards, there's a through-hole pad labeled `TP1` which is intended for the Slot 8 Support module. If you want to be able to disable Slot 8 Support mode, run the jumper through an unused portion of `SW2`, the I/O ADDR switch. I used position 8. Here's the `/CARDSEL` jumpers installed on a prototype XT-IDE rev 3:

{% linked_image :file => 'cardsel_jumpers.jpg', :alt_text => '/CARDSEL jumpers installed' %}

With the `/CARDSEL` jumpers installed, make the jumper connections to `/ISA_IOR` and `/CS_IDE`. These signals connect to pads `TP2` and `TP3` on the Slot 8 Support board. It doesn't matter which signal goes to which pad. The following image shows the most convenient points of connection, with `/CS_IDE` coming from pin 19 of U6, and `/ISA_IOR` coming from a via just below and to the left of `TP2` on the Slot 8 Support module. It helps to scrape back the solder mask on the via -- this will be changed to another test point in future revisions:

{% linked_image :file => 'io_jumpers.jpg', :alt_text => 'I/O jumpers installed' %}

That's it! If you routed `/CARDSEL` through a switch, close the switch to enable Slot 8 support, and open the switch for use in regular slots. If you're interested in ordering a bare board, parts kit, or assembled module, please {% contact :text => 'use the contact form' %} to make your order. If you have an XT-IDE rev 2 card, here's the [installation writeup](/~glitch/2017/02/05/slot-8-xt-ide-rev2).

{% counter :text => 'XT Slot 8s Utilized' %}
