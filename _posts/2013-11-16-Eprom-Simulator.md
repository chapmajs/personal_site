---
layout: post
title: Pragmatic Designs DBM-1 EPROM Simulator
topic: An EPROM simulator on a S-100 card
category: s100
description: I picked this board up from a popular online auction site with no documentation or cables. It's an EPROM simulator -- it can replace two 1K EPROMs or a single 2K EPROM with RAM for rapid development without the need to program/erase EPROMs. A handy board, but no one has information on it!
image: eprom-sim-icon.jpg
---

### UPDATE

[Herb Johnson](http://retrotechnology.com/) tipped me off to an eBay auction for a DBM-1 manual, which I've scanned and uploaded. [Here's the manual](http://filedump.glitchwrks.com/manuals/s100/dbm-1/dbm_manual.pdf) with a [separate schematic](http://filedump.glitchwrks.com/manuals/s100/dbm-1/dbm_schematic.pdf).

Part of the trouble in writing boot code, firmware, or other ROM routines for old systems is continually transferring changes to the code to the target system. Once you have a minimally functional system up and an operational serial link, this can be accomplished with a ROM monitor and XMODEM, but sometimes that's not an option. For example, I have several early embedded boards, essentially single-board computers, which use only a ROM or two and less than 1K of scratchpad RAM, with very little I/O available. For these systems, "development" consists of writing programs and assembling them on one system, then transferring them to my utility computer (it controls the EPROM burner), and burning ROMs for every revision.

I purchased this board to reduce the amount of headache in developing for these neat old boards. The DBM-1 provides 2K of dual-port static RAM on a S-100 card: the memory appears as regular RAM to the S-100 host on one port, and the other port is accessible via 24-pin headers on the top of the board. The headers correspond to the pinouts of 2708, Intel 2716, and Texas Instruments 2716 EPROMs. IDC connectors and ribbon cable jumpers can be used to connect the DBM-1 to target systems.

{% linked_image :file => 'front.jpg', :alt_text => 'DBM-1 S100 card' %}

I've found a few references to the DBM-1 through various online sources, mostly ads in various trade and user group magazines. From these, I've gleaned that the DBM-1 refers to "DeBug Memory," that it supports traps at specified memory addresses, and that it can be daisy-chained with another DBM-1 to provide 4K of EPROM simulation with the trap addresses extending through the range. No schematics or manuals, though, which I'd really like to find! If you have more information on this board, please let me know via the contact link above.

Fortunately, my DBM-1 came configured to operate as a standalone board and was in working condition when it arrived. I found it at address 0x8000 with all other memory cards removed. It occupies a single 2K block, and appears to be addressable on any 2K boundary. It functions as any other memory board on the S-100 bus, and as suggested by several of the ads I've found, it functions fine as regular RAM. My current switch settings are as below:

{% linked_image :file => 'switches.jpg', :alt_text => 'Switch settings' %}

It seems that the rightmost five positions of the address switch control which 2K block the DBM-1 will use. Open switch == 1, closed switch == 0. As of yet, I don't know what SW2 does, and I haven't experimented with changing its settings. The daisy chain connector is jumpered pin 1 to pin 3 with a wire wrap jumper, I'd imagine this is standard for single DBM-1 boards but would be removed if there were a second board in use.

My DBM-1 didn't come with cables for the useful part; that is, 24-pin 0.6" spacing IC headers on ribbon cable. Not many places carry the IDC headers, but [DigiKey has a few matches](http://www.digikey.com/product-search/en?pv88=29&FV=fff40016%2Cfff802f9%2C1140050%2C1680002&k=24+pin+idc&mnonly=0&newproducts=0&ColumnSort=0&page=1&quantity=0&ptm=0&fid=0&pageSize=25). The CW Industries part number prefix is `CWR-130-24`. I found a pair in an old parallel port print buffer and crimped them onto a longer cable. I'm not sure what the maximum cable length is, but the interface probably tolerates a fair bit of noise at the slow speeds one would usually access it.

A solder header and a few leads were connected to the "TRAP SIGNALS" socket of my board. Pin 4 terminates in a female socket labeled /SET while pin 5 goes to the cathode of a red LED. The anode of the LED connects to the regulated +5V supply of the DBM-1 through a resistor (value unknown -- it's in a bit of heat shrink tubing). The LED has never been illuminated in my use of the board, so I suspect TRAP functionality requires software setup.

