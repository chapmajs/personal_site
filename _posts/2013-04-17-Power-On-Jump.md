---
layout: post
title: Power On Jump Board for the S-100 Bus
topic: Building a standalone power-on jump circuit
category: s100
description: One of my S-100 systems uses a CPU board that doesn't have a power-on jump function. The ROM board doesn't have it either. It's a turnkey system with no front panel, so I had to come up with a way to get the CPU to jump into the ROM board's address space without starting the ROMs at 0x0000.
image: jump_icon.jpg
---

Power-on jump is one of those features I've gotten used to having in S-100 systems. Usually it's present either on the CPU card or whichever board provides the ROM monitor or bootstrap code. This allows the system to be configured with RAM at 0x0000 during normal use, but have the bootstrap code switched in on power-on reset and/or system reset. While it's a nice feature with front panel systems like the IMSAI, it's absolutely crucial on turnkey systems with no front panel, unless you can handle ROM at 0x0000.

Power-on jump can be accomplished in several ways, depending on the hardware and processor architecture. Processors like the 6502 or 6800 are hardwired to look for a reset vector in high memory and often just use banked memory to switch out ROMs after the bootstrap process is complete. The 8080 and compatibles (8085, Z80, NSC800, et c.) have no such feature and begin execution at 0x0000 upon restart. For some systems, there's no problem with placing ROM right at 0x0000, either permanently or in a switched configuration.

So what's the problem with ROM at 0x0000 anyway? Well, if it's permanently mapped, some software (CP/M, for example) can't be loaded as RAM is expected at 0x0000. You're also stuck with the contents of ROM for interrupt/restart routines. If it's switchable, you can't use common code such as console or I/O driver routines from ROM with software that requires RAM at 0x0000. You potentially end up with code duplication and an overall less flexible system.

Implementing Power-On Jump
--------------------------

Fortunately, the S-100 bus allows one to construct a power-on jump circuit on a board external to both the CPU and ROM circuits. This is accomplished through synchronizing instruction jams on pSYNC and using the /PHANTOM line to disable memory present at 0x0000 after the jump circuit is activated. Of course, I chose to build the circuit on none other than the Solid State Music IO-2. While I've used the IO-2 to build both a [debug board](/2011/09/01/Debug-Board/) and a [ROM/RAM board](/2012/01/30/IO2-ROM-RAM/), this function will only utilize prototype space (don't worry, the actual I/O function of the board will be used in a later project!).

There are a few common/popular ways to achieve power-on jump with 8080-compatible processors. Many of them depend on integration with either the CPU or ROM board (switching the ROM address, for instance) and aren't applicable to this situation unless the ROM board is to be modified extensively. Of the common methods, instruction jamming and [NOP sleds](http://en.wikipedia.org/wiki/NOP_slide) seemed the most appealing. I chose to use a method of instruction jamming based on the power-on jump circuit of the [Cromemco ZPU](http://www.s100computers.com/Hardware%20Folder/Cromemco/Z80/ZPU.htm), adapted for use on an external board. This would require fewer components when using "old" TTL, which was a goal for this project. Here's the circuit I came up with:

Insert schematic scan here

When system /PRESET goes low, the 74LS164 shift register gets reset, forcing all outputs to off. Its inputs are tied to +5V, and the shift register is clocked by pSYNC, meaning that every 8080 data fetch shifts a logic 1 into the shift register. Output 4 of the shift register both enables the output buffers that drive the Data In bus and the open-collector /PHANTOM driver, which prevents other memory boards from responding while the circuit is active. This output remains low for three data fetches (an 8080 JMP instruction is 3 bytes long), going high on the fourth data fetch, which should be our bootstrap code. Output 3 selects a set of inputs from a 74LS157 quad 2-to-1 multiplexer.

