---
layout: post
title: North Star Horizon Restoration
topic: Cleaning up the North Star Horizon
category: s100
description: This North Star Horizon arrived with a larger lot of equipment. It had clearly been a mouse house at some point in its life, but the bulk of the mouse mess had been removed, hiding the full extent of the damage. Repair involved replacing many sockets and even some S-100 slots.
image: horizon_restore_icon.jpg
---

My North Star Horizon came with a larger lot of vintage computer equipment that all seemed to be pretty well cared for. The Horizon proved to be an exception: it had housed a mouse at some point, but the mouse nest had been cleaned out, making the extent of the damage less obvious. The nest seemed to have been located behind the last board in the card cage (in slot P9). Most of the damage was concentrated in the left half of the motherboard, including slots P10 - P12 and many IC sockets near the regulator area. There was also some damage to slot P3. The motherboard was removed and the damaged parts desoldered:

{% linked_image :file => 'motherboard_slots_removed.jpg', :alt_text => 'Sockets and Slots Removed' %}

In the above picture, heavy corrosion is present on the regulator heatsinks, more damage from the mouse house. There's also quite a bit of filth on the board. Here's some closeups of the removed slots and sockets:

{% linked_images :files => ['closeup_slots_removed.jpg', 'sockets_removed.jpg'], :alt_texts => ['Closeup of Removed S-100 Slots', 'Closeup of Removed Sockets'] %}

The motherboard was then cleaned several times with hot soapy water and dried in the hot air drying cabinet. After drying, the damaged S-100 slots and IC sockets were replaced. I ordered new old stock S-100 slots from [Anchor Electronics](https://anchor-electronics.com/), a long-time favorite. Sockets were replaced with high quality machine pin sockets. North Star had populated the motherboard with good quality dual-wipe sockets, so only the damaged sockets were replaced.

{% linked_image :file => 'motherboard_repaired.jpg', :alt_text => 'Motherboard Cleaned and Repaired' %}

After repair, the motherboard was again washed and dried to remove flux residue from the organic core solder used. This results in a very clean appearance, with no flux blobs on the back of the board. Here are some closeups of the repaired areas:

{% linked_images :files => ['new_slots.jpg', 'new_sockets.jpg'], :alt_texts => ['Closeup of New S-100 Slots', 'Closeup of New Sockets'] %}

Here's a shot of the removed components, before they were discarded:

{% linked_image :file => 'removed_components.jpg', :alt_text => 'Sockets and Slots Removed During Repair' %}

With the motherboard already out, I took the opportunity to give the chassis a thorough cleaning. Dust and grime buildup was removed and the entire chassis wiped down. 

{% linked_image :file => 'motherboard_installed.jpg', :alt_text => 'Repaired Motherboard Installed' %}

The motherboard was then reinstalled in the Horizon chassis, and the power supply was brought up slowly using a variac. Voltages were monitored during bring-up. Main filter capacitors held up well, providing very low ripple and retaining their charge for quite some time after power was removed. The boards that came with the Horizon were tested in a small backplane with my Lambda bench supply, which provides adjustable current limiting -- very handy for catching shorted tantalum capacitors before they explode! Some shorted tantalums were found (North Star boards seem to have plenty of them) and replaced. The chassis was moved from the assembly workbench to the red-topped testing workbench, and the cards reinstalled:

{% linked_images :files => ['finished_chassis.jpg', 'boards_installed.jpg'], :alt_texts => ['Cleaned and Repaired Horizon Chassis', 'Installed S-100 Boards'] %}

The board set is a pretty typical "later Horizon" set:

* North Star Z80 CPU board at 4 MHz
* North Star MDS double density hard sector floppy controller
* North Star HRAM64 64K dynamic RAM board

I had several bootable CP/M disks for various versions of CP/M from North Star and Lifeboat Associates, but I wanted to get Lifeboat CP/M 2.23a DQ to maximize available disk space and device features. [Mike Douglas](http://deramp.com/) has written a number of utilities for the North Star Horizon with hard sectored disk system, which [can be found here](http://deramp.com/downloads/north_star/horizon/). In particular, his [Disk Image Transfer](http://deramp.com/downloads/north_star/horizon/double_density_controller/disk_image_transfer/) for the double-density controller makes getting images onto and off of the Horizon very simple. Mike has a copy of Lifeboat CP/M 2.23A DQ in the [disk images directory](http://deramp.com/downloads/north_star/horizon/double_density_controller/disk_images/cpm/).

{% linked_images :files => ['finished_system.jpg', 'cpm.jpg'], :alt_texts => ['Completed System with VT220 Terminal', 'Lifeboat CP/M Screenshot'] %}

Once CP/M is up and running, Mike's [PCGET and PCPUT](http://deramp.com/downloads/north_star/horizon/pcget_pcput/) can be used to move files between CP/M and another machine capable of doing XMODEM transfers. Using a terminal program such as [minicom](https://en.wikipedia.org/wiki/Minicom) running on a modern computer as the Horizon console is especially nice for getting the system up and going.

The only major work left hardware-wise is to repair the 5.25" floppy drives that came with this Horizon. The drives pictured above are Tandon TM-100s that are not original to the machine. The original A: drive would not boot and won't read disks that it has formatted, so something more significant than alignment issues exist. The original B: drive works initially on power-up, but becomes intermittent as the machine warms up. A pair of reliable drives will run for many hours with no issues. The Horizon makes for a nice, compact 4 MHz Z80 based machine, excellent for CP/M work. It can also be run under North Star's own North Star DOS. Being S-100 based, it is easily expanded.

I do have the wooden cover for this Horizon, it's just almost never installed when the machine is in use!

{% counter :text => 'North Star Horizons Repaired' %}
