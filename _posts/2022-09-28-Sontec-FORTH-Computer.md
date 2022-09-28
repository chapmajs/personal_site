---
layout: post
title: Sontec FORTH Computer
topic: Rockwell R6500 series FORTH computers
category: vintage-misc
description: ITI Audio/Sontec is known for analog audio mastering equipment. During the 1980s, they designed and prototyped a series of FORTH computers intended to control a mastering product which was eventually cancelled. This writeup takes a look at some of the extant prototypes.
image: sontec_forth_computer-icon.jpg
---

ITI Audio/Sontec is well-known for world class analog audio mastering equipment, but was also responsible for the design of a FORTH computer in the 1980s. In addition to his background in analog electronics, Burgess is no stranger to digital electronics, including the hardware and software sides of computers. ITI/Sontec's first computer was an [Ohio Scientific Challenger III](http://www.glitchwrks.com/2019/07/30/470-repair-and-second-c3), kit-built and run without a case its whole life. The company developed the [Compudisk](https://en.wikipedia.org/wiki/Burgess_Macneal#Sontec_Compudisk), an advanced record lathe control system which was microprocessor based and used the Zilog Z80. ITI/Sontec also developed their own computer system for use with a product that never came to be: a single-board computer that ran [FORTH](https://en.wikipedia.org/wiki/Forth_(programming_language)) on a Rockwell R6500 series chip! 

### Functional Prototype FORTH Computer

I found one of the prototypes while working there in college:

{% linked_images :files => ['front.jpg', 'back.jpg'], :alt_texts => ['Sontec FORTH computer, front', 'Sontec FORTH computer, back'] %}

In 2019, while doing some new prototyping work for ITI/Sontec, I re-discovered the above FORTH computer in a bin on one of the stock shelves. Burgess had briefly talked about it when I worked there during college. He'd made extensive use of FORTH on the Ohio Scientific, using it for managing their inventory, writing his own word processor, etc. It seemed to him the natural choice for a computerized automation system for a new product, which unfortunately never came to market. This board uses the Rockwell R6501AQ single-chip microcontroller, which is visible with the bodge board removed:

{% linked_image :file => 'cpu.jpg', :alt_text => 'Rockwell R6501AQ processor' %}

The Rockwell R6501AQ is a 6502 processor core with some modifications:

* Four new bit manipulation instructions
* Integrated 192 bytes of static RAM
* Stack on zero page instead of page one
* Four 8-bit parallel I/O ports
* One serial port
* Two counters/timers

Rockwell provided kernel and development ROMs to allow the R6500 series CPUs to run Rockwell RSC-FORTH essentially out of the box. Their RSC-FORTH user's manual includes details on implementing floppy disk mass storage, and the Sontec FORTH computer was set up for that.

As seen in the first set of pictures, there's a bodge board plugged into a 20-pin DIP socket. Here's a closer look:

{% linked_images :files => ['bodge_front.jpg', 'bodge_back.jpg'], :alt_texts => ['Sontec FORTH computer bodge board, front', 'Sontec FORTH computer bodge board, back'] %}

I'm pretty sure that this bodge board was intended to be a development aid for a PAL or GAL, though Burgess says he has no memory of planning on using one. A GAL16V8 would pretty much drop in, with one bodge wire on the back of the board to an otherwise uncommitted pin.

This prototype does actually function, and runs Rockwell's RSC-FORTH kernel and development ROMs, which have been consolidated from two mask ROMs to a single UV EPROM. Cleaning, testing, and repair will be discussed in a future writeup.

### Earlier Prototypes

Some time in late 2019, I found more remnants from the development process that resulted in the above prototype FORTH computer. The schematics for these boards appear to be lost, but we do have some of the circuit board artwork -- on transparency film, of course! Burgess says that the above working prototype was the most complicated AutoCAD layout he'd done to date, and was one of the last things he did before switching to Protel (now Altium). Apparently the plot for the above prototype hung on the wall at a circuit board manufacturer's office in Charlottesville, VA for some time, as an example of what could be done with AutoCAD!

### Dynamic Designs Prototype

I believe this prototype was produced from artwork provided by Rockwell in one of their manuals, but I'm having a hard time finding it in the PDF copies I currently have. It may be from something I haven't digitized yet. Anyhow, here it is:

{% linked_images :files => ['dynamic_designs_front.jpg', 'dynamic_designs_back.jpg'], :alt_texts => ['Dynamic Designs prototype, front', 'Dynamic Designs prototype, back'] %}

Pictured are an assembled prototype and a bare board. The bare board has not been fully cut to size: at that time, ITI/Sontec ordered prototypes in large, consolidated panels, like most folks in the industry. Panels were then sheared to size with a 48-inch foot operated metal shear. Here's a closeup of the Dynamic Designs logo:

{% linked_image :file => 'dynamic_designs_logo.jpg', :alt_text => 'Dynamic Designs logo' %}

