---
layout: post
title: VA Linux FullOn 2x2 Server Cleanup
topic: Cleaning up a VA Linux FullOn 2x2
category: vintage-misc
description: This server was the first "proper" server I owned. It was bought cheaply online, a leftover from the dot-com bubble. It sat unused for many years in my parents' basement, now it gets cleaned up and put back to work.
image: va_linux_server-icon.jpg
---

This VA Linux FullOn 2x2 rackmount server was the first "proper" server I owned: things before it were just consumer PCs. It's not the first rackmount computer I'd owned, that was probably the 4U AT chassis I'd bought in high school and put an AMD K6-II system into. The FullOn 2x2 started [shipping in late 1999](https://www.tech-insider.org/linux/research/1999/1109.htm), and prices started around $2900. This particular machine was purchased in 2005 or so, well past the point of having become obsolete. It was a leftover from the dot-com bubble, supposedly the result of a cleanout of some storage locker from a now-defunct business.

Specs of my VA Linux FullOn 2x2 as purchased, in 2005 or so:

* 2U chassis
* 4x SCSI SCA trays, front accessible, 1" or 1.6" drives
* 4x Compaq branded 18 GB SCA drives
* IDE CD-ROM drive
* 1.44 MB floppy drive
* Intel Server motherboard, i440GX+ chipset
* Dual Slot 1 Pentium III 550 MHz processors
* 1 GB of PC100 ECC SDRAM
* Onboard Adaptec Ultra LVD SCSI
* Onboard Intel 10/100 Ethernet
* Two available slots, risers required (but not provided)

I remember shipping costing more than the machine. No rack rails were included, but I only had a two-post rack anyway. This machine probably ran Slackware 9.x or 10. I'd switched over to Debian for a while, but that wasn't until we'd gotten satellite Internet at the farm -- `apt-get` being excruciating on a 56K dialup connection!

This machine was used primarily as a learning tool. I'd never experimented with "real" server hardware of my own. The four 18 GB SCSI drives allowed me to try different filesystems and software RAID levels. Having them in hot swap trays allowed quicker/easier OS experimentation, as the root disk could be changed out or pulled and set aside to avoid potential wrecking. It was multiprocessor, a novel thing to me at the time. It ended up being a testbed for things I didn't want possibly wrecking important machines, sort of a "staging" machine for home hacking.

### Rebuilding the Server

During summer 2022, I rediscovered the VA Linux server at my parents' house while we were rearranging part of the shop. It had been living in the basement, stored under some old camping gear. Being flat and sturdy, it was on the bottom, directly on the concrete floor. It acquired a fair bit of dirt and rust:

{% linked_images :files => ['dirty_front.jpg', 'dirty_back.jpg'], :alt_texts => ['VA Linux server, dirty, front', 'VA Linux server, dirty, back'] %}

The ports area was particularly rusty:

{% linked_image :file => 'dirty_ports.jpg', :alt_text => 'Dirty and rusted ports' %}

Here's the system information tag:

{% linked_image :file => 'system_tag.jpg', :alt_text => 'System information tag' %}

I decided to try and clean the old server up. Even if the motherboard was trashed from exposure to moisture, it was standard ATX and could be replaced. Opening it up, I discovered things weren't too bad on the inside:

{% linked_image :file => 'motherboard.jpg', :alt_text => 'VA Linux FullOn 2x2 motherboard' %}

The rusting on the chassis work must really have been from concrete damp, not a water leak or something. The insides were a bit dusty, but pretty clean for a server that hadn't been opened in so long! No mouse houses or anything. Next, the drives were pulled, and here we see the likely reason this server was taken out of use:

{% linked_image :file => 'bad_drive.jpg', :alt_text => 'Failed 18 GB SCSI SCA drive' %}

