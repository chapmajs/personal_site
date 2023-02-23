---
layout: post
title: Cleaning DEC RL Packs
topic: Cleaning and testing DEC RL01 and RL02 packs
category: dec
description: In March 2013, I'd finally gotten enough hardware together to try and run DEC RL01 pack drives with my PDP-11. Sark and I got together to clean a bunch of packs and get our respective systems set up and running. 
image: pack_cleaning-icon.jpg
---

My first DEC PDP-11 system came out of a piece of Kevex lab gear found during college, some time in 2008, but it wasn't until March 2013 that I actually had enough hardware together to try and run [DEC RL01 pack drives](https://gunkies.org/wiki/RL01/02_disk_drive). In that time, I'd acquired [my PDP-11/10]({% post_url 2019-06-05-PDP1110-PSU-Repair %}) -- the power supply ran fine back then -- and found a RL11 Unibus controller for it. The lot of equipment that the PDP-11/10 came from also included some DEC RL01 pack drives, which store 5 MB per removable disk pack. I had gone in with [Sark](http://www.retrohacker.com/) on that lot of equipment, and in splitting it up, we decided I would try and run the RL01 drives as he already had RL02 drives.

Finding RL01 disk packs ended up being almost as challenging as the rest of the hardware! I ended up buying several RL02 packs and trading various folks, including Sark, to get a few packs together for my system. In late March 2013, Sark and I decided to get together and clean packs and drives, set up a PDP-11 test system, and generate usable system media. We chose to work at his house, since he had room to set everything up.

### Cleaning RL Packs

The first thing to do was clean RL packs. We'd both been warned by many other hobbyists: 

***Never load a totally unknown pack in your good RL drive, if it's crashed you'll wreck the drive which will then wreck other packs!***

Not only can a crashed pack ruin a good drive, but a *dirty* pack also runs that risk. We used Sark's kitchen counter since it was a convenient work surface next to a sink. It was also easy to wipe down, we wanted to eliminate as much dust as possible. The counter was cleared, cleaned with regular multipurpose cleaner, then wiped down with isopropyl alcohol and lint-free Kimwipes:

{% linked_image :file => 'clean_counter.jpg', :alt_text => 'Kitchen counter wiped down for work' %}

After that, we got our tools together and wiped those down, too:

{% linked_image :file => 'tools.jpg', :alt_text => 'Tools for pack cleaning' %}

The following items were used:

* Kimwipe lint-free wipers
* Lint-free swabs
* 99% isopropyl alcohol in a wash bottle
* Compressed gas duster
* Screwdrivers
* Bright flashlight (a [Hexbright](https://www.adafruit.com/product/1725))

We also pretty quickly discovered that 99% isopropyl alcohol is *much drier* than 70% from the drugstore, and had to acquire gloves, as it was desiccating our hands! Nitrile gloves from the auto store worked well.

The cleaning procedure is, basically:

* Clean the outside of the pack, top and bottom, removing loose/unwanted stickers
* Release pack handle and remove bottom cover, clean inside cover and pack shield
* Remove pack shield (screws on RL01, tabs on RL02)
* Inspect for signs of crashes ("rings of Saturn", nicks, obvious distortion)
* Wrap a Kimwipe around the wooden stick of a swab, saturate in alcohol
* Hold the stick with Kimwipe radially against the pack platter and rotate
* Repeat on the other platter surface
* Use a saturated lint-free swab to remove stubborn dust (scrub *very gently* if at all)

After cleaning, the platter surfaces were inspected with the bright flashlight. Small bits of dust and dirt that were not visible in regular lighting showed up much better this way, especially with the light at an angle to the platter. Loose bits can be picked up with the corner of a Kimwipe with a bit of alcohol on it.

99% alcohol really is necessary for cleaning packs, even 91% from the drugstore leaves too much residue on drying. The alcohol we used came from [McMaster-Carr](https://www.mcmaster.com/). Don't just open the container and dip into it -- you'll contaminate the bulk container, plus it'll draw moisture from the air. We poured small amounts (an ounce or so) into a wash bottle, which was used to do the actual dispensing.

We had a lot of packs to go through:

{% linked_image :file => 'dirty_packs.jpg', :alt_text => 'Dirty RL packs ready for cleaning' %}

This is the first one that got cleaned:

{% linked_image :file => 'first_pack.jpg', :alt_text => 'First pack to be cleaned' %}

The label with the green and red writing was loose (there's a note from [Will Kranz](http://www.willsworks.net/) that the pack was tested in March 2011), and there was residue from another label someone had peeled off. Both of these were removed, including residue. The pack's outside was then wiped down with a Kimwipe and alcohol:

{% linked_image :file => 'labels_removed.jpg', :alt_text => 'Labels removed from pack' %}

The pack could now be removed from the bottom cover (unlock and lift the handle):

{% linked_image :file => 'bottom.jpg', :alt_text => 'RL02 pack with bottom cover removed' %} 

The inside of the bottom cover was cleaned and wiped down, as well as the pack shield. Pay special attention to the black sealing material around the edge of the pack, we found that it often held filth. Now remove the pack shield, the piece of plastic covering the bottom of the platter:

{% linked_image :file => 'shield_removed.jpg', :alt_text => 'RL02 with pack shield removed' %}

This is of course the bottom surface of the disk platter, so be careful! Use non-magnetized screwdriver(s) to remove the shield. On the RL01s I've had, the shield is usually secured with screws. On the RL02s, it's usually clips. You can see them around the perimeter of the upper housing in the above picture. Pry *gently* to free them, you don't want to break the housing or slip and gouge the disk.

During inspection, we did find several of Sark's RL02 packs with obvious head crash damage that was not apparent from peeking inside the pack with the shield on. We also removed several spots of stuck-on filth, which could have very well crashed heads. Once again, ***it is absolutely critical to inspect and clean packs before mounting them in a drive!***

### PDP-11 Setup

For testing, we decided to use Sark's PDP-11/23 Plus. This machine was purchased from [Will Kranz](http://www.willsworks.net/) and was known to be in working condition. We set it up on a slab of Masonite in a spare room:

{% linked_image :file => '1123plus_setup.jpg', :alt_text => 'PDP-11/23 Plus' %}

The computer lived in a DEC "corporate cab," a half-rack purpose built for a QBus PDP-11 and two RL style pack drives. The plan was to give the system a cleaning, use the lower RL02 as the boot drive, and the upper RL02 for testing packs. The top access afforded through the corporate cab would make this easier -- the top surface seen above is the RL02's top, not a piece of the rack enclosure!

Sark had a Televideo 910 fixed up and ready to use as the system console terminal:

{% linked_image :file => 'terminal.jpg', :alt_text => 'Televideo 910 terminal' %}

Sark's KDF11 came up with no issues:

{% linked_image :file => 'startup.jpg', :alt_text => 'KDF11 sign-on' %}

I brought my utility PC over, an old Lian Li full tower with an AMD Slot A Athlon motherboard. It triple-booted MS-DOS 6.22, Windows 2000, and Linux. Here it is booted into Windows 2000:

{% linked_image :file => 'utility_pc.jpg', :alt_text => 'Utility PC running Windows 2000' %}

I'd already gotten a [TU58](http://gunkies.org/wiki/TU58_DECtape_II) emulator up and running, and had it talking to my PDP-11/03 setup at home. [VTserver](https://minnie.tuhs.org/Programs/Vtserver/) is running in the above picture. VTserver is the "**V**irtual **T**ape server" and allows transfer of media images to/from PDP-11 systems over serial. Despite the name mentioning tape, VTserver will in fact work with various kinds of disks. 

### RL02 Drive Cleanup and Testing

Before testing packs, we cleaned Sark's RL02 drives. The outsides were cleaned with Windex and paper towels, then the pack wells and heads were cleaned. This involves powering them up to retract the solenoids that lock the door covering the pack well, powering them off, and cleaning the heads with a lint-free swab saturated with 99% isopropyl alcohol. The pack wells were wiped down with Kimwipes and alcohol. In the case of Sark's drives, we also had to rotate the head lock plate out of the way: the drives were still locked from their trip to Sark's house from Will Kranz's.

While we were cleaning the drives, we also replaced some burned out indicators. I happened to have the exact bulbs on hand, in quantity, found in The Gym. We didn't have the actual lamp extraction tool, so we wrapped black electrical tape around the jaws of long needle-nose pliers. This allowed gripping the lamps by the glass without crushing them.

### Testing the First Pack

Finally, time to mount a pack:

{% linked_images :files => ['first_pack_mounted.jpg', 'cover_in_drive.jpg'], :alt_texts => ['First cleaned pack mounted in drive', 'Cover placed over pack in drive'] %}

I don't remember who pressed the `LOAD` switch on the first one, but there was much anticipation as the lights dimmed slightly, the drive spun up, and finally, the `READY` lamp came on! No fault lamp, no weird noises, no excessive vibration. When Sark bought the PDP-11/23 Plus from Will, Will was kind enough to provide a known-good bootable RT-11 pack generated for the system. That was why we cleaned it first! It booted without issue:

{% linked_image :file => 'rt11_running.jpg', :alt_text => 'RT-11 running from RL02 pack' %}

After booting the RT-11 pack and poking around, we halted the PDP-11 and loaded VTserver using its ODT type-in bootstrap feature. In this mode, VTserver acts as the serial console for the PDP-11 and "types" the PDP-11 side of itself into memory using ODT. This is a very convenient way to bring it up "bare metal" on a PDP-11 for which one does not have bootable media.

With VTserver loaded, we dumped the RL02 pack. We were running Sark's KDF11's onboard console SLU at 19200 BPS, its maximum rate. After watching progress for a while, we realized it'd take *over an hour and a half* to dump this first pack, and decided to go get a burger. It did eventually finish without error.

### Processor Upgrades and Dumping More Packs

To speed things up, we pulled the KDF11 in Sark's PDP-11 and plugged in a KDJ11 and memory board I'd traded [Bill Degnan](http://vintagecomputer.net/) for some time earlier. The KDJ11 is faster CPU-wise, but we were mainly interested in the console SLU, which can run at 38400 BPS. This cuts the time to dump a pack in half, to around 45 minutes. The KDJ11 also has a more in-depth startup diagnostic routine, and supports booting from basically anything you can plug into a QBus machine.

We used this setup to dump the rest of the packs which appeared to be serviceable. During testing, we'd mount a pack, hit `LOAD`, and wait a minute or so before taking a finger off the `LOAD` switch. If there were any weird noises or excessive vibration, the `LOAD` switch could be released immediately, optimally before the pack finished coming up to speed and the heads actually loaded. This saved us on more than one pack! There was one that started making a pinging noise as soon as the heads loaded, almost certainly a sign of a previous head crash. Another produced a crazy amount of vibration on spin-up: this pack had a tripped ShockWatch indicator, and the platter was likely slightly warped from a fall.

Dumping the packs was a multi-day affair. File dates on the pictures for this writeup suggest we started on Saturday, March 30th and took Sunday to continue dumping packs. It looks like we picked up the following weekend, and finished on Sunday, April 7th.

### Running My RL01 Drive

Since we now had a known-good system with good RLV12 controller and two functional RL02 drives, it was time to figure out if I had good RL01 drives or not. Here's my first RL01:

{% linked_image :file => 'my_rl01.jpg', :alt_text => 'My RL01 pack drive' %}

To the left of the drive, my KDJ11 and memory board can be seen, so this must've been taken before we installed them in Sark's PDP-11 chassis. My RL01 got the same exterior cleanup, pack well wipedown, and head cleaning as Sark's RL02s. The heads in my RL01 were much dirtier, but it had been stored for a long time in a somewhat damp basement in Malden, MA, by the previous owner. The RL cable on top of it was not original to the setup from which it came, and was purchased with the RL11 controller I'd bought for my PDP-11/10. It got new lamps as well.

We extracted Sark's top RL02 drive, and mounted my RL01 in its rails (they're the same between drives). We then loaded the only pack I had at the time, referred to as the "cat pack" due to the sticker on top:

{% linked_images :files => ['catpack_mounted.jpg', 'catpack_cover.jpg'], :alt_texts => ['Cat pack mounted', 'Cat pack cover'] %}

The "cat pack" was dumped (they go much faster, being half the capacity of a RL02!). It was not bootable and did not contain a filesystem that RT-11 was interested in talking to. We decided to start on a new process with this pack: loading XXDP and exercising the packs, then reformatting them under RT-11 and running `DIR/BAD` to check bad blocks. That would require a little more work...

### Getting XXDP Going

Sark didn't have an XXDP pack, and we had to figure out how to generate one. We had an XXDP pack image, but none of the RL02 packs he had were `-EF` error-free suffix packs. This means that we couldn't just use VTserver to dump the image on, as it was extremely unlikely the image's defects would line up with the defects on a given RL02 pack.

To solve this problem, we used a process I'd been using to run diagnostics on my PDP-11/03 and PDP-11/10 setups: we generated XXDP TU58 images by booting the XXDP pack image in [Ersatz-11](http://www.dbit.com/), a PDP-11 emulator (couldn't make SIMH do it back then) and mounting a "blank" TU58 image. Files were then copied from the mounted pack image to the TU58 image. Once a TU58 image was prepared, we booted it on the actual PDP-11 using [Will Kranz's TU58 emulator](http://www.willsworks.net/pdp-11/tu58-emu). Real TU58 tape drives connect to the PDP-11 over a SLU, so they're easy to emulate using a PC.

Once booted into XXDP on the emulated TU58, we were able to run `UPDAT` to `INIT` and `CREATE` a RL02 cartridge for XXDP. Files were then copied from the emulated TU58 tape to the RL02 pack. This was repeated many times in order to get everything we needed onto RL02. It took a long time, but doing it this way allowed for sparing out the bad blocks on the RL02 packs.

The resulting bootable XXDP RL02 pack was of course dumped using VTserver!

With XXDP running, we were now able to run additional hardware diagnostics on my RL01, pack utilities, etc. The "cat pack" was initialized with an XXDP filesystem, and parts of XXDP relevant to my needs on the PDP-11/03 and PDP-11/10 were copied over (the whole of XXDP won't fit on a RL01).

### Conclusion

Well, that took a while! Only nearly 10 years to turn the pictures into a writeup, too! Now both Sark and I had known good packs and drives, though we couldn't directly interchange packs since I had only RL01 drives. and Sark had only RL02 drives. During the course of going through additional packs Sark retrieved from storage, he did find two additional RL01 packs, both of which were good, which he traded to me.

During our PDP-11 hacking, we apparently tested some extra QBus hardware I had in my BA11-N chassis:

{% linked_image :file => 'my_1103.jpg', :alt_text => 'Testing extra QBus hardware' %}

As I recall, this board didn't work, and we didn't spend too much time chasing down issues with it. I ended up trading it to another hobbyist at some point. There was quite a lot going on in Sark's spare room though:

{% linked_image :file => 'whole_setup.jpg', :alt_text => 'PDP-11 hacking' %}

Above, you can see another drive perched on top of Sark's RL02 in the top of the corporate cab. I don't remember if that was my other RL01 or an additional RL02 of Sark's. Do note we put a big rectangle of cardboard under it, so that it wouldn't mar the top of the RL02 below it!

{% counter :text => 'head crashes avoided' %}
