---
layout: post
title: Homebrew Counter with Nixie Tubes
topic: Checking out a small homebrew counter with Nixie tubes
category: test_equipment
description: A little homebrew or shop built counter with Nixie tube readout. This counter has been in the glow discharge project bin for a while, let's take a look at it.
image: homebrew_nixie_counter-icon.jpg
---

I bought this little counter around 15 years ago. I think it came from either the Virginia Tech Surplus Auction, or a local flea market. It's clearly homebrew or maybe shop built:

{% linked_image :file => 'counter.jpg', :alt_text => 'Homebrew counter with Nixie tube readout' %}

It's about as basic as you can get! Build quality is pretty good, considering it's not a commercial product. It's strictly an event counter, as it has no internal timebase. The input is TTL, and runs directly to the first counter stage. Reset is not debounced, and often falsely triggers at least one stage, requiring a few presses to zero.

The heart of the unit are the little printed circuit counter modules:

{% linked_image :file => 'module.jpg', :alt_text => 'Counter module' %}

As seen, these modules contain the counting and display logic, a Burroughs B-5750S Nixie tube, a capacitor, and the 22K anode limiting resistor. Logic consists of 7400 series parts, from top to bottom:

* 7490 decade counter
* 7475 4-bit latch
* 7441 Nixie tube driver

The modules appear to be built on manufactured circuit boards. They contain the text `Diceon` and/or `GILFORD U.S.A.` Diceon Electronics Inc. appears to have been a manufacturer of printed circuit boards (they also seem to have dumped hazardous waste and [created an EPA superfund site](https://cumulis.epa.gov/supercpad/CurSites/csitinfo.cfm?id=0101100)). I can't find any particular information on these modules, but I wouldn't be surprised if they were offered as a hobbyist "build your own counter" type kit. The names are visible in the following pictures:

{% linked_images :files => ['diceon.jpg', 'gilford.jpg'], :alt_texts => ['Diceon marking', 'Gilford U.S.A. marking'] %}

Whoever built this did a pretty decent job! The chassis appears to be handmade, formed with a sheet metal brake. The somewhat unusual fuse post on the front holds a Littelfuse miniature bi-pin device. Here's a shot of the underside:

{% linked_image :file => 'underside.jpg', :alt_text => 'Underside of homebrew counter' %}

The counters are bussed, except for the carry input/output pins. The power supply is transformer based, so there's no AC line rectification. Anode supply is half-wave rectified and filtered with a 3uF 200V Sprague oil filled capacitor, a very nice part for the application!

+5V rectification is full bridge, with a 4000uF 15V Sprague computer grade capacitor mounted in a clamp on top of the chassis. There's a TO-3 regulator for the rail, but if one looks closely at the top-left of the chassis in the above picture, you can see that the regulator is not in circuit! I suspect there was not enough voltage overhead for the regulator to keep in-regulation, which may be something that happened as the bulk capacitor aged.

The card slots for the counter modules are clearly cut down from larger connectors. They bolt to the chassis with the usual mounting lug on the end closest to the front of the chassis, but the back end is blocked against a piece of aluminum angle stock. They're not really secured on the back end, just jammed against the aluminum angle.

The spacing on the five-way binding posts is correct for fixed-spacing banana plug adapters, such as a Pomona dual banana plug to BNC:

{% linked_image :file => 'binding_posts.jpg', :alt_text => 'Binding posts with Pomona BNC adapter' %}

The counter does work, sort of. I brought it up on the variac and connected the Krohn-Hite 5100B function generator to the input. Since the counter is direct TTL input, I used the 5100B's 5V square wave output. One of the many nice features of the 5100B is that it can generate very low frequency outputs. Here's a video of the counter running:

<div class='center'><iframe width="560" height="315" src="https://www.youtube.com/embed/pPUAP9k6lxU" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe></div>

As seen above, two of the modules don't work, and two have very dark glass. There's also an extra card slot for a sixth counter module, which was not populated when I got this counter. The modules were shuffled to put the good digits at the right.

The two leftmost modules are not functional: the far left does not light at all and does not pass count, and the next one over is stuck displaying `9` and also does not pass count.

The middle module has some issues, it seems that either some of the 7441 Nixie driver outputs are shorted/leaky, or that the Nixie tube has an internal short. The module does still count though.

Due to the limitations of this counter (it's a TTL level event counter only), two of the modules being bad, and the missing module, it will likely become parts for something else. There are just too many problems to justify repair. For practical use, it'd require power supply repair (at least a new capacitor and figuring out why the regulator is bypassed, maybe a new transformer if there's not enough overhead for +5V), repair of the bad modules, a proper reset circuit, and a more useful/resilient input topology.

{% counter :text => 'pulses counted' %}