We're speculating this board is actually an "emulator" board, intended to allow easy development for a Rockwell 40-pin microcontroller. It's unclear whether it would've been used with a R6501Q or R6500/1EQ.

### First Sontec FORTH Computer Prototype

This board appears to be the first Sontec-designed FORTH computer circuit board:

{% linked_images :files => ['first_forth_front.jpg', 'first_forth_back.jpg'], :alt_texts => ['First Sontec FORTH computer, front', 'First Sontec FORTH computer, back'] %}

It obviously shares some characteristics with the Dynamic Designs prototype, but has been extended. There's a `forth 6501Q` text in the bottom right corner, indicating the intended processor type. The three larger DIP sockets are for static RAM and two Rockwell RSC-FORTH mask ROMs. Interfacing is still through a 40-pin DIP socket, perhaps indicating that this board was intended to do development work for a mask programmed Rockwell FORTH chip.

### Rockwell Chips

Speaking of FORTH chips, this assortment was found in the box as well:

{% linked_image :file => 'rockwell_chips.jpg', :alt_text => 'Rockwell FORTH chips' %}

At the top, we have a Rockwell R65F11 (40-pin DIP) and R65F12 (64-pin QUIP). These are FORTH based microcomputers, and include the FORTH kernel in mask ROM, internal to the processor. These chips are essentially the same thing, except the R65F12 has more I/O lines -- five 8-bit I/O ports rather than the two 8-bit I/O ports of the R65F11.

Below the FORTH processors, on the left, are the two chips required for running RSC-FORTH Configuration 2 on the R6501Q processor. These were likely used with the first Sontec FORTH computer prototype above, and support a "small" configuration FORTH development environment. This configuration allows more of the R6501Q's I/O lines to be used in the chip's intended application.

To the right of the Configuration 2 ROMs are the RSC-FORTH Configuration 3 ROMs. These ROMs use the full configuration on the R6501Q, which uses some of the I/O pins as address lines, allowing access to the full 64K memory space of the 6502 core.

The RSC-FORTH ROMs have been dumped and we've made them available [here, on Github](https://github.com/glitchwrks/rsc_forth). The repository also includes datasheets relevant to these chips. A set of patches is also included, which allows the ROMs to run on our [R65X1Q single-board computer](https://www.tindie.com/products/glitchwrks/glitch-works-r6501qr6511q-single-board-computer/).

### Panel Interface Board

This board was found in the bin as well:

{% linked_images :files => ['panel_interface_front.jpg', 'panel_interface_back.jpg'], :alt_texts => ['Panel interface, front', 'Panel interface, back'] %}

The board still has a strung tag attached, showing it was assembled in September 1984. It's unclear which prototype FORTH computer this board was meant to talk to.

Here's a prototype of the front panel this was intended to interface with:

{% linked_images :files => ['panel_board_front.jpg', 'panel_board_back.jpg'], :alt_texts => ['Sontec front panel prototype, front', 'Sontec front panel prototype, back'] %}

Quite the thing! I've not made an attempt to get this front panel interfaced to any of the FORTH computers. Burgess says he's pretty sure parts were scavenged off of it after the product for which it was intended was canceled. Quite the mess of blue wire on the back.

### Interface Boards

The following three boards were found separate from the bin that contained the FORTH computer prototypes, and appear to be interfaces that would've plugged into a backplane, controlled by the FORTH computer:

{% linked_images :files => ['interfaces_front.jpg', 'interfaces_back.jpg'], :alt_texts => ['Interface boards, front', 'Interface boards, back'] %}

I'm pretty sure the middle board is an earlier prototype of the leftmost board. These appear to be a serial interface, presumably to talk to other equipment which was to be interfaced with the canceled product these were designed for.

There was also a protoboard in with the three interfaces pictured above:

{% linked_images :files => ['protoboard_front.jpg', 'protoboard_back.jpg'], :alt_texts => ['Protoboard, front', 'Protoboard, back'] %}

It's my guess that this protoboard contains a circuit meant to program PALs or GALs, for use in place of the bodge board currently installed on the working Sontec FORTH computer prototype. There was a 20-pin low insertion force test socket in the bin as well, which would've made sense for a board intended to program parts.

### Revision B Sontec FORTH Computer

Finally, there was a second revision of the working Sontec FORTH computer prototype:

{% linked_images :files => ['blank_revb.jpg', 'revb_closeup.jpg'], :alt_texts => ['Revision B Sontec FORTH computer, blank board', 'Revision letter closeup'] %}

This board is unlikely to be assembled: we do have the artwork for it, but the schematics have been lost. The Rev A prototype works, so building this one up wouldn't get more functionality out of what we've got. This prototype is also not plated through; that is, the holes that would normally be feedthroughs are not connected. This was a reality for small-run prototypes in the old days, but makes for a painful assembly process when using sockets. If I were to try and assemble another Sontec FORTH computer, it'd probably be from a new layout on newly run boards.

{% counter :text => 'FORTH computers fixed' %}
