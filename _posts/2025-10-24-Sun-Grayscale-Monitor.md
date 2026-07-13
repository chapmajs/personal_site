---
layout: post
title: Sun 19 Inch Grayscale Monitor Cleanup
topic: Cleaning up a grayscale video monitor for Sun systems
category: sun
description: Sun supplied 19 inch grayscale monitors that were largely the same as their ECL offering, but with analog inputs. This one also required a cleanup and recapping, like the ECL version.
image: sun_ecl_monitor-icon.jpg
---

When I got my [Sun 3/50 system]({% post_url 2022-09-19-Sun-3-50 %}) from Guy Fedorkow, he put me in touch with a friend of his who had a 19" Sun monitor that he wanted to part with. The original hope was that the monitor was ECL, which would have worked with the Sun 3/50; however, it turned out to be a grayscale monitor. The Sun grayscale monitor's video input is analog, and completely incompatible with ECL, but works with a `bwtwo`.

While the grayscale monitor wouldn't work with the Sun 3/50, it was still useful to me, and I decided to use it with a 13W3 output `bwtwo` in my Sun SPARCstation 2. From my experience with the [Sun ECL monitor]({% post_url 2022-12-31-Sun-ECL-Monitor %}), I knew this one would also need recapped: the two monitors are virtually identical, *other than the video interface circuit!*

Step one was cleaning the monitor. It contained quite a bit of dust, both the regular kind and what appeared to be sawdust:

{% linked_image :file => 'dirty.jpg', :alt_text => 'Dirty Sun grayscale monitor' %}

With the filth out, the first board to get recapped was the video board:

{% linked_image :file => 'video_recapped.jpg', :alt_text => 'Recapped Sun grayscale monitor video board' %}

I actually recapped both monitors' video boards at the same time. The grayscale monitor showed cap leakage at the same position as the ECL monitor; however, the capacitor was a lower voltage rating. Presumably it was uprated at some point to increase longevity.

The power supply board was next for recapping:

{% linked_images :files => ['psu_original.jpg', 'psu_closeup.jpg'], :alt_texts => ['Power supply before recapping', 'Closeup of the electrolytic substituted on the power supply board'] %}

Just like the ECL monitor, the grayscale monitor's power supply appeared to have an electrolytic capacitor installed where a film capacitor had been designated. I replaced this one with a 4.7uF film capacitor as well:

{% linked_image :file => 'psu_recapped.jpg', :alt_text => 'Recapped power supply' %}

Finally, the interface board needed recapped:

{% linked_images :files => ['interface_board.jpg', 'interface_closeup.jpg'], :alt_texts => ['Grayscale monitor interface board', 'Closeup of interface board'] %}

This is the only difference between the grayscale and ECL models of this monitor. It is of course *substantially different*, though not much more complex than the ECL interface board. It did include a high frequency transistor in a neat package:

{% linked_image :file => 'hf_transistor.jpg', :alt_text => 'High frequency transistor on the interface board' %}

The grayscale interface board included a 47uF 16V bipolar electrolytic capacitor, which was replaced with a multilayer ceramic capacitor (MLCC):

{% linked_images :files => ['mlcc_and_bipolar.jpg', 'mlcc_installed.jpg'], :alt_texts => ['Bipolar electrolytic next to MLCC replacement', 'MLCC installed on interface board'] %}

I usually replace bipolar electrolytics with film capacitors; however, there was not enough room on this board for that swap. I was initially concerned about using a MLCC, but the monitor performs as it should with this substitution.

This completed the recap of the interface board:

{% linked_image :file => 'interface_recapped.jpg', :alt_text => 'Recapped interface board' %}

With everything cleaned and recapped, the monitor was reassembled in reverse. As with the [Sun ECL monitor]({% post_url 2022-12-31-Sun-ECL-Monitor %}), there are a number of screws that should not be fully removed, as they mount in keyholes in the chassis, and are easier to work with when left partially installed.

This monitor now lives with my SPARCstation 2.

{% counter :text => 'monochrome monitors repaired' %}