Two of the drive sleds had disks (one being the failed disk pictured above), two did not. I remember stealing drives from this system once it was no longer in use, one ended up in my [SGI O2](https://en.wikipedia.org/wiki/SGI_O2), which [Sark](http://www.retrohacker.com/) now has. Like the rest of the chassis, the trays were quite dirty. Fortunately, I'd saved the drive mounting screws and taped them inside.

{% linked_images :files => ['drive_sled_front.jpg', 'drive_sled_screw.jpg'], :alt_texts => ['Dirty drive sled, front', 'Drive mounting screws in a bag'] %}

The sleds look a lot like those used in Rackable Systems servers, I wonder if there's any connection?

Since the machine was getting a complete cleaning and going-through, everything was removed from the chassis, including the SCA backplane, CD-ROM/floppy mounting, motherboard, and power supply. Here's the chassis, completely empty:

{% linked_images :files => ['empty.jpg', 'empty_front.jpg'], :alt_texts => ['Empty chassis, motherboard area', 'Empty chassis, from the front'] %}

Everything was thoroughly cleaned, rust spots were removed with a stainless steel brush, sticker residue was removed, rusted fasteners were replaced. The original slot blanks were in bad shape and were replaced with some from inventory:

{% linked_image :file => 'slot_blanks.jpg', :alt_text => 'New slot blanks' %}

With the system cleaned, the power supply was opened and checked for failing capacitors, excessive corrosion, etc. Everything looked good, and the fans turned freely with no wobble or bad bearing feel. I started with reinstalling the motherboard and power supply, figuring I should check them out first before finishing reinstallation. Handily, someone stuck the Intel motherboard's info sticker inside the top cover:

{% linked_image :file => 'motherboard_layout.jpg', :alt_text => 'Motherboard layout sticker in top of chassis' %}

I always liked that Intel gave you stickers for the motherboard layout and port designations!

This server has its original pair of [Intel Pentium III 550 MHz processors](https://www.cpu-world.com/CPUs/Pentium-III/Intel-Pentium%20III%20550%20-%2080525PY550512%20(BX80525U550512).html), in [Slot 1](https://en.wikipedia.org/wiki/Slot_1) packaging. These are Katmai cores, with 512 KB L2 cache. The CPUs and memory were the final things installed:

{% linked_image :file => 'processors.jpg', :alt_text => 'Pair of 550 MHz Pentium III processors' %}

### Initial Bring-Up

After reassembly, the power supply was load tested with [Matt D'Asaro's AT supply tester](http://www.dasarodesigns.com/product/pc-at-ps2-power-supply-load-tester/) and an ATX -> AT adapter. Everything was fine, so the motherboard was plugged in, a monitor and keyboard attached, and powered up...nothing! No beeps, nothing on the display. Time for the POST card:

{% linked_image :file => 'post_card.jpg', :alt_text => 'Landmark KickStart 1 POST card' %}

I had to use my small Landmark KickStart 1, rather than one of the larger cards with more features, due to the case construction of the server. A riser would be required for an ISA card that extends to the normal full rearward length and/or has a bracket. The KickStart 1 showed signs of life, so I decided to try moving the RAM to the other two slots. Success:

{% linked_images :files => ['splashscreen.jpg', 'post_screen.jpg'], :alt_texts => ['Intel server board splashscreen', 'POST output'] %}

After that, [memtest86+](https://www.memtest.org/) was run on the system to verify memory. All systems 386 and newer get the memtest86+ treatment before any serious hacking begins...lessons learned from years of fighting infrequent memory issues in surplus equipment!

{% linked_image :file => 'memtest_start.jpg', :alt_text => 'memtest86+ running on 1 GB RAM' %}

That went well, so I purchased another pair of 512 MB PC100 registered ECC DIMMs from a popular online auction site. This would bring the system up to its maximum 2 GB configuration, which would've been huge and very expensive in 1999! The expanded system spent a night grinding away at memtest86+ and finished with no errors:

{% linked_image :file => 'memtest_done.jpg', :alt_text => 'memtest86+ showing 2 GB of good, tested RAM' %}

With that, this old server was ready to be used for...something!

### Racking the Server

I've never had rack rails for this server, it didn't come with them and I wouldn't have cared back then anyway as I had a two-post relay rack. It was mounted either using a rack shelf, or by placing it atop another server that was front mount capable. I'd apparently cut features off of the rack ears to allow securing it to the two-post rack:

{% linked_image :file => 'rack_ears.jpg', :alt_text => 'Cut rack ears' %}

For now, the system is sitting in the bottom of an equipment rack in the shop, mounted using an old set of APC UPS rails:

{% linked_image :file => 'racked.jpg', :alt_text => 'VA Linux server, racked up' %}

If anyone has a set of rails, or knows of a compatible set, {% contact %} and let me know! I'd like to be able to mount it properly, but this is fine for now.

I took the opportunity to hook up the Kill-a-Watt and figure out idle and loaded power consumption:

{% linked_images :files => ['power_idle.jpg', 'power_loaded.jpg'], :alt_texts => ['Power consumption at idle', 'Power consumption at load'] %}

Not exactly lightweight, given the performance-per-watt! Still, this is low enough that 24/7 operation would add less than $10 to the monthly power bill, so if the server ends up being really useful, I won't feel bad about leaving it on.

### Installing NetBSD

A dual 550 MHz Pentium III with 2 GB RAM isn't exactly going to run big modern workloads, but it can be useful for some applications. We could sort of use a dedicated machine on the "old stuff network" to act as a boot server, and that's the current role this machine is going to attempt to fill. It's the sort of role that could be filled by a small VM on one of our VM hosts, but we do try to keep the old stuff off of the hardware that's actually used for day-to-day business purposes.

I decided to install [NetBSD](http://www.netbsd.org/), since many of the things we'd like to netboot will be running NetBSD, and it's a fine operating system for the role anyway. That feels a little wrong, on a system produced by a company with "Linux" in the name, but only a little! A new 300 GB SCA drive was plugged into the first slot (lower right slot, which is SCSI ID 1), and [NetBSD/i386 9.3](http://wiki.netbsd.org/ports/i386/) was installed from a burned CD.

The install went as expected: everything was identified and supported, even the [SAF-TE](https://ask.adaptec.com/app/answers/detail/a_id/1921/~/what-does-ses-and-saf-te-mean-on-an-enclosure%3F) features of the SCSI backplane. The onboard Ethernet card is an Intel 10/100 chipset, which has excellent NetBSD support. The machine feels fairly quick from the command line, unlike running modern NetBSD on, say, a `sun4c` SPARC system.

Currently, the following services are being run on the "old stuff" network:

* ISC DHCPd with static leases for netbootable devices, BOOTP support enabled
* TFTP for boot loading and configuration transfer
* FTP for file transfer
* NFS for diskless operation

Here's the `dmesg` output for the system:

{% textblock :title => 'NetBSD/i386 9.3 on VA Linux FullOn 2x2' %}
[     1.000000] Copyright (c) 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003, 2004, 2005,
[     1.000000]     2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017,
[     1.000000]     2018, 2019, 2020, 2021, 2022
[     1.000000]     The NetBSD Foundation, Inc.  All rights reserved.
[     1.000000] Copyright (c) 1982, 1986, 1989, 1991, 1993
[     1.000000]     The Regents of the University of California.  All rights reserved.

[     1.000000] NetBSD 9.3 (GENERIC) #0: Thu Aug  4 15:30:37 UTC 2022
[     1.000000] 	mkrepro@mkrepro.NetBSD.org:/usr/src/sys/arch/i386/compile/GENERIC
[     1.000000] total memory = 2047 MB
[     1.000000] avail memory = 1993 MB
[     1.000000] rnd: seeded with 256 bits
[     1.000000] timecounter: Timecounters tick every 10.000 msec
[     1.000000] Kernelized RAIDframe activated
[     1.000000] running cgd selftest aes-xts-256 aes-xts-512 done
[     1.000000] timecounter: Timecounter "i8254" frequency 1193182 Hz quality 100
[     1.000003]                                                                 (                       )
[     1.000003] mainbus0 (root)
[     1.000003] ACPI: RSDP 0x00000000000F6AD0 000014 (v00 PTLTD )
[     1.000003] ACPI: RSDT 0x000000007FFFD7D7 00002C (v01 PTLTD    RSDT   06040001  LTP 00000000)
[     1.000003] ACPI: FACP 0x000000007FFFFB24 000074 (v01 Intel  L440GX   06040001 INT  000F4242)
[     1.000003] ACPI: DSDT 0x000000007FFFD803 002321 (v01 Intel  L440GX0  06040001 MSFT 0100000B)
[     1.000003] ACPI: FACS 0x000000007FFFFFC0 000040
[     1.000003] ACPI: APIC 0x000000007FFFFB98 000068 (v01 Intel  N440BX   06040001  TNI 00000000)
[     1.000003] ACPI: 1 ACPI AML tables successfully acquired and loaded
[     1.000003] ACPI: BIOS is too old (20000413). Set acpi_force_load to use.
[     1.000003] ACPI Error: Could not remove SCI handler (20190405/evmisc-312)
[     1.000003] mainbus0: Intel MP Specification (Version 1.4) (INTEL    Lancewood   )
[     1.000003] cpu0 at mainbus0 apid 1
[     1.000003] cpu0: Intel 686-class, 547MHz, id 0x673
[     1.000003] cpu0: package 0, core 0, smt 0
[     1.000003] cpu1 at mainbus0 apid 0
[     1.000003] cpu1: Intel 686-class, id 0x673
[     1.000003] cpu1: package 0, core 0, smt 0
[     1.000003] mpbios: bus 0 is type PCI   
[     1.000003] mpbios: bus 1 is type PCI   
[     1.000003] mpbios: bus 2 is type PCI   
[     1.000003] mpbios: bus 3 is type ISA   
[     1.000003] ioapic0 at mainbus0 apid 2: pa 0xfec00000, version 0x11, 24 pins
[     1.000003] pci0 at mainbus0 bus 0: configuration mode 1
[     1.000003] pci0: This pci host supports neither MSI nor MSI-X.
[     1.000003] pci0: i/o space, memory space enabled, rd/line, rd/mult, wr/inv ok
[     1.000003] pchb0 at pci0 dev 0 function 0: vendor 8086 product 71a0 (rev. 0x00)
[     1.000003] agp0 at pchb0: aperture at 0xf8000000, size 0x4000000
[     1.000003] ppb0 at pci0 dev 1 function 0: vendor 8086 product 71a1 (rev. 0x00)
[     1.000003] pci1 at ppb0 bus 1
[     1.000003] pci1: This pci host supports neither MSI nor MSI-X.
[     1.000003] pci1: i/o space, memory space enabled
[     1.000003] ppb1 at pci1 dev 15 function 0: vendor 1011 product 0023 (rev. 0x06)
[     1.000003] pci2 at ppb1 bus 2
[     1.000003] pci2: This pci host supports neither MSI nor MSI-X.
[     1.000003] pci2: i/o space, memory space enabled
[     1.000003] ahc1 at pci0 dev 12 function 0: Adaptec aic7896/97 Ultra2 SCSI adapter
[     1.000003] ahc1: interrupting at ioapic0 pin 19
[     1.000003] ahc1: aic7896/97: Ultra2 Wide Channel A, SCSI Id=7, 32/253 SCBs
[     1.000003] scsibus0 at ahc1: 16 targets, 8 luns per target
[     1.000003] ahc2 at pci0 dev 12 function 1: Adaptec aic7896/97 Ultra2 SCSI adapter
[     1.000003] ahc2: interrupting at ioapic0 pin 19
[     1.000003] ahc2: aic7896/97: Ultra2 Wide Channel B, SCSI Id=7, 32/253 SCBs
[     1.000003] scsibus1 at ahc2: 16 targets, 8 luns per target
[     1.000003] fxp0 at pci0 dev 14 function 0: i82559 Ethernet (rev. 0x08)
[     1.000003] fxp0: interrupting at ioapic0 pin 21
[     1.000003] fxp0: Ethernet address 00:d0:b7:65:ce:da
[     1.000003] inphy0 at fxp0 phy 1: i82555 10/100 media interface, rev. 4
[     1.000003] inphy0: 10baseT, 10baseT-FDX, 100baseTX, 100baseTX-FDX, auto
[     1.000003] pcib0 at pci0 dev 18 function 0: vendor 8086 product 7110 (rev. 0x02)
[     1.000003] piixide0 at pci0 dev 18 function 1: Intel 82371AB IDE controller (PIIX4) (rev. 0x01)
[     1.000003] piixide0: bus-master DMA support present
[     1.000003] piixide0: primary channel wired to compatibility mode
[     1.000003] piixide0: primary channel interrupting at ioapic0 pin 14
[     1.000003] atabus0 at piixide0 channel 0
[     1.000003] piixide0: secondary channel wired to compatibility mode
[     1.000003] piixide0: secondary channel interrupting at ioapic0 pin 15
[     1.000003] atabus1 at piixide0 channel 1
[     1.000003] uhci0 at pci0 dev 18 function 2: vendor 8086 product 7112 (rev. 0x01)
[     1.000003] uhci0: interrupting at ioapic0 pin 21
[     1.000003] usb0 at uhci0: USB revision 1.0
[     1.000003] piixpm0 at pci0 dev 18 function 3: vendor 8086 product 7113 (rev. 0x02)
[     1.000003] timecounter: Timecounter "piixpm0" frequency 3579545 Hz quality 900
[     1.024257] piixpm0: 24-bit timer
[     1.024257] piixpm0: interrupting at SMI, 
[     1.024257] iic0 at piixpm0 port 0: I2C bus
[     1.024257] vga0 at pci0 dev 20 function 0: vendor 1013 product 00bc (rev. 0x23)
[     1.024257] wsdisplay0 at vga0 kbdmux 1: console (80x25, vt100 emulation)
[     1.024257] wsmux1: connecting to wsdisplay0
[     1.024257] drm at vga0 not configured
[     1.024257] isa0 at pcib0
[     1.024257] lpt0 at isa0 port 0x378-0x37b irq 7
[     1.024257] com0 at isa0 port 0x3f8-0x3ff irq 4: ns16550a, working fifo
[     1.024257] com1 at isa0 port 0x2f8-0x2ff irq 3: ns16550a, working fifo
[     1.024257] pckbc0 at isa0 port 0x60-0x64
[     1.024257] attimer0 at isa0 port 0x40-0x43
[     1.024257] pcppi0 at isa0 port 0x61
[     1.024257] midi0 at pcppi0: PC speaker
[     1.024257] sysbeep0 at pcppi0
[     1.024257] isapnp0 at isa0 port 0x279
[     1.024257] fdc0 at isa0 port 0x3f0-0x3f7 irq 6 drq 2
[     1.024257] attimer0: attached to pcppi0
[     1.024257] isapnp0: no ISA Plug 'n Play devices found
[     1.024257] timecounter: Timecounter "clockinterrupt" frequency 100 Hz quality 0
[     1.840756] scsibus0: waiting 2 seconds for devices to settle...
[     1.840756] scsibus1: waiting 2 seconds for devices to settle...
[     1.840756] fd0 at fdc0 drive 0: 1.44MB, 80 cyl, 2 head, 18 sec
[     1.870769] uhub0 at usb0: NetBSD (0000) UHCI root hub (0000), class 9/0, rev 1.00/1.00, addr 1
[     1.870769] uhub0: 2 ports with 2 removable, self powered
[     1.870769] IPsec: Initialized Security Association Processing.
[     4.101682] sd0 at scsibus0 target 1 lun 0: <COMPAQ, BF3008B26C, HPB9> disk fixed
[     4.101682] sd0: 279 GB, 74340 cyl, 8 head, 985 sec, 512 bytes/sect x 585937500 sectors
[     4.141696] sd0: sync (25.00ns offset 63), 16-bit (80.000MB/s) transfers, tagged queueing
[     5.692331] ses0 at scsibus0 target 9 lun 0: <VA Linux, Fullon 2x2, 1.01> processor fixed
[     5.692331] ses0: SAF-TE Compliant Device
[     5.702336] ses0: async, 8-bit transfers
[    22.959398] atapibus0 at atabus0: 2 targets
[    22.959398] cd0 at atapibus0 drive 0: <CD-540E, , 1.0A> cdrom removable
[    22.969402] cd0: 32-bit data port
[    22.969402] cd0: drive supports PIO mode 4, DMA mode 2, Ultra-DMA mode 2 (Ultra/33)
[    22.969402] cd0(piixide0:0:0): using PIO mode 4, Ultra-DMA mode 2 (Ultra/33) (using DMA)
[    22.989411] boot device: sd0
[    22.989411] root on sd0a dumps on sd0b
[    22.999417] root file system type: ffs
[    22.999417] kern.module.path=/stand/i386/9.3/modules
[    37.615399] wsdisplay0: screen 1 added (80x25, vt100 emulation)
[    37.625408] wsdisplay0: screen 2 added (80x25, vt100 emulation)
[    37.635413] wsdisplay0: screen 3 added (80x25, vt100 emulation)
[    37.635413] wsdisplay0: screen 4 added (80x25, vt100 emulation)
{% endtextblock %}

I'm pretty happy with the NetBSD install. I will probably add at least one more 300 GB SCA drive and do a software `RAID1` mirrored pair: while the drives are "new," they're really more like NOS, and were made quite a few years ago! This machine won't be storing anything super important, but it's not worth the cost to deal with a downed machine from a single disk.

With four drive trays, this system can actually support quite a bit of storage, given that data will usually come and go over 100 mbit Ethernet at best. It will likely end up being the fileserver for the "old stuff" network, as well as the boot server.

{% counter :text => 'old servers rebuilt' %}
