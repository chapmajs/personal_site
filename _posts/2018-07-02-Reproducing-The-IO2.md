---
layout: post
title: Reproducing the Solid Sate Music IO-2
topic: Making new SSM IO-2 Boards
category: s100
description: The Solid State Music IO-2 is one of my favorite S-100 boards due to its versatility and flexibility. It is usually the board I grab when I want to quickly interface something to the S-100 bus. Vintage IO-2 boards are difficult to find and usually require rework to remove the previous owner's projects, so I decided to reproduce the IO-2 and make the boards available to others.
image: reproduction_io2-icon.jpg
---

### Reproduction Boards Now Available!

We have bare boards and parts kits available through our [Tindie store](https://www.tindie.com/stores/glitchwrks/):

* [Bare Reproduction Solid State Music IO-2 PC Board](https://www.tindie.com/products/glitchwrks/reproduction-solid-state-music-io-2-s-100-board/)
* [Solid State Music IO-2 Basic Parts Kit](https://www.tindie.com/products/glitchwrks/solid-state-music-io-2-basic-parts-kit/)

The Solid State Music IO-2 is one of my favorite S-100 boards: I've used it to build a [debug board](/2011/09/01/debug-board), a [1702A ROM/2101 RAM board](/2012/01/30/io2-rom-ram), and a [power-on jump board](/2013/04/17/power-on-jump), as well as other projects that I haven't documented online. Its versatility comes from the minimal address decoding and I/O laid out in copper -- the rest of the board is prototype space. It's usually the board I grab when I want to quickly interface a project to the S-100 bus. Unfortunately, vintage IO-2 boards are difficult to find. They're also usually populated with someone else's old project. While cleaning up a vintage board for reuse, I decided to fully strip it down and send it to [Mile High Test Services](http://www.mhtest.com/) for high resolution scanning. This allowed me to make reproductions of the board, here's a first run prototype, built up as a simple parallel I/O board:

{% linked_images :files => ['prototype_assembled.jpg', 'prototype_wiring.jpg'], :alt_texts => ['Prototype Reproduction IO-2', 'Prototype Wiring'] %}

It's hard to find a board house that will run circuit boards with colored FR-4, so I tried an experiment with this run: I created a solder mask layer that exposes all of the traces, covering only the spots that would've been bare FR-4 if I had run the boards with no solder mask. As seen above, I think the effect worked nicely. The board doesn't look exactly like an original, which I sort of count as a bonus anyway, since it would be harder to pass off as original by an unscrupulous seller. Here's a closeup of the SSM logo etched in the copper in the regulator area, even this part came out alright:

{% linked_image :file => 'prototype_logo.jpg', :alt_text => 'Prototype SSM Logo' %}

With the prototype design tested and confirmed, it was time to do a small production run. I knew several people from the [s100computers.com Google Group](https://groups.google.com/forum/?fromgroups=#!forum/s100computers), [Altair Computer Club](https://groups.yahoo.com/neo/groups/altaircomputerclub/info?v=1&t=directory&ch=web&pub=groups&sec=dir&slk=7), and various other groups would want reproduction boards, so I ordered a large enough run to make hard gold edge plating affordable. Hard gold is critical for long term durability of edge connectors, ENIG is not sufficient. Here are the results:

{% linked_images :files => ['production_board.jpg', 'production_board_back.jpg'], :alt_texts => ['Production IO-2 Front', 'Production IO-2 Back'] %}

As with all of my reproduction boards, this one has a note stating it's not vintage:

{% linked_image :file => 'production_note.jpg', :alt_text => 'Production Board Note' %}

The first one I built up became an 8-bit LED output register:

{% linked_images :files => ['chips_installed.jpg', 'wired_with_leds.jpg'], :alt_texts => ['Chips Installed', 'LED Register Wiring'] %}

The wiring was done with different colors from 25-pair telephone wire:

{% linked_image :file => 'wiring_closeup.jpg', :alt_text => 'Closeup of LED Register Wiring' %}

Just as with the prototypes, the production boards work fine! If you're interested in getting your own reproduction Solid State Music IO-2 board(s), see the links to our Tindie store at the top of this writeup. Bare boards and full parts kits are availble. If you'd like something custom built on an IO-2 board for your system, please {% contact %} and describe what you'd like built -- we're happy to build custom interfaces!

{% counter :text => 'S-100 interfaces hacked' %}
