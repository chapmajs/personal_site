---
layout: post
title: Sabernetics I2C OLED Display Testing and Demo
topic: Exercising the Sabernetics I2C OLED Display with the Bus Pirate
category: news
description: The Kickstarter-funded Sabernetics Technology OLED Display arrived yesterday. Before committing it to a project, I wanted to ensure the display was functional and get a feel for its daylight readability. The Bus Pirate was the obvious choice for prototyping.
image: glitch.jpg
---

Well, it's finally here! The [Sabernetics Technology OLED Display](http://sabernetics.com/store/0-84-oled-display-96x16/) (another successful Kickstarter hardware project) arrived Monday, but due to a SNAFU with the post carrier, I received a package slip rather than a display. Wednesday afternoon, the display was retrieved from the post office. I bought the display with a particular project in mind, but wanted to test it and make sure it was appropriate for the project before committing it. Fortunately, [Enable Labs](http://www.enablelabs.com) gives all employees five hours per week to work on personal projects, so getting the display tested and exercised was possible despite a busy home schedule.

The Hardware
------------

The tool of choice, at least within my toolkit, for experimenting with serial bus devices is the [Bus Pirate](http://dangerousprototypes.com/docs/Bus_Pirate). The actual unit I own is Version 3.5 hardware and was produced by Seeed Studio from one of [Dangerous Prototypes](http://dangerousprototypes.com/)' designs. In addition to being very useful for rapid prototyping, the Bus Pirate is open-source (both hardware and software) and carries a Creative Commons [CC-0](http://creativecommons.org/publicdomain/zero/1.0/) for the hardware design and GNU [GPL](http://www.gnu.org/licenses/gpl.html) for the bootloader.

The Bus Pirate interface is a FTDI USB -> Serial UART and is compatible with a majority of operating systems that support USB. In particular, it's fully compatible with Linux and various flavors of BSD, which makes it a useful tool when paired with my Linux-based workstations. Connecting to the USB UART with a terminal program such as minicom or GNU Screen provides an interactive console interface through which you can poke and prod the various supported serial interfaces. While the Bus Pirate does support a binary command mode, you can also poke at it with a stream of properly-paced ASCII commands in your favorite programming/scripting language.

Making the Connections
----------------------

Fortunately, due to the flexible designs of both the OLED module and the Bus Pirate, no additional hardware is required to interface the two. Both devices use standard 0.1" spaced square pins for interface headers, so I chose to make the connections between the two using wire wrap. I've got the tools and wire on hand, so wire wrap tends to be quicker for these interfaces, and doesn't require dragging the soldering station to work!

{:.center}
[![Bus Pirate connected to OLED Display](/images/general/oled/scaled/connections.jpg)](/images/general/oled/connections.jpg)

Connections between the OLED module and Bus Pirate are pretty straightforward:

		 +5V pin on OLED module ->  +5V pin on Bus Pirate
		   D pin on OLED module -> MOSI pin on Bus Pirate
		   C pin on OLED module ->  CLK pin on Bus Pirate
		/RST pin on OLED module ->  AUX pin on Bus Pirate
		 GND pin on OLED module ->  GND pin on Bus Pirate
		 VPU pin on Bus Pirate  ->  +5V pin on Bus Pirate

VPU is tied to +5V for the internal pullups on the Bus Pirate. The AUX pin is being used to reset the OLED display module. The OLED module's /CS pin can be left floating if it isn't needed; otherwise, pull it low to activate the module.

Preliminary Testing
-------------------

Preliminary testing was done via minicom under Linux. Connecting to the USB UART (/dev/ttyUSB0 if it's the only USB UART on your Linux box) at 115200 kbps lets you manually interact with the Bus Pirate. Follow the [Bus Pirate I2C Guide](http://dangerousprototypes.com/bus-pirate-manual/i2c-guide/) for general setup. The Sabernetics OLED module is located at I2C address 0x78 for writes by default. The following sequence will reset the device and prepare for writing into Page 1 (the RAM page nearest the pin connector):

		[0x78 0x00 0x10 0x40 0x81 0x7F 0xA1 0xA6 0xA8 0x0F 0xD3 0x00 0xD5 0xF0 0xD9 0x22 0xDA 0x02 0xDB 0x49 0x8D 0x14 0xAF]

As per the usual Bus Pirate I2C syntax, open bracket ([) places the I2C bus in the I2C start condition. 0x78 specifies the I2C write address. After that, we send a series of commands to set things like the contrast, DC-DC converter, internal oscillator and display offset to sane values. A very detailed description of the SSD1306 OLED controller is available from [Adafruit Industries](http://www.adafruit.com) at [this link](http://www.adafruit.com/datasheets/SSD1306.pdf).

At this point, we can begin writing bytes into the display's RAM. We've initialized the display in non-inverse mode, so a 1 at a location in a byte will correspond to an "on" pixel. Since display RAM has not been initialized, there will be a random scattering of lit pixels across the display. The following Bus Pirate command will create a 5x8 glyph of alternating on and off pixels:

		[0x78 0x40 0x55 0xAA 0x55 0xAA 0x55]

Again, this follows standard Bus Pirate I2C syntax. Command 0x40 tells the SSD1306 controller that we want to write to display RAM. The following bytes are written to sequential addresses in the active Page of RAM, as the RAM pointer is automatically incremented on writes. Here's the result:

{:.center}
[![Initialized Display with Test Pattern](/images/general/oled/scaled/inittest.jpg)](/images/general/oled/inittest.jpg)

At this point, we can be pretty certain that our display actually works. However, since it's easy to interface to the Bus Pirate with a scripting language, why not push a few more bytes to the display?

A Python Demo Script
--------------------

Scripting the commands to the Bus Pirate requires talking to the USB UART. Since it's really just a standard UART that happens to have a USB interface on one end, most existing serial communications libraries can be used to fill this need. I chose Python with the pySerial package because I'm already familiar with its syntax. A few things to keep in mind:

 * Send a newline ('\n') character after each command string, just as if you hit Return on the keyboard
 * The script will send data much faster than a human, you'll need to include a pacing delay (50 mS seems to be plenty)
 * If using a UNIX-like OS, you can "tail -f /dev/ttyUSB0" and get a read-only view of what's going to the USB UART
 * The display is bitmapped, sending it ASCII will only result in the binary representation being displayed

I threw together a quick script to dump two bitmaps to the two available RAM pages. That script is available from my [GitHub Examples repository](https://github.com/chapmajs/Examples/blob/master/display_test.py). I've tested it under Arch Linux x86_64 and i686 with Python 3.2.3 and pySerial 2.6-2 from the Arch Linux pacman repositories. The two bitmaps align to render the [Enable Labs](http://www.enablelabs.com) logo and a message. Here's the output:

{:.center}
[![Bus Pirate and Display after running Python script](/images/general/oled/scaled/buspiratedisplay.jpg)](/images/general/oled/buspiratedisplay.jpg) [![Hello from Troy NY!](/images/general/oled/scaled/hello.jpg)](/images/general/oled/hello.jpg)

Final Thoughts
--------------

The Sabernetics OLED module was definitely worth the $24.95 and just goes to show that funding for neat electronics projects is possible for hobbyists. The display module chosen seems to be of high quality, and produces a sharp, sunlight-readable image with minimal external hardware (by the way, the display is similar to the blue Kynar wrapping wire, but it comes out white in pictures!). Testing with the Bus Pirate is easy and scriptable, and allows one to verify complete display operation before committing it to a project. For integration into projects with a larger production quantity, the bare display modules can be purchased separately and interfaced directly with the project, reducing cost and overall board size. The choice of I2C protocol is a definite win if the OLED module is to be used with a modern microcontroller.

{% counter :id => 'oled', :text => 'happy Kickstarter backers' %}
