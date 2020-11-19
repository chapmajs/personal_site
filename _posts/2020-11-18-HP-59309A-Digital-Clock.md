---
layout: post
title: Cleaning up a HP 59309A Digital Clock
topic: Cleaning up a HP 59309A Digital Clock
category: vintage-misc
description: HP produced a HP-IB connected digital clock, the 59309A, which was intended to serve as a clock/calendar for HP-IB (GPIB, IEEE-488) equipped computers or assemblies of test equipment. This one needed some cleanup and repair before being put into service.
image: hp_59309a_digital_clock_icon.jpg
---

{% linked_image :file => 'outside_before_repair.jpg', :alt_text => 'HP 59309A before repair' %}

The HP 59309A (HP museum entry [here](http://www.hpmuseum.net/display_item.php?hw=741)) is a digital clock that connects over HP-IB (GPIB, IEEE-488) to computers or test equipment assemblies. It was intended to provide clock/calendar functionality to computers, timing information to test equipment, etc. 

### Initial Check-Out

As received, the HP 59309A clock basically worked: there was some battery leakage on the motherboard, which had been disclosed. After running for about an hour, the date suddenly changed from `11 13` (13th of November) to `11 33` (an impossible combination in any date format):

{% linked_image :file => 'wrong_date.jpg', :alt_text => 'Incorrect date of 11-33' %}

After tracing the likely issue to a 74LS03 quad open collector NAND gate, the chip was replaced with no change. It was discovered that there was a film of high resistance corrosion over the edge connector contact connected to the 74LS03's pin 1 (sixth pin in from the right in the picture below). After cleaning the contact, the date displayed correctly:

{% linked_images :files => ['dirty_pin.jpg', 'fixed_date.jpg'], :alt_texts => ['Dirty pin on card', 'Correct date displayed'] %}

The original 74LS03 was reinstalled in the board.

### Full Cleaning and Repair

During initial check-out, the battery corrosion was found to be a little worse than the pictures from the seller reflected. There were also two RIFA line filter capacitors present, which had not yet failed but were cracking. The main filter capacitor was original and would get replaced since the clock had to be disassembled anyway.

Here's a picture of the "minor corrosion:"

{% linked_images :files => ['corrosion.jpg', 'board_removed_corrosion.jpg'], :alt_texts => ['Corrosion from a leaked 9V battery', 'Closeup of battery corrosion'] %}

After disassembly, the RIFA line filter capacitors were the first to go. They had not yet failed, but were cracking, which is the start of failure for them. Cracks allow moisture into the capacitor, which is constructed of foil and paper. As the paper dielectric absorbs moisture, it becomes conductive, and eventually gets hot enough to carbonize. Once enough has carbonized, there's a runaway overheating of the capacitor, which usually results in smoke and a blown-apart capacitor. Here's the originals, before and after removal:

{% linked_images :files => ['rifa_capacitors.jpg', 'rifa_cracks.jpg'], :alt_texts => ['Original RIFA capacitors', 'Cracks visible in RIFA capacitors'] %}

Both were cut out and replaced with WIMA Y2 rated safety capacitors, which are polyester film and should provide very long life:

{% linked_image :file => 'rifas_replaced.jpg', :alt_text => 'RIFA capacitors replaced with WIMA Y2 safety capacitors' %}

With the motherboard out, corrosion was neutralized with Superior #30 organic acid liquid flux. Superior #30 is mildly acidic and neutralizes corrosion (don't worry, it's safe for electronic work). It also aids in re-tinning bare copper traces once the corrosion has been stripped off. Fortunately, as with many HP boards of the era, this one is finished in gold, which resisted most of the corrosive efforts of the battery leakage. A new axial 2200uF 16V capacitor was installed for the main filter.

{% linked_images :files => ['motherboard_cleaned.jpg', 'battery_contacts_cleaned.jpg'], :alt_texts => ['Motherboard cleaned and recapped', 'Battery contact area cleaned and repaired'] %}

The main filter capacitor wasn't shorted, but it was quite old, the unit was apart anyway, and the bridge rectifier showed signs of running hot. Here's a picture of the bottom of the motherboard, showing discoloration under the bridge rectifier:

{% linked_image :file => 'board_under_rectifier.jpg', :alt_text => 'Discolored circuit board under rectifier' %}

The plug-in circuit cards were cleaned and reinstalled in the clock chassis:

{% linked_images :files => ['boards.jpg', 'reassembled.jpg'], :alt_texts => ['Plug-in circuit cards', 'Reassembled HP 59309A clock'] %}

With repairs complete, the HP 59309A clock was powered up and the date and time set:

{% linked_images :files => ['finished_front.jpg', 'finished_closeup.jpg'], :alt_texts => ['Repairs finished, from the front', 'Closeup of display'] %}

The 5V regulator and bridge rectifier now run cooler, though the regulator may get an additional external heatsink. HP-IB interface testing is next!

{% counter :text => 'clocks repaired' %}