The three lowest outputs of the shift register can be used to select three separate byte patterns to jam onto the data bus. There are several ways to accomplish this, including the use of ROM, but the Cromemco ZPU achieves the necessary functionality with combinational logic. I chose to replicate that design in my circuit. The goal is to force `JMP 0x?000` onto the bus, or `C2 00 ?0` where ? is the nybble selected via DIP switch:

* Since this circuit jumps on 4K boundaries, bits 2 and 3 in all three bytes will always be zero and can be tied to ground at the 74LS367
* Bits 0 and 1 are only true for the first byte, and can be controlled with an inverter from shift register output 1
* The upper nybble is either 0xC, 0 or the state of the four-position DIP switch

The last point is accomplished with the 74LS157 multiplexer. Its select pin is tied to the third output of the shift register, so the "A" set of inputs is selected until the third pSYNC pulse. The inverter that provides the low nybble of the first byte is used to provide the high nybble as well. When the third pSYNC pulse arrives, the select pin is set true and the state of the 4-position DIP switch is transferred to the upper nybble of the data bus. On the next clock, the fourth output of the shift register goes high, disabling the data bus buffer until the next reset.

Board Construction
------------------

->[![Front of boards](/images/s100/jump_board/scaled/original_front.jpg)](/images/s100/jump_board/original_front.jpg) [![Back of boards](/images/s100/jump_board/scaled/original_back.jpg)](/images/s100/jump_board/original_back.jpg)<-

I purchased two IO-2 boards from [Herb Johnson](http://retrotechnology.com/) a while back, one in basically unused condition, the other...well, fairly hacked up. Before starting, everything that wasn't a socket was stripped from the board. It took several applications of concentrated dish soap and 91% isopropyl alcohol to get the board to the point at which it could be repopulated. Here's how it looked after its cleaning:

->[![Stripped and cleaned board](/images/s100/jump_board/scaled/stripped_down.jpg)](/images/s100/jump_board/stripped_down.jpg) [![Solid State Music markings](/images/s100/jump_board/scaled/old_ssm_logo.jpg)](/images/s100/jump_board/old_ssm_logo.jpg)<-

Part of the reason I went through the trouble of cleaning this board is that it appears to be older than the other IO-2 boards I have. It includes an etch in the regulator area that doesn't appear on the other IO-2s, there's no solder mask, and the only other markings are "BY M.T. WRIGHT" and "IO-2". In any case, it was time to start rebuilding, which of course starts with power regulation. The jump circuit requires only +5V, so only the 7805 regulator is populated:

->[![Regulator and capacitors](/images/s100/jump_board/scaled/regulator.jpg)](/images/s100/jump_board/regulator.jpg)<-

The rest of the board is populated according to the schematic. I was able to reuse the existing sockets with the addition of one more 16-pin socket for a 74LS367. A 2N2222 transistor was used for an open-collector /PHANTOM driver to avoid the inclusion of another DIP device when only a single driver was required. All wiring was done using 30 gauge Kynar-insulated wrapping wire. The connection between the shift register and the enable pins of the 74LS367 drivers was made with two machine pin sockets and a jumper to allow easy disabling of power-on-jump.

->[![Finished jump circuit](/images/s100/jump_board/scaled/circuit_closeup.jpg)](/images/s100/jump_board/circuit_closeup.jpg) [![Finished wiring](/images/s100/jump_board/scaled/back.jpg)](/images/s100/jump_board/back.jpg)<-

Success! The board disables my system RAM at 0x0000 and jams opcodes onto the data bus! If you have a system with a front panel, you can single-step after a reset and observe the opcodes pushed onto the data bus. While observing the last byte in the 3-byte JMP instruction, the DIP switches can be changed with the results showing up immediately on the data bus. So far, I've tested this circuit with 2 MHz 8080 CPU boards as well as 4 MHz Z80 CPU boards with no problems. Combinational logic should be fast enough for systems above 4 MHz as well. Just be sure your processor board supplies pSYNC and that your RAM board(s) respond to the /PHANTOM line.
