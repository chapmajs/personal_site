---
layout: post
title: Converting the MTI MXV22M to MXV22
topic: Using a MXV22M with 8 inch diskettes for RX01 and RX02 compatibility
category: dec
description: The Micro Technology Incorporated MXV22M is very similar to the more useful MXV22, which allows use of Shugart compatible 8 inch floppy drives as RX01 and RX02 compatible disk subsystems in a QBus PDP-11. Conversion requires changing jumpers and blowing a new set of fuse PROMs.
image: mti_mxv22m_conversion-icon.jpg
---

## Quick Links

* [MXV22M manual on Bitsavers](https://bitsavers.trailing-edge.com/pdf/microTechnology/MXV22/810010-202C_MXV22M_198410.pdf)
* [MXV22 manual on Bitsavers](810010-202C_MXV22M_198410.pdf)
* [Fuse PROM files, via FTP](ftp://filedump.glitchwrks.com/qbus/MTI_MXV22_CA_ROMs.tar.gz)
* [Fuse PROM files, via HTTP/HTTPS](http://filedump.glitchwrks.com/qbus/MTI_MXV22_CA_ROMs.tar.gz)
* [VC Forums Thread](https://forum.vcfed.org/index.php?threads/1257550/)

A number of years ago, [Al Kossow](https://www.bitsavers.org/) was talking about doing a group buy of a bunch of QBus hardware, which included several Micro Technology Incorporated MXV22 boards. The MXV22 is a RXV21 compatible interface that talks to regular Shugart-style 8" diskette drives, like the SA-800. It can even format RX01 and RX02 diskettes in-system, something that the DEC RX systems can't do. I negotiated a good price for the lot and took delivery of it...only to discover that the boards were **MXV22M**:

{% linked_image :file => 'mxv22m.jpg', :alt_text => 'MTI MXV22M, as received' %}

Unlike the MXV22, the -M suffix doesn't talk to 8" diskette drives, it talks to 5.25" SA-460 drives. It still presents a RXV21 compatible interface to the QBus, but uses its own format on the 5.25" diskettes. This is significantly less useful than media compatibility with RX01/RX02. The MXV22 and -M suffix boards did look very similar though, and several of us speculated that it might simply be a jumper and firmware change. Fortunately, [John Ball](https://www.bitsavers.org/) had an actual MXV22 and was willing to loan it to me for examination:

{% linked_image :file => 'johns_mxv22.jpg', :alt_text => 'MTI MXV22 on loan from John Ball' %}

The boards are in fact the same etch number, what luck! With boards in hand, it was time to find the differences, which turned out to be:

* Jumper W1 - W3 settings
* Jumper W4 - W6 settings
* Jumper W12 - W14 settings
* Jumper W41 - W46 settings
* Missing pins on the floppy header

The last item, the missing pins on the floppy header, didn't actually matter. These pins were not used on the 8" Shugart connector standard.

### Rejumpering the MXV22M to MXV22

The above jumpers need to be changed over for MXV22 operation. Here's a guide to their location on the board:

{% linked_image :file => 'jumper_locations.jpg', :alt_text => 'MXV22/M jumper locations' %}

The MXV22M ships with a link between W1 and W2, this needs to be desoldered and a link installed between W2 and W3:

{% image :file => 'jumpers_w1.jpg', :alt_text => 'Jumper diagram for W1 - W3' %}

The MXV22M ships with a link between W4 and W5, this needs to be desoldered and a link installed between W5 and W6:

{% image :file => 'jumpers_w4.jpg', :alt_text => 'Jumper diagram for W4 - W6' %}

The MXV22M ships with a link between W13 and W14, this needs to be desoldered and a link installed between W12 and W13:

{% image :file => 'jumpers_w12.jpg', :alt_text => 'Jumper diagram for W12 - W14' %}

The MXV22M ships with shunts on W41 through W46 (there was variation as to which ones were jumped on the MXV22Ms I received) that need to be moved:

{% image :file => 'jumpers_w41.jpg', :alt_text => 'Jumper diagram for W41 - W46' %}

All other jumpers are the same between the MXV22M and the MXV22, and should match the factory manuals. Do note that W46 - W47 controls 22-bit compatibility mode and will need set based on your system configuration.

### Firmware Changes

Aside from rejumpering, the firmware between the MXV22M and the MXV22 is different. This firmware is contained in a number of bipolar fuse PROMs, which are one-time programmable devices. U1 through U7 are N82S185A type 2K x 4 devices, U39 is a N82S129 256 x 4 device with tristate outputs. These devices are obtainable, but are somewhat hard to find. They're also one-time devices: unlike EPROMs, bipolar fuse PROMs use chip-scale nichrome fuse links which are physically blown out during the programming process (this is where "blow a PROM" comes from). Many Internet sources claim to have unprogrammed devices but end up shipping useless, pre-programmed devices.

The PROMs from John's MXV22 were dumped using the Data I/O 29B with UniPak 2B. Those files are available on the Glitch Works filedump:

* Via HTTP/HTTPS: [http://filedump.glitchwrks.com/qbus/MTI_MXV22_CA_ROMs.tar.gz](http://filedump.glitchwrks.com/qbus/MTI_MXV22_CA_ROMs.tar.gz)
* Via FTP: [ftp://filedump.glitchwrks.com/qbus/MTI_MXV22_CA_ROMs.tar.gz](ftp://filedump.glitchwrks.com/qbus/MTI_MXV22_CA_ROMs.tar.gz)

All ROM images are in Intel HEX format. `1031CA.HEX` through `1037CA.HEX` are for U1 through U7. `1015A.HEX` is for U39. If you burn a set of these PROMs and try the conversion in your MTI MXV22M, please {% contact :text => 'let us know' %} -- include a short description of the system you're running the MXV22 in, and the operating system(s) or software you have tested with.

There are three other bipolar fuse PROMs on the MXV22M at U19, U20, and U49 but these PROMs are the same on the MXV22.

### Testing

I tested my MXV22M-to-MXV22 conversion in my PDP-11/23 Plus with a pair of Shugart SA-801 drives in a Xerox 820 cabinet. It was able to boot XXDP and RT-11 media from the MINC-23, format blank (degaussed) diskettes from the onboard firmware as both RX01 and RX02 media, initialized fine under XXDP and RT-11, and media thus initialized could be made bootable in the system. Success!

{% linked_image :file => 'converted_mxv22m.jpg', :alt_text => 'MXV22M converted to MXV22' %}

Steve Hirsch was interested in a converted MXV22M, and bought a set of blank fuse PROMs to try the conversion himself. His programmed turned out to not support the variants he had purchased, so he sent them to me for programming on the Data I/O. I went ahead and strapped up a MXV22M as a MXV22 for him, and the second conversion worked as well in my PDP-11/23 Plus as the first had! 

Steve tested the converted board in his "Frankenstein 11/83":

* DEC KDJ11-B CPU board
* 4 MB Clearpoint PMI memory
* QBone for MSCP drive emulation

After resolving a mixup with I/O address length in ODT (the manual gives examples for a Q16 system!), Steve was able to get the controller working. He does note:

{% textblock :title => 'MTI MXV22 Notes' %}
  I have it booting from the floppy. It may be coincidental, but this started
  cooperating after disabling 22-bit addressing on the controller. The MTI manual
  is very confusing in its treatment of address width, but I get the impression a 
  patched driver is required for 22-bit operation.
{% endtextblock %}

I have not poked further into this issue, but it looks like the W46 - W47 jumper purpose may be a little misleading w.r.t. the manual's description!

### Bipolar PROM Replacements

It should be possible to replace the bipolar PROMs at U1 through U7 with a daughterboard containing high speed EEPROM or Flash memory. I have not yet started this project, other than to verify that the original devices aren't too fast to make that possible.

For now, if you have enough blank PROMs on hand but no way to program them, {% contact %} and we can blow a set for you!

{% counter :text => 'MXV22Ms made useful' %}
