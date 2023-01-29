---
layout: post
title: Quad Port Gigabit PCI Ethernet Card Roundup
topic: Evaluating quad port gigabit Ethernet cards for use in a pfSense box
category: general
description: I was recently tasked with building a new pfSense box for the office. We needed three or four Ethernet ports, and wanted to use a 1U Intel Atom based server. Finding a quad port card was a little challenging, so here's a writeup on picking the right card for your build.
image: glitch.jpg
---

[Enable Labs](http://www.enablelabs.com) recently moved to a larger building, and with the move we decided to replace our aging [pfSense](http://www.pfsense.org) router/firewall device with new hardware in a rack mount chassis. There were several requirements for the project: the chassis must be half-depth for front- or mid-mount in a two post telecom rack, it must be low-power (preferably Intel Atom based), and it must provide a sufficient number of physical Ethernet ports for our planned network topology. We would need at least three LAN ports, as well as a WAN port. Since the chassis was to be 1U and we wanted some expandability, it was decided that a quad port Ethernet card would fit the bill.

We chose to go with an [Intel D525MW](http://www.intel.com/content/www/us/en/motherboards/desktop-motherboards/desktop-board-d525mw.html) Mini-ITX motherboard in a [SuperMicro 512L-200B](http://www.supermicro.com/products/chassis/1u/512/sc512l-200.cfm) shallow 1U chassis. This choice was made due to the availability of an Intel D525MW in-house for throughput and compatibility testing. The chassis depth of 14 inches limited the selection of Ethernet cards physically, while the PCI 2.2 slot on the motherboard limited us to 5V compatible PCI and PCI-X cards. Here's a review of the various cards we experimented with, from the winner down.

Sun Microsystems GigaSwift Quad Port PCI-X Adapter (501-6738-10)
----------------------------------------------------------------

{% linked_image :file => 'sun6738.jpg', :alt_text => 'Sun 501-6738-10, image credit to eBay seller tryc2' %}

This adapter ended up being our winner. It's a true quad port Ethernet card, it's physically short enough to fit in the chosen 1U case, and it's PCI 2.2 3.3V/5V compatible. These cards are also cheaply available as used hardware through auction sites like eBay -- we picked ours up for $24 including shipping. The National Semiconductor Saturn chipset and FreeBSD [cas(4)](http://www.freebsd.org/cgi/man.cgi?query=cas&sektion=4) driver play well together. When using this card in a PCI 2.2 slot, the PCI bus will be your bottleneck.

The only hitch is that this card is only supported in pfSense 2.0.1, and it's not officially listed in the [FreeBSD 8.1 Hardware Notes](http://www.freebsd.org/releases/8.1R/hardware.html#ETHERNET), which is the FreeBSD release that pfSense 2.0.x is based on. [This pfSense forum post](http://forum.pfsense.org/index.php?topic=33960.0;wap2) made it seem likely that the board would be supported, but there was no definite evidence available online. The updated cas(4) driver was apparently included in the pfSense 2.0.1 release, and this card is recognized at boot time with no additional configuration. We've been using it in a production environment for several weeks with no troubles.

Sun Microsystems GigaSwift Quad Port PCI-X Adapter (501-6522-08)
----------------------------------------------------------------

{% linked_image :file => 'sun6522.jpg', :alt_text => 'Sun 501-6522-08' %}

Similar to the above Sun 501-6738-10, this Sun adapter shares the same chipset and many of the same characteristics. It is an older card, so it's cheaply available through online resellers. It is officially listed in the [FreeBSD 8.1 Hardware Notes](http://www.freebsd.org/releases/8.1R/hardware.html#ETHERNET) as being supported, and was initially our card of choice; however, due to its length it would not fit in our shallow 1U chassis. If you're using a full-depth chassis or an old PC for your pfSense build, this card would be an economical choice.

Intel PRO/1000 MT Quad Port PCI-X Adapter
-----------------------------------------

{% linked_image :file => 'pro1000mt.jpg', :alt_text => 'Intel PRO/1000 MT' %}

I'm generally a big fan of Intel's gigabit Ethernet adapters, but this card was a letdown. Intel specifies it as a universal PCI-X/PCI 2.2 compatible card; however, it is a 3.3V-only PCI card with the 5V notch uncut. This wouldn't be disappointing if Intel didn't list the card as 3.3V/5V compatible. It's probably a fine card for anyone building a box with 3.3V PCI slots or actual PCI-X slots, but avoid it for most PCI 2.2 motherboards (very few have 3.3V-only slots). Do note that Intel's PRO/1000 MT dual port cards are actually universal 3.3V/5V compatible.

Silicom PXG4BPi Quad Port PCI-X Bypass Adapter
----------------------------------------------

{% linked_image :file => 'silicom.jpg', :alt_text => 'Silicom PXG4BPi' %}

Avoid this card for FreeBSD applications. These cards are available for less than true Intel PRO/1000 cards through online resellers and are often listed as Intel-compatible. They're not. They use an Intel chipset, but will not work with the Intel [em(4)](http://www.freebsd.org/cgi/man.cgi?query=em&sektion=4) driver under FreeBSD. You can get the driver source from Silicom's website (you'll need to e-mail them for a login), but I had no luck in building it under FreeBSD 8.1. It wasn't worth my time to fix someone else's proprietary-licensed C code.

Final Thoughts
--------------

Choices for quad port gigabit Ethernet adapters seem to be pretty open. Depending on your situation, you can probably pick one up cheaply on the surplus market. There are a couple of main considerations to picking an appropriate card:

* Avoid cards that use a single gigabit chipset and a four-port switch if you need four true adapters
* Make sure it is electrically compatible -- some cards support only 3.3V PCI operation
* While not an issue for full-size cases, make sure cards are short enough for shallow cases
* If the driver has a proprietary license, make sure the source complies in your target environment *first*

This roundup only covers gigabit PCI-compatible quad port cards. There are a number of options available for the PCIe bus (careful, many of these use more than one PCIe lane and won't work in an x1 slot!), and if you don't need gigabit ports on your router, there are several good quad port fast Ethernet adapters available for the PCI and PCI-X bus. Our fallback, had the Sun GigaSwift card not worked out, would have been the Sun Quad Fast Ethernet PCI Adapter (501-4366), which is a [hme(4)](http://www.freebsd.org/cgi/man.cgi?query=hme&sektion=4) based card and has been supported since FreeBSD 5.0.

{% counter :id => 'quadnic', :text => 'packets filtered' %}
