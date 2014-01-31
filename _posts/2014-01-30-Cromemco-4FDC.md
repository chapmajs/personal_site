---
layout: post
title: Cromemco 4FDC Floppy Controller
topic: Notes on the Cromemco 4FDC Floppy Controller
category: s100
description: This one goes back to my first bit of S-100 hacking -- getting a Cromemco 4FDC up and running. Five years later, my 4FDC finally formats a floppy! Here we will discuss some of the tips, tricks, resources and myths about the lowly 4FDC.
image: eprom-sim-icon.jpg
---

In the summer of 2008, while working as an assistant in a warehouse full of electronics surplus, I discovered two Cromemco Z2-D enclosures. One of them contained a Morrow WunderBuss, a Cromemco ZPU, and an Ithaca Intersystems 64K Dynamic RAM board. In 2009, I returned to the facility connected to the warehouse with a new employer, the actual owner of the two Z2-D systems. Soon enough, the WunderBuss backplane was on my desk, lashed up to a Lambda bench supply, and I was in the process of getting the ZPU to boot from a 2716 on a protoboard.

After getting the ZPU reliably executing code from ROM, purchasing and repairing an [IMS 8K Static RAM board](http://s100computers.com/Hardware%20Folder/IMS/8K%20Static%20RAM/8K%20Static%20RAM.htm) from [Erik Klein](http://www.vintage-computer.com/)'s [Vintage Computer and Gaming Marketplace](http://marketplace.vintage-computer.com/), and writing enough ROM routines to fully test the setup, I purchased a Cromemco 4FDC from a popular online auction site. It was supposed to be "fully working," as with most things one purchases online...

4FDC Image Here

The 4FDC was Cromemco's first floppy controller, intended for their System 3 computer. It's a single-sided, single-density controller based around the Western Digital WD1771 disk controller. The board also includes a TMS5501 UART, which is used as the default console port, and a 2708 PROM socket for the boot ROM/monitor, RDOS. The 4FDC was designed to drive 8" Persci 277 voice coil drives, or Wangco Model 82 5.25" drives. RDOS, aside from providing standard monitor commands, can read and write tracks and sectors to any connected floppy drive. While it's an interesting and versatile board, it doesn't seem to be popular with the vintage computer crowd.

Don't Bother, Buy a 16FDC
-------------------------

Often, the suggestion found in historical Internet posts and active forums or mailing list discussion amounts to, "the 4FDC is primitive, give up and buy a 16FDC, or better yet, a 64FDC!" This may be valid advice, based on your needs and goals. If you're trying to maximize capacity or compatibility with other systems, the 4FDC probably isn't the way to go. Both later controllers are indeed superior to the humble 4FDC; however, they're also more expensive. Fortunately, the 4FDC isn't quite as esoteric as one might be led to believe. 

The following summarizes my findings regarding common wisdom about the oddities of the 4FDC:

Floppy Drives and Data Separators
---------------------------------

One of the most popular arguments against the 4FDC is incompatibility with standard floppy drives. There's some truth in this: the 4FDC was indeed designed for operation with 8" Persci 277 voice coil drives. Persci drives are expensive and unreliable, so they're less than optimal for a practical, useable system. The 4FDC manual specifies Wangco Model 82 5.25" drives as an option as well. This particular model is somewhat uncommon, and certainly more expensive than a Shugart-compatible 5.25" drive. It's commonly believed that these particular drives are required because the 4FDC requires a drive with an external data separator since the WD1771 doesn't include a data separator...well, not quite!

The Western Digital WD1771 disk controller does in fact include a FM (single-density) data separator on-chip. Being an early design, the data separator is not particularly high-performance. As a result, Cromemco decided to use the data separator present on Persci 277 drives. This turns out to be less of an issue than expected, as many early 8" floppy drives (the Shugart SA-800, for example) include a FM data separator. But that still leaves the requirement for 5.25" drives that include a data separator...right?

This one is flat out incorrect -- while the WD1771's onboard data separator is indeed disabled for 8" disk access, the *MINI/MAXI* select line enables it for 5.25" disks. Any standard 40-track 5.25" floppy drive will indeed work perfectly with the 4FDC, provided that it is strapped appropriately. I'm currently using [a pair of Tandon TM-100 drives](http://www.glitchwrks.com/2013/01/11/5.25-Disk-Box) with my 4FDC, which successfully formats, reads, writes and boots floppy disks. Perhaps the lower data rate of the 5.25" drives makes the onboard WD1771 data separator acceptable; in any case, it seems to work.

->[![DBM-1 S100 card](/images/s100/eprom_sim/scaled/front.jpg)](/images/s100/eprom_sim/front.jpg)<-

