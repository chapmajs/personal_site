---
layout: post
title: S-100 Computer Products 32K Static RAM
topic: S-100 Computer Products 32K Static RAM
category: s100
description: Fixing up a S-100 Computer Products 32K Static RAM board. This board uses 2114 type 1K x 4 SRAMs and after repair was running *very* hot. 5V supply was modified, and addressing was changed to system-specific needs.
image: s100_products_32k_sram_icon.jpg
---

This is the S-100 Computer Products 32K Static RAM board:

{% linked_images :files => ['front.jpg', 'back.jpg'], :alt_texts => ['Finished S-100 Computer Products 32K Static RAM, from the front.', 'From the back.'] %}

I've had this board for quite a few years, but never got it working reliably. Fortunately, it did [come with the manual](http://filedump.glitchwrks.com/manuals/s100/s100_computer_products_32k_sram.pdf). It's a pretty basic 32K SRAM board, notable only in that they managed to pack a *bunch* of 2114 1K x 4 SRAMs onto a single S-100 card! The main problem that ended up in the board being shelved turned out to be mostly caused by bad sockets in the decode/buffering circuitry. Fortunately, sockets in the RAM array were higher quality gold-plated dual wipe sockets, so I didn't have to resocket the whole board. Two of the SRAM sockets were damaged, and required replacement.

Aside from bad sockets, this board proved a little difficult/confusing to troubleshoot: *there is enough parasitic capacitance that empty sockets will sometimes, sort of hold data!* I'd started with the board minimally loaded with a single pair of 2114 SRAMs and was having all sorts of issues getting the test system to come up. The TDL Zapple monitor was being used for debugging, as the system this board is destined for uses a TDL/CDL SMB-II. Zapple sizes memory non-destructively by `XOR`ing the contents, writing it back, `XOR`ing again, and writing again. The S-100 Computer Products 32K SRAM board appeared to be actually returning valid data during the sizing process, causing Zapple to locate its stack and variables in RAM that didn't really exist!

During minimal testing, the regulator on the board got pretty hot. Sixty-four 2114 type SRAMs, even the low-power variants, are a big load for a single regulator. The original design uses a PNP power transistor and a wirewound resistor to boost the capacity of a regular old 7805 type regulator, but heatsinking was entirely insufficient. This is the original regulator hardware and heatsink:

{% linked_image :file => 'original_regulator.jpg', :alt_text => 'Original regulator hardware' %}

The small heatsink, 7805, and PNP transistor were replaced with a single uA323 5V regulator in a TO-3 package. This regulator is specced for 3A service, which this board is pushing. The datasheet for the particular regulator used says it won't shut down until at minimum 4A draw, as long as the heat can be dissipated. I scavenged a large Wakefield cast aluminum heatsink from a dead DEC power supply, which can be seen in the first picture at the top of this page. Holes were drilled through the S-100 board and some power traces cut and scraped back. Ground pour under the regulator was also scraped back to prevent shorts. Here's a picture of the back after the regulator rework:

{% linked_image :file => 'regulator_back.jpg', :alt_text => 'Replacement regulator rework' %}

The Wakefield heatsink is rated for around 10W dissipation without forced air cooling. With the board up on a S-100 extender, the heatsink gets hot, but not so hot that it can't be safely touched, which was the case with the previous arrangement. With even minimal airflow, it is more than adequate.

The board was further modified to change its address decode: this board was being fixed up for an IMSAI that already contained 16K of SRAM adressed from `0x0000` - `0x3FFF`. The IMSAI's owner did not have a manual for the 16K card and didn't want to re-address it. A few cuts and jumps, and a piggybacked 74ACT00 changed the 32K board's addressing to `0x4000` - `0xBFFF`.

{% linked_image :file => 'piggyback_chip.jpg', :alt_text => 'Piggyback 74ACT00 and modifications' %}

{% counter :text => 'RAM boards repaired' %}
