---
layout: post
title: Cromemco CDOS Tools
topic: Bare-metal Bootstrapping CDOS 2.58
category: vintage-misc
description: With a Cromemco 4FDC and no boot media, getting a functional system was not entirely straightforward. Tools exist for bare-metal bootstrapping CDOS with a 16FDC, but they're incompatible with the 4FDC. Fortunately, there was enough existing work and experience in the area to hack together a solution!
image: cdos-icon.jpg
---

With a [functional Cromemco 4FDC](/~glitch/2014/01/30/cromemco-4fdc) and [a pair of Tandon TM-100 drives](/~glitch/2013/01/11/5-25-disk-box), it was time to to get CDOS running with the Cromemco Z2-D. This is a bit of a task when one does not have boot media as the 4FDC can't format disks on its own. It may be possible to restore CDOS disks using [Dave Dunfield's ImageDisk](http://www.classiccmp.org/dunfield/img/index.htm), since ImageDisk CDOS images do exist; however, disks for the 4FDC will need to be single-sided, single-density, which "modern" PC floppy controllers often have trouble with.

Dave Dunfield has also provided a [RDOS transfer utility](http://www.classiccmp.org/dunfield/img/index.htm) but it's geared toward the Cromemco 16FDC, which uses RDOS 2.x. The 4FDC uses RDOS 1.x which differs enough in command syntax as to be inoperable with the RT utility. RT allows one to format disks by loading an "in-memory" image of CDOS's INIT utility. This is simply a snapshot of the first 32K of RAM with INIT loaded in the TPA. This key bit of data makes bare-metal bootstrapping with no existing images possible.

The Test System
---------------

{:.center}
[![Test System](/images/vintage-misc/4fdc_utils/scaled/hacking.jpg)](/images/vintage-misc/4fdc_utils/hacking.jpg) [![Test System Closeup](/images/vintage-misc/4fdc_utils/scaled/test_system.jpg)](/images/vintage-misc/4fdc_utils/test_system.jpg)

- Morrow WunderBuss terminated 8-slot backplane
- Lambda triple-voltage adjustable power supply, set for +7V, +15V, -15V
- Cromemco ZPU @ 2 MHz
- Cromemco 4FDC
- 2x Tandon TM-100 5.25" floppy drives
- North Star 32K HRAM3 Dynamic RAM board (0x0000 - 0x7FFF)
- Processor Technology 16KRA 16K Dynamic RAM board (0x8000 - 0xBFFF)

Additionally, I used my [Dajen SCI](/~glitch/2011/11/03/dajen-sci) to load the in-memory CDOS image just to test that CDOS 2.58 was workable with a Cromemco 4FDC. Note that the RAM boards used do not support Cromemco-style bank switching -- that is OK for image restoration or using CDOS with 48K of RAM.

Formatting Disks
----------------

Since the 4FDC can't format disks by itself, CDOS must be loaded. Not so easy when one does not have a bootable CDOS disk! This is a key part of the RT utility -- an "in-memory" snapshot of CDOS with INIT loaded is used to format single-sided, single-density disks using the Cromemco controller itself. The image is 32K and occupies the lower half of system memory. Since RT didn't work with RDOS 1.x, I was unsure whether the in-memory image would work with the 4FDC at all. To find out, I plugged my Dajen SCI into the test system, adjusted the ZPU's jump location to 0xD000 (Dajen ROM base), and used the Dajen monitor to load the INIT image. This is possible since the Dajen SCI doesn't conflict with the 4FDC in memory or port allocation, and the SCI uses its own 256 bytes of RAM for stack, leaving the entire lower 32K editable. Here's the process:

- Convert the in-memory image from binary to ASCII-coded hex
- Boot the test system with the Dajen SCI installed
- Jump to 0xC000 and autobaud to the RDOS prompt
- Jump back to 0xD000 for the Dajen SCI
- Configure a terminal emulator with "ASCII paste" functionality (minicom, TeraTerm, et c.)
- Start editing memory at 0x0000 (`E 0000` with the Dajen monitor)
- Paste the converted in-memory image

The above procedure works because the Dajen monitor accepts a continuous string of hex characters as input once the initial edit command is given. The terminal emulator will likely require a pacing delay (150 ms was sufficient with the Dajen SCI at 9600 bps). Converting the image from binary to ASCII-coded hex will effectively double the number of bytes that have to travel over the serial link, so at 9600 bps with a 150 ms delay, the image takes more than 2.5 HOURS to transfer! Later work will include a high-speed, native binary image loader that doesn't require a separate monitor board.

Providing that all goes well, jump to location 0x0100 after the image is loaded. CDOS INIT should sign on using the 4FDC's console port. Format SEVERAL 5.25" disks as single-sided, single-density using the default INIT options otherwise. Once a disk has formatted, press the RESET switch and jump to 0x0100 again to format another. With formatted disks in hand, it should now be possible to use the RDOS disk commands (WD, RD, et c.) to manipulate sectors.

Writing CDOS Disk Images
------------------------

Once formatted disks are available, CDOS images can be written to them using RDOS. This is somewhat complicated since disk images for SSSD 5.25" media are 90KB and won't fit in base system memory. RT handles this by loading the image in pieces into a buffer and writing them out to disk. Following the same general idea, I developed a workflow to write images to disks using RDOS 1.x and the base 32K of system memory:

- Sign a disk drive on
- Seek track 0
- Load one track (18, 128 byte sectors) of data into memory starting at 0x0200
- Write the track to disk
- Seek to the next track
- Repeat

With RDOS, the commands would look a bit like this:

{% codeblock :language => 'nasm', :title => 'Cromemco RDOS Commands' %}
A;;;
S 0
SM 0200
;... here track 0 is "typed" in ...
WD 0200 0AFF 1
S 1
SM 0200
;... here track 1 is "typed" in ...
WD 0200 0AFF 1
{% endcodeblock %}

Following this workflow, it was easy to hack together a Perl script using the [Device::SerialPort](http://search.cpan.org/~cook/Device-SerialPort-1.04/SerialPort.pm) module. You can find the script [in my GitHub repositories](https://github.com/chapmajs/cromemco_utilities). This proof-of-concept worked, and now a bootable CDOS 2.58 5.25" SSSD disk has been created:

{:.center}
[![CDOS 2.58 Booted](/images/vintage-misc/4fdc_utils/scaled/cdos.jpg)](/images/vintage-misc/4fdc_utils/cdos.jpg)

Further Utility Development
---------------------------

The above utility requires Perl and relies on the Device::SerialPort module which assumes a UNIX-like environment. It has proven effective in an Arch Linux environment with a USB -> RS232 adapter. While it does work for me, it doesn't provide much in the way of error handling. Undoubtedly, the specific environmental requirements won't be something everyone has on hand. I'm working on developing a suite of utilities to allow fast, easy bare-metal bootstrapping of systems using the 4FDC. Check here for future updates!
