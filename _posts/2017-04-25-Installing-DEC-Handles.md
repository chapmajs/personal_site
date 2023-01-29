---
layout: post
title: Installing DEC Handles
topic: Installing DEC Handles
category: dec
description: Many DEC cards and modules use plastic extractor handles. These handles can become damaged, and some cards (new made prototype boards, for example) often come with no handles. DEC attached them with tubular hollow rivets, while most hobbyists are stuck with pop rivets or bolts. Here's how to properly rivet handles on!
image: dec_handle_icon.jpg
---

DEC handles are little plastic extraction handles used on many DEC modules, cards, and assemblies. They should be familiar to all QBus, Unibus, and Omnibus hackers. DEC riveted them on for production cards, but some third-party manufacturers and most hobbyists use pop rivets or bolts. I've got a number of boards with bolted-on handles, some are DEC cards with damaged handles, some are prototype boards that never came with handles, and others, like this XYlogics Unibus grant continuity card, seemed to optionally come without handles:

{% linked_images :files => ['xylogics_bolted.jpg', 'xylogics_bolted_closeup.jpg'], :alt_texts => ['XYlogics grant card', 'XYlogics closeup'] %}

This card came to me with no handle installed, though it did have holes for mounting one. I had originally bolted on a white handle, removed from a scrapped Sundstrand CNC control board, using 4-40 machine screws and nuts. On acquiring a larger lot of Sundstrand boards to salvage and rework, I decided to locate appropriate brass tubular hollow rivets to attach DEC handles. The originals are 1/8 inch, but it turns out that a metric M3 x 5mm rivet is close enough. These can be purchased cheaply in quantity on popular online auction sites. Mine came from China, 200 rivets for $6 USD, shipped:

{% linked_images :files => ['rivets.jpg', 'rivets_closeup.jpg'], :alt_texts => ['Pack of rivets', 'M3 x 5mm rivets'] %}

Tubular rivets are typically set with a rivet set. I didn't have one, so for a while I used small steel ball bearings from a wrecked bearing. This worked fine. I eventually found the right tool, a small Indestro rivet set. This tool looks like a tiny arbor press, except you strike the tool with a small hammer rather than pressing down on a lever. This is the Indestro rivet set I've got, along with two M3 x 5mm rivets and a green DEC handle:

{% linked_image :file => 'indestro_tool.jpg', :alt_text => 'Indestro rivet set' %}

The tool is itself vintage, and as luck would have it, it came with a setting tool close enough for M3 rivets! With the Indestro tool, hollow rivets, and a proper green handle for the XYlogics grant card, it was time to get rid of the 4-40 screws:

{% linked_images :files => ['handle_installed.jpg', 'handle_installed_closeup.jpg'], :alt_texts => ['XYlogics riveted', 'XYlogics riveted closeup'] %}

Where did the green DEC handle come from? An EMM static RAM card that came in a pile of board scrap. Someone had already sheared off the edge connectors, so it was doomed to the parts heap anyway. Aside from SEMI4200 static RAMs, it had DEC bus tranceivers and four somewhat faded green DEC handles, like this one:

{% linked_image :file => 'green_handle.jpg', :alt_text => 'Green DEC handle' %}

{% counter :id => 'dec_handles', :text => 'handles installed' %}
