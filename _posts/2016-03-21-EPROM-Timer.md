---
layout: post
title: Quick EPROM Timer Script
topic: Controlling a relay with Ruby
category: programming
description: I was erasing a pile of UV EPROMs today and got tired of interrupting what I was doing to go unplug the EPROM eraser when 20 minutes had elapsed, so I made up a little cable to control one of my relay-switched outlets using the serial handshake lines on a serial port. A few lines of Ruby later and, problem solved!
image: ruby.png
---

{% danger :add_break => true %}
We're going to control something mains powered with a computer! In the case of my old, low-feature EPROM eraser, this means that if a [Bad Thing](http://www.catb.org/jargon/html/B/Bad-Thing.html) happens, the UV lamp could turn on which is potentially damaging to eyes and skin! Always unplug whatever you're controlling before working on it, **DO NOT DEPEND ON THE SOFTWARE/COMPUTER TO DO THE RIGHT THING!**
{% enddanger %}

I've got a cheap old EPROM eraser which simply turns on when you plug it in, and turns off when you unplug it (no safety interlocks, even!). Erasing EPROMs usually involves filling it up, plugging it in, and setting a kitchen timer or something for 20 minutes. The trouble is, you have to remember to unplug it when the timer goes off, which involves stopping what you're currently doing or forgetting about the EPROMs and overerasing them into uselessness. I've already built a number of [optoisolated relay switched outlets](/~glitch/2013/02/28/relay-board) for various projects, but didn't currently have a timer to control them. Enter Ruby!

{% codeblock :language => 'ruby', :title => 'eprom_timer.rb' %}
require 'serialport'
require 'ruby-progressbar'

SECONDS_TO_RUN = 20 * 60

port = SerialPort.new('/dev/ttyUSB0')
progress = ProgressBar.create(:title => 'EPROM Erase', :total => SECONDS_TO_RUN)
puts "Erasing for #{SECONDS_TO_RUN} seconds (#{SECONDS_TO_RUN / 60.0} minutes)..."

# Wired my cable for RTS == 0 == relay on
port.rts = 0

begin
  for seconds in 1..SECONDS_TO_RUN
    progress.increment
    sleep 1
  end
rescue SystemExit, Interrupt
  puts ' Caught interrupt, exiting...'
ensure
  port.rts = 1
  puts '...done!'
  exit
end
{% endcodeblock %}

(View [on GitHub](https://github.com/chapmajs/Examples/blob/master/eprom_timer.rb) for direct download)

Being as the relay controller was an optoisolated current loop, I just connected it to the RTS handshake pin on a USB -> RS-232 adapter. The RTS pin is typically used to signal to a connected device that the computer is ready to send some data. It, along with the other output handshake signals, can be used as a 1-bit output port under software control. The [serialport](https://rubygems.org/gems/serialport) gem allows us to control the handshake lines from Ruby with ease:

{% codeblock :language => 'ruby', :title => 'Controlling RS-232 Lines from Ruby' %}
require 'serialport'

port = SerialPort.new('/dev/ttyUSB0')
port.rts = 0 # Switch the relay on
port.rts = 1 # and back off again
{% endcodeblock %}

I added in a quick progress bar using the [ruby-progressbar](https://rubygems.org/gems/ruby-progressbar) gem. Its [documentation](http://www.rubydoc.info/gems/ruby-progressbar/1.7.5) covers both basic and advanced usage.

The control of the relay is wrapped in a `begin-rescue-ensure-end` structure, which captures `SIGINT` and `SIGTERM`. This makes sure that we turn the relay off if someone bashes CTRL+C or uses `kill`.

For wiring, simply use pins 4 and 7 (RTS and GND) on a DB-25, or pins 7 and 5 on a DB-9. You can stick a LED directly across them (they're current limited) to test. Since the RS-232 port reverses polarity between mark and space, you can reverse the connections to invert the action on the LED. Use a two-color, two-pin LED and try toggling the RTS pin if you're unsure.

{% counter :text => 'EPROMs ruined' %}
