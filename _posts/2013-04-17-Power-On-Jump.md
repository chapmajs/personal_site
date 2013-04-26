---
layout: post
title: Power On Jump Board for the S-100 Bus
topic: Building a standalone power-on jump circuit
category: s100
description: One of my S-100 systems uses a CPU board that doesn't have a power-on jump function. The ROM board doesn't have it either. It's a turnkey system with no front panel, so I had to come up with a way to get the CPU to jump into the ROM board's address space without starting the ROMs at 0x0000.
image: poj-icon.jpg
---

Power-on jump is one of those features I've gotten used to having in S-100 systems. Usually it's present either on the CPU card or whichever board provides the ROM monitor or bootstrap code. This allows the system to be configured with RAM at 0x0000 during normal use, but have the bootstrap code switched in on power-on reset and/or system reset. While it's a nice feature with front panel systems like the IMSAI, it's absolutely crucial on turnkey systems with no front panel, unless you can handle ROM at 0x0000.

Power-on jump can be accomplished in several ways, depending on the hardware and processor architecture. Processors like the 6502 or 6800 are hardwired to look for a reset vector in high memory and often just use banked memory to switch out ROMs after the bootstrap process is complete. The 8080 and compatibles (8085, Z80, NSC800, et c.) have no such feature and begin execution at 0x0000 upon restart. For some systems, there's no problem with placing ROM right at 0x0000, either permanently or in a switched configuration.

So what's the problem with ROM at 0x0000 anyway? Well, if it's permanently mapped, some software (CP/M, for example) can't be loaded as they depend on RAM at 0x0000. You're also stuck with the contents of ROM for interrupt/restart routines. If it's switchable, you can't use common code such as console or I/O driver routines from ROM with software that requires RAM at 0x0000. You potentially end up with code duplication and an overall less flexible system.

[NOP Sled](http://en.wikipedia.org/wiki/NOP_slide)

->[![24V Relays](/images/general/relay_board/scaled/relays.jpg)](/images/general/relay_board/relays.jpg)<-
