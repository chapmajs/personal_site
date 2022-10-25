---
layout: post
title: DEC Scholar 2400 BPS Modem
topic: 2400 BPS FORTH powered DEC modem
category: dec
description: DEC produced a series of modems intended for end users. This one is the Scholar DF 224-AA, a 2400 BPS non-Hayes modem with some interesting hardware inside.
image: dec_scholar-icon.jpg
---

I'd been on the lookout for a DEC Scholar modem for a while, either the base model or the Plus model, for use with some of my DEC terminals. These modems do show up periodically, but almost always without the power supply. In 2021, I ended up finding a pair that came with a power supply and the manuals:

{% linked_image :file => 'as_purchased.jpg', :alt_text => 'Pair of DEC Scholar modems, as purchased' %}

The power supply is a wall wart, but it's triple-voltage, providing +5V, +12V, and -12V, all DC. The connector is a six-pin Molex KK-156 (now KK-396). Here's a look at the front and back of the modem:

{% linked_images :files => ['front.jpg', 'back.jpg'], :alt_texts => ['DEC Scholar 2400, front', 'DEC Scholar 2400, back'] %}

From the outside, they appear just to be another 2400 BPS external modem, requiring a proprietary power supply, but otherwise unremarkable. The manual shows that these are not [Hayes command set](https://en.wikipedia.org/wiki/Hayes_command_set) modems, but use their own command structure. Many modems intended for end users included such interfaces, providing convenient functions such as phone books and interactive configuration. Presumably this was to provide a more "natural language" interface, rather than something that was easy to script.

Inside, we find something a little more interesting:

{% linked_image :file => 'open.jpg', :alt_text => 'DEC Scholar 2400, opened' %}

The modem section looks like it's basically a Rockwell R2424 2400 BPS full duplex modem set, which accounts for the two QUIP-64s on the left side of the image, as well as the 40-pin DIP near the top-left. But what's the other QUIP-64?

{% linked_image :file => 'r65f12.jpg', :alt_text => 'Rockwell R65F12 FORTH chip' %}

It's a Rockwell R65F12 FORTH chip! The R65F12 is a 6502 core with some extra instructions, 192 bytes of integrated SRAM, stack in zero page, several I/O ports, a serial channel, and Rockwell's [RSC FORTH](https://github.com/glitchwrks/rsc_forth) in mask ROM.

The EPROM in the lower center with the white label contains the application that runs on the FORTH chip. That ROM has been dumped and is available [here via FTP](ftp://filedump.glitchwrks.com/rom_dumps/TD24-J200-021.HEX), or [here via HTTP](http://filedump.glitchwrks.com/rom_dumps/TD24-J200-021.HEX). The checksum is `0xFD5F`. [TangentDelta](https://github.com/tangentdelta) is working on dissecting the ROM and analyzing its contents.

With the modem apart, I took measurements and made a power supply pinout diagram -- click for a larger version:

{% linked_image :file => 'power.jpg', :alt_text => 'DEC Scholar 2400 power supply connections' %}

From left to right, the pins are:

* Pin 6, +12V DC
* Pin 5, key pin (absent on the male connector, plugged on the female end)
* Pin 4, -12V DC
* Pin 3, +5V DC
* Pin 2, logic ground
* Pin 1, earth ground

Pins 1 and 2 are isolated when the transformer isn't plugged in, but basically connected when it is. Pin 2 connects directly to IC grounds, while pin 1 connects through a small resistance to things like the DB25F shell.

The connectors are Molex KK-156 (now KK-396) connectors, and the original power cable includes a molded housing/strain relief which encloses most of the KK-156 housing. The locking ramp should be up, toward the top of the modem.

Both modems do actually work:

{% linked_image :file => 'level29.jpg', :alt_text => 'VT320 connected to Level 29 BBS through DEC Scholar 2400' %}

Shown above is my DEC VT320 plugged into the DEC Scholar 2400 BPS modem connected at 2400 BPS to [Level 29 BBS(https://bbs.retrobattlestations.com/) over the phone line. We seemed to be having a lot of line noise today, notice the garbage at the login prompt! I disconnected and tried again, but line conditions were even worse.

The DEC Scholar can of course answer the line, but given the non-Hayes command set, it's probably less suited to automatic answering for e.g. \*NIX system dialins than other modems. It does make a pretty decent modem for terminals and computers running terminal emulators, though!

{% counter :text => 'modems running FORTH' %}
