---
layout: post
title: IMSAI SIO-2 Compatibility with the Processor Tech 3P+S
topic: Making a 3P+S look like an IMSAI SIO-2
category: s100
description: The Processor Technology 3P+S is an early S-100 universal I/O board, providing both parallel and serial I/O. It is a versatile board, allowing the builder to select from many onboard options via jumpers. As shipped, it can be configured to be compatible with many other manufacturers' serial interfaces; however, making it compatible with the IMSAI SIO-2 requires some modification.
image: 3ps_imsai_sio-icon.jpg
---

I was recently asked to repair a [Processor Technology 3P+S](http://s100computers.com/Hardware%20Folder/Processor%20Technology/3P+S/3P+S.htm) for the [Vintage Computer Federation](http://vcfed.org) [Museum at InfoAge Science Center](http://vcfed.org/wp/vcf-museum/). This particular 3P+S was destined to be used in an IMSAI 8080. As such, in addition to repairing the board, it was to be configured to mimic the first channel of an [IMSAI SIO-2](http://s100computers.com/Hardware%20Folder/IMSAI/SIO/SIO.htm). While this is possible, it is not a configuration supported out of the box, and required some cut-and-jump fixes. Here's the repaired and modified board, note the small sticker (closeup in second image): this board was originally sold by Computer Mart of New Jersey:

{% linked_images :files => ['front.jpg', 'CMNJ_sticker.jpg'], :alt_texts => ['Completed 3P+S', 'Computer Mart of New Jersey Sticker'] %}

### Addressing Options Jumpering

Getting the board into the desired base configuration was the first step. Section III of the 3P+S manual covers options selection. We'll start with I/O port addressing options: the IMSAI SIO-2 consists of two Intel 8251 based serial channels. The first channel is typically used as a console port. Its data and control registers appear at `0x02` and `0x03`, respectively. To get the 3P+S into the general area, Area B option is jumpered left to center:

{% linked_image :file => 'areas_b_c_d.jpg', :alt_text => 'Areas B, C, and D' %}

Area B is in the middle of the above image. Jumpering from left to center places the 3P+S's two general purpose parallel ports at addresses `0x00` and `0x01`, the UART control port at `0x02`, and the UART data port at `0x03`. The UART control and data ports will be reversed from the IMSAI SIO-2 standard, but that's OK for now -- we'll fix it later.

Area A selects the base I/O address at which the 3P+S address block starts. To be compatible with the default IMSAI SIO-2 configuration, this needs to be `0x00`, or all jumpers from left to center in Area A:

{% linked_image :file => 'area_a.jpg', :alt_text => 'Area A Jumpers' %}

### UART Control Options Jumpering

Area C controls whether the UART configuration options are fixed or software-selectable. Fixed configuration is the most straightforward, and is more likely to result in a functional UART even if something else is broken in the system, which is very nice for debugging. Jumper from center to right to select static configuration, as seen below (Area C is to the right of Area B):

{% linked_image :file => 'areas_b_c_d.jpg', :alt_text => 'Areas B, C, and D' %}

For standard RS-232 operation, leave all jumpers in Area H disconnected. This will result in the UART being configured for 8N2 operation. This will still work with almost all situations in which the console terminal is expecting 8N1, since the extra stop bit is ignored by almost all hardware.

Area G contains the pads for the 3P+S UART status channel, which is labeled as Channel C in the manual. The UART flags can be jumpered in any order; however, to be compatible with the 8251 USART used in the IMSAI SIO-2, they do need to be in a certain order. The following table describes each connection:

{% codeblock :language => 'text', :title => '3P+S Area G Configuration' %}
Bit Function           3P+S Label     Jumpering
-------------------------------------------------------------------------------
0   Transmitter Ready  TBE            TBE to C0
1   Receiver Ready     RDA            RDA to C1
2   Transmitter Empty  TBE            TBE to C2
3   Parity Error       PE             PE  to C3
4   Overrun Error      OE             OE  to C4
5   Framing Error      FE             FE  to C5
6   BREAK Detect                      No Connection
7   Data Set Ready                    No Connection

Both Transmitter Ready and Transmitter Empty to be driven by TBE.

Note that the 3P+S has no default BREAK detection. DSR can be configured by the
user if required, consult the manual for details. Leaving C6 and C7 floating
will cause them to be read as 1 (TRUE) on Channel C.
{% endcodeblock %}

Below, you can see the jumpers in Area G as described in the table:

{% linked_image :file => 'status_jumpers.jpg', :alt_text => 'Area G Status Jumpers' %}

Bits 0 and 2 of the 8251 USART status register are effectively the same signal on the 3P+S and must be connected together. As seen above, this was accomplished with a small jumper between pads C0 and C2.

### Serial I/O Jumpering

For this project, I configured the 3P+S for RS-232 serial levels. The manual covers this and other options in detail, but we'll run through the jumpers for a three-wire connection with no handshake signals. First, connect the UART transmitted data output to one of the 1488 RS-232 transmitter inputs. I chose to use the first input. This is done in Area J:

{% linked_image :file => 'transmitter_area.jpg', :alt_text => 'Area J Jumpers' %}

Likewise, one of the 1489 RS-232 receivers should be jumpered to the UART's received data input. This is done in Area G, where the status jumpers are located. I used the first element of the 1489, which is present on pad 1. Jumper pad 1 to R IN:

{% linked_image :file => 'status_jumpers.jpg', :alt_text => 'Area G Status Jumpers' %}

When the 20 mA current loop transmitter is not in use, Area D should be jumpered from center to right. Area D is above IC 30 and IC 20 in the following picture:

{% linked_image :file => 'areas_b_c_d.jpg', :alt_text => 'Areas B, C, and D' %}

### Serial Bitrate Selection

Section III pages 7 and 8 cover bitrate selection. It's possible to control the 3P+S bitrate via software using the output portion of Channel C; however, static jumpering is simpler and once again is more likely to result in a functional serial channel even if something else in the system breaks. The following picture is of Area E, which contains the 12 bitrate selection jumpers:

{% linked_image :file => 'bitrate_jumpers.jpg', :alt_text => 'Areas E Bitrate Jumpers' %}

It is convenient to build up the bitrate selection area using machine socket pins: this allows the jumpers to be rearranged without desoldering. Especially on older boards, repeated desoldering will eventually result in lifted pads and/or broken vias.

With the standard options configured, it's time to move on to necessary modifications!

### Fixing the Bitrate Clock

The 3P+S is a fairly early S-100 board, from the days when almost all S-100 systems would've been built around an Intel 8080 running at 2 MHz. As such, the 3P+S uses the system clock as the clock input to the bitrate divider. This is fine if your system will only ever run a 2 MHz processor board, but will cause problems if a processor board with a different system clock speed is ever installed.

To fix this problem, the trace from S-100 pin 24 to IC 23 pin 15 can be cut and re-jumpered to S-100 pin 49. Pin 49 is a 2 MHz clock line, which will always be 2 MHz regardless of system clock frequency. This fix is easily accomplished on the front side of the 3P+S, as seen below:

{% linked_image :file => '2mhz_fix.jpg', :alt_text => '2 MHz Clock Fix' %}

The trace was cut near the edge connector pad for S-100 pin 24, and jumpered to S-100 pin 49 with a bit of 30 gauge Kynar wire. The wire is held in place with a few dabs of 5 minute two-part epoxy. Do note that this modification can potentially affect the XDAA and XDAB parallel handshake lines, since the J-K flip flop they control is clocked by the system clock. The 2 MHz clock on S-100 pin 49 is not guaranteed to have any phase relationship to the system clock.

At this point, the 3P+S should be functional enough for testing via the routines specified in the manual. This particular 3P+S had a dead DM8131 address comparator, resulting in the board failing to select during I/O operations to its address range. After the DM8131 was replaced, it was found that the 1488 RS-232 transmitter was dead. Once the 1488 was replaced, the 3P+S successfully passed a simple echo test!

### Fixing Control/Data Register Ordering

As mentioned in the Addressing Options Jumpering section, the 3P+S control and data ports are still reversed with respect to the IMSAI SIO-2. To correct this, address line `A0` should be inverted. The 3P+S uses four multiplexers to select which input port is addressed during an I/O read, so we must invert `A0` for all onboard functions. This has the result of flipping the ordering of parallel channels A and B, such that Channel B appears at `0x00` and Channel A appears at `0x01`. It's possible to achieve this by lifting pin 3 of IC 22 and jumpering it directly to pin 5 of IC 22, but this places additional load on the S-100 address lines. To avoid this, I installed a 74LS04 in the spare socket on the bottom-right corner of the 3P+S and used its first element to invert the `A0` signal:

{% linked_image :file => 'A0_inversion_fix.jpg', :alt_text => 'A0 Inversion Fix' %}

This modification is easily made by cutting the trace from S-100 bus pin 79 (`A0`) on the back of the board. There's a via located below the large +5V trace near IC 19 on the back of the board that makes for a convenient spot:

{% linked_image :file => 'A0_fix_via_closeup.jpg', :alt_text => 'A0 Fix, Cut Near Via' %}

Connect the trace going to S-100 pin 79 to the input of the inverter, and the output of the inverter to the via leading to pin 5 of IC 22:

{% linked_image :file => 'A0_fix_inverter_closeup.jpg', :alt_text => 'A0 Fix, Inverter Pads' %}

Note that the ground trace going up the middle of the spare pad area was cut: if not cut, the output of one inverter element will be tied to ground! There is also a small bridge from pin 7 to ground, since the spare pad area was for a 16-pin IC. This fix was again made with 30 gauge Kynar wire, held in place with a few drops of 5 minute two-part epoxy.

With this final modification, the 3P+S should now appear close enough to the first channel of an IMSAI SIO-2 for most software. If your software depends on hardware handshake lines you'll probably need to do additional work. I was able to swap out my IMSAI SIO-2 for this modified 3P+S and run my usual software without modification.

{% counter :text => 'SMBs back in service' %}
