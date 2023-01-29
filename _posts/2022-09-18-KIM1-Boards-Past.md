---
layout: post
title: KIM-1 Boards of the Past
topic: A look at KIM-1 boards since sold
category: vintage-misc
description: In Summer 2008, I was working for a surplus components dealer while on break from college. I came across a number of KIM-1 systems, all which have been sold by this point. Here's a look at those systems.
image: kim1_boards_past-icon.jpg
---

During the summer of 2008, I worked for a surplus components dealer in the Blacksburg area, a small mostly-online operation run by Al Witherspoon called Alcomp or Alf Components. Items were listed/labeled both ways, presumably the name had changed at some point and Al hadn't updated everything! My job with Alcomp was effectively "general help," everything from sorting parts and working on inventory documentation to taking pictures for listings. I eventually ended up selling items through my personal eBay account for Alcomp as a form of agreed-upon compensation, mostly items Al didn't want to test and which were more valuable once tested.

During this time, I found a total of six KIM-1 computers: five rev 0 and rev A MOS manufactured boards, and one rev F Commodore board. All were Virginia Tech surplus. All have been sold at this point. Below are the remaining images of them, as well as descriptions.

### My First KIM-1

My first KIM-1 was given to me by [Burgess Macneal](https://en.wikipedia.org/wiki/Burgess_Macneal), who was the owner of the building that Alcomp's bulk inventory storage was located in. I'd spotted it sitting by itself in The Gym. Burgess himself is a 6502 hacker: his business's first computer was an [Ohio Scientific Challenger III](/~glitch/2019/07/30/470-repair-and-second-c3), kit-built and run without a case its whole life. He suggested I repair the KIM-1 and learn 6502 assembly. That's pretty much what I did, apparently working on my parents' living room table:

{% linked_image :file => 'burgess_repair.jpg', :alt_text => 'My first KIM-1 being repaired' %}

Someone at Virginia Tech had done a very nice job of building a base with PSU for the KIM-1! This one had a blown bridge rectifier in the power supply, and its 1 MHz crystal had been removed at some point. In the picture above, the power supply has been removed and the dead bridge rectifier module can be seen in the white plastic base. The power supply appears to be an in-house build.

After repairing the PSU, voltages were checked with my Fairchild/Systron-Donner 7050 Nixie tube DMM:

{% linked_image :file => 'burgess_dmm.jpg', :alt_text => 'Checking the KIM-1 PSU with a Nixie DMM' %}

Simpler times! Note the Rat Shack pencil iron in the stand atop the 7050 DMM. With PSU voltages verified and a new 1 MHz crystal installed, the KIM-1 was operational:

{% linked_image :file => 'burgess_008a.jpg', :alt_text => 'My first KIM-1 running' %}

I followed the instructions for basic check-out found in scans of the KIM-1 manuals, and started figuring out the basics of the 6502 architecture. I'd already taught myself PIC16 assembly in high school, and had been working with PICs for some time. This was of course the beginning of the discovery that basically all modern computers are the same, at their core!

### More KIM-1s

During that summer, I was tasked with going through a lot of the boxed "stuff" that had arrived from Alcomp's bulk purchases of parts and equipment. Some of the incoming material was from closed businesses, some from Al's personal efforts in buying from other vendors online and at hamfests, and some was from the Virginia Tech surplus auction.

One of the boxes of incoming material contained ***five KIM-1 computers***, various documentation, and miscellaneous associated hardware. It seemed to have been the results of a cleanout of some EE or ECE lab. The cases on the bottoms of most of the KIM-1s matched the white plastic case that my first KIM-1 was mounted on, suggesting that mine had either come from the same lot, or at least the same lab. To my astonishment, Al insisted KIM-1s weren't worth his hassle to try and sell -- he explained this as not having the digital experience to thoroughly test them, and not wanting to deal with buyers who had purchased a "tested, working" machine and either didn't know how to use it, or broke it in the process.

In any case, I was told that the KIM-1s were going to be scrapped, and was given the opportunity to take them home for some agreed upon amount of money to be deducted from my pay. That sounded like a good deal to me, and so they went home.

### Broken Revision A KIM-1

I have only a single picture of this system, undoubtedly from its eBay listing:

{% linked_image :file => 'rev_a.jpg', :alt_text => 'A revision A MOS KIM-1' %}

This one was pictured removed from its white plastic base. I believe, but cannot be certain, that one of the bases was badly damaged. It's also my recollection that this particular KIM-1 didn't work -- I remember one of them being non-functional, and this one has two small penciled X marks on the 6502 and the upper 6530 RRIOT. This was probably the first of the KIM-1s to be sold, I'm sure I saw no reason to hang onto one that didn't work, and which likely required a replacement 6530 RRIOT, for which there was no substitute at the time.

### A Commodore Revision F KIM-1

This was certainly the newest KIM-1 of the bunch, it's a rev F and carries Commodore branding. These photos are also from its eBay listing, but there are more of them:

{% linked_images :files => ['rev_f_4352.jpg', 'rev_f_0000.jpg'], :alt_texts => ['Revision F KIM-1 showing address 0x4352', 'Revision F KIM-1 showing address 0x0000'] %}

The white plastic base common to most of these Virginia Tech surplus machines can be seen in the left side of the above pictures. There's also a Virginia Tech (VPI & SU) asset tag next to the keyboard. I forget if the previous two had asset tags when I received them. Here's a closeup of the displays and the logos:

{% linked_images :files => ['rev_f_displays.jpg', 'rev_f_logo.jpg'], :alt_texts => ['Revision F KIM-1 display closeups', 'Revision F KIM-1 logos'] %}

I don't have records of its sale, but I believe the rev F board sold around $250 at the time of its listing. The filedates on the images are nonsense, clearly I'd let the battery fully discharge in the camera, but I believe this was sold fairly quickly after my acquiring the KIM-1s, in summer 2008.

### A Very Early KIM-1

This KIM-1 is a very early one: it's a revision 0/no-revision MOS unit, and the 6502 was early enough that it included the [ROR bug](https://www.pagetable.com/?p=406)! 

{% linked_image :file => 'veryold_kim1.jpg', :alt_text => 'A very old KIM-1' %}

Unfortunately, I don't seem to have a picture of the serial number for this one. Perhaps it wasn't marked? The datecodes put the machine's assembly as early 1976. It also has the unmasked MOS logo in the corner:

{% linked_images :files => ['veryold_ics.jpg', 'veryold_logo.jpg'], :alt_texts => ['40-pin ICs on rev 0 KIM-1', 'MOS logo on rev 0 KIM-1'] %}

The case on which this KIM-1 was mounted lacked the finish of the white plastic cases:

{% linked_image :file => 'veryold_case.jpg', :alt_text => 'Mounting case for the rev 0 KIM-1' %}

The above case is more mechanically complicated, and definitely "feels" like a one-off. The power supply was point-to-point wired, using terminal strips rather than a circuit board. I believe the power supply showed signs of damage, and I never ended up powering the supply up. A Dymo label reading `EET 1` can be seen at the top of the case; presumably, this was the first KIM-1 used for classroom instruction at Virginia Tech.

{% linked_images :files => ['veryold_powered.jpg', 'veryold_display.jpg'], :alt_texts => ['Rev 0 KIM-1 powered up', 'Rev 0 KIM-1 displays' ] %}

The rev 0 board did work when powered with a bench supply! In running through some test programs, I discovered the `ROR` bug was present on this one's 6502. 

In addition to the KIM-1 and its case, this one was sold with all of the relevant extras from the lot. Below are the 6502 and 6530 datasheets that were found with it:

{% linked_images :files => ['6502data.jpg', '6530data.jpg'], :alt_texts => ['Early 6502 datasheet', 'Early 6530 RRIOT datasheet'] %}

The following letter, which included either a cover or closing letter signed by [Chuck Peddle](https://en.wikipedia.org/wiki/Chuck_Peddle) himself, is dated February 1976 and corresponds with the datecodes found on the RRIOTs on the KIM-1. Presumably this letter was sent in response to an inquiry from Virginia Tech about purchasing KIM-1s:

{% linked_images :files => ['veryold_correspond.jpg', 'veryold_date.jpg'], :alt_texts => ['MOS correspondence from 1976', 'Closeup of correspondence date'] %}

The correspondence mentions the ROMless MOS 6532 RIOT, which had apparently not been introduced yet. There was of course a wall-sized KIM-1 poster:

{% linked_image :file => 'veryold_poster.jpg', :alt_text => 'KIM-1 wall poster' %}

This was already a very complete bundle for an early KIM-1, but I also had one more piece of related hardware: a KIM-2 RAM expansion!

{% linked_image :file => 'kim2.jpg', :alt_text => 'KIM-2 RAM expansion board' %}

The KIM-2 provides 4K of static RAM for the KIM-1. I did not fully test the KIM-2, only checking for power supply shorts and excessive current draw. There was no KIM-4 backplane or custom wiring harness for the KIM-2, and I don't think I was able to find documentation for it at the time.

All of these items sold through eBay to an individual in France. This would've been in late 2009 or early 2010 -- I was living off-campus at that point. I remember the buyer paying for UPS express international shipment, certainly the most expensive shipping bill I'd ever paid at the time.

### My Last KIM-1

In the process of going through all of the KIM-1s I'd acquired, I had set aside one to keep for myself. This one was a revision A MOS-branded board, and was in overall better shape than the KIM-1 Burgess had given me:

{% linked_image :file => 'lastone_off.jpg', :alt_text => 'Final rev A KIM-1' %}

I took more detailed pictures of the base and power supply:

{% linked_images :files => ['lastone_mounting.jpg', 'lastone_psu.jpg'], :alt_texts => ['Rev A KIM-1 unmounted from base', 'Power supply detail'] %}

The above shot of the opened base shows the clean layout in the base with the power supply mounted in its intended home. The holes in the bottom line up with the heatsink of one of the regulators, clearly intended to promote convective cooling, drawing cool air from the bottom and exhausting warm air through the top, below the KIM-1. This one did of course work:

{% linked_images :files => ['lastone_running1.jpg', 'lastone_running2.jpg'], :alt_texts => ['Revision A KIM-1 running', 'Revision A KIM-1 running'] %}

Its serial number is `1898`:

{% linked_image :file => 'lastone_sn.jpg', :alt_text => 'Revision A KIM-1 Serial Number' %}

Unfortunately, the KIM-1 I'd intended to keep was eventually sold. This was autumn 2010, I'd just moved with my future wife to Troy, NY while she pursued a Ph.D. at Rensselaer Polytechnic Institute. Jobs were scarce, college loans were coming due, and the KIM-1 was valuable. Oh well! Easy come, easy go. Paying bills was of course more important than owning a KIM-1, and I could always [hack on the Apple IIe](/~glitch/2010/11/09/48-hours-apple-iie) or the [Ohio Scientific](/~glitch/2016/04/20/challenger-3-cleanup) if I needed a 6502-based system!

### What Happened to These Computers?

I have never seen any of these machines talked about or pictured on the Internet, exhibited at [VCF East](https://vcfed.org/events/vintage-computer-festival-east/), [VCF Midwest](http://vcfmw.org/), or the [HOPE conference](https://hope.net/). I haven't seen them show up for sale on everyone's favorite auction site. None of the new owners contacted me at all after the sales of these machines.

There's a sixth KIM-1 that was sold, but I don't appear to have pictures of it. I believe it was another revision A MOS board, mounted to the plastic base with PSU seen in three of the above sections.

I'd love to know what became of these KIM-1s. If you are the current owner of one of them, know the current owner, or used one of these while at Virginia Tech, please {% contact %}!

{% counter :text => 'KIM-1s remembered' %}
