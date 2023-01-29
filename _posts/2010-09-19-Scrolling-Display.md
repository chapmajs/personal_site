---
layout: post
title: Scrolling LED Displsy
topic: A scrolling LED display with the 8085 SBC
category: i8085
description: Interfacing a PDSP-1881 LED character display with the 8085 SBC. I wrote software to scroll a message across the display for the 2010 Maker Faire in NYC, utilizing a circular array and FIFO.
image: scroller-icon.jpg
---

Now that the 8085 SBC had been converted to a printed circuit board and tested, it was time to build a perihiperal board! With the 2010 Maker Faire in NYC approaching, I decided something visual that could be shown off at the M.A.R.C.H. table. A LED scrolling sign seemed relevant, doubly so as I could reuse the output routines for future projects.

{% linked_image :file => 'closeupdisp.jpg', :alt_text => 'Close-up of LED display' %}

Recognize the display? It's the Siemens PDSP-1881 from the original point-to-point 8085 prototype! This one was pulled from the board, but I have several in the event that I should want to use the original again. The PDSP-1881 is a yellow 8-character LED display with full ASCII decoding. It's covered with a red filter in these images because the camera doesn't want to focus on the plain display, and when it does the brightness of the exposed LED dice washes out the rest of the image. It's an easy display to interface with, requiring /CS, /WR, address and data lines. I don't use any of it's advanced features like software-controlled brightness or Flash RAM, so the A3 and A4 lines are tied directly to +5 V (don't forget to do this if they're unusued -- I made that mistake, which will result in very erratic operation!).

I originally breadboarded the display to the 8085 SBC using a 40-pin female IDC socket soldered to the SBC's 40-pin expansion connector. This allows one to insert breadboarding wire into the socket just as with a breadboard. It will also allow a stacking connector or IDC male header to plug into the SBC. I wanted to leave the pins accessible for further experimentation, so I built my own stacking connector using extra-long breakaway SIP sockets. These are meant as a "build your own" socket system, and are cheaply available over the Internet. They work perfectly in this application -- after being soldered to a piece of perfboard, you can plug the perfboard into the SBC's expansion connector and still connect wires to the SIP sockets.

{% linked_image :file => 'perfboard.jpg', :alt_text => 'Prefboard with long pins' %}

I/O space address decoding was done using a 74LS138, which gives us 8 segments of 32 ports each. This is sufficient for our application; and besides, other boards on the bus are free to decode I/O space as they wish! The 8085's multiplexed bus is interesting in that during an I/O access, the 8-bit address is mirrored on the high address bits. This means that no address latch is needed for I/O with the 8085. That's why the 8085 SBC brings out the multiplexed address/data bus and the /ALE lines -- most perihiperal boards will never need address demultiplexing, as they should contain I/O devices rather than memory devices. Such is the case with this board, and the three high address bits are taken from the upper address byte of the 8085's bus -- A13, A14, and A15. One of the '138's /CE lines is connected to the 8085's IO/M line though an inverter. The inversion wasn't necessary, since the '138 has a CE (non-inverting enable) pin, but was done as to buffer the IO/M signal.

{% linked_images :files => ['displaybd-front.jpg', 'displaybd-back.jpg'], :alt_texts => ['Display board components', 'Display board wiring'] %}

The '138's Y0 output drives the PDSP-1881's /CE line. The 8085's /WR line drives the /WR line of the display. All that's left is to handle resets: the PDSP-1881 requires a reset after power-on to restore it to a known state. Conveniently, this default state is the mode in which we want to operate, so resetting the device keeps us from having to send commands to the display! I soldered a wire between RESET OUT on the 8085 (pin 3) and pin 4 of the SBC's expansion connector, which is unusued. This gets inverted on the display board, and fed into the /RESET input of the display. I'll probably make an effort to bring the RESET OUT line down to the expansion connector on future revisions!

{% linked_image :file => 'resetfix.jpg', :alt_text => 'Bringing RESET OUT to the connector' %}

With the hardware done, it's time to write software to drive the display board. Of course, the software is the difficult part! Since my UV eraser was still in Virginia at the moment, I decided to make a "wedge" adapter socket to allow the use of a SEEQ DQ52B13 EEPROM in the 2764/27128 PROM socket on the SBC. The 52B13 is compatible with the 2816 (my iUP-201 will program it as such), and pin-compatible with the 2716. This made creating the wedge socket easy: just bend pins 24 and 21 up on a standard 24-pin DIP socket, solder a wire to them, and connect it to +5 V. Insert the EEPROM into this socket, and insert the socket against the back of the 28-pin PROM socket on the SBC:

{% linked_image :file => 'eeprommod.jpg', :alt_text => '2716 EPROM adapter' %}

This works just fine, and allows me to make revisions to the code without worrying about running out of blank EPROMs. In the next revision of the 8085 SBC, I'll add jumpers to allow the installation of 2716, 2732, 2764 or 27128 devices in the PROM socket without modification to the board. Just change a few jumper positions and you can use what you have on hand!

Getting a message to scroll across the screen in the manner I wanted wasn't as easy as one might assume. First of all, I wanted to be able to continuously loop message, as with a marquee. This required the use of a [circular array](http://en.wikipedia.org/wiki/Circular_buffer); that is, an array whose tail links back to its head. This is a trivial task in higher level languages, even if one has to design their own linked list. However, I'm writing my code for the 8085 SBC in 8080 Assembly! Even so, the task wasn't too difficult (albeit not dynamic) and didn't require a lot of code:

{% codeblock :language => 'nasm', :title => 'Circular Array in 8080 ASM' %}
;Circular Array Implementation
;Return with the next value of the array in A.
;If we reach the end, loop back around.
ARRAYNEXT: PUSH H 
           LHLD STRINGPTR
           MOV A, M
           CPI 00h
           JZ WRAP
           INX H
           SHLD STRINGPTR
           POP H
           RET
WRAP:      LXI H, STRING
           SHLD STRINGPTR
           CALL ARRAYNEXT
           RET
{% endcodeblock %}

What this gives us is a sort of get_next() function for our null-terminated character array. All we need to do is define STRINGPTR with an equate to a free memory location, and define STRING as the starting memory address of our null-terminated string. I chose 0x2000 for STRINGPTR, the first address at the bottom of the SBC's RAM. STRING was assigned 0x0400, a block of the 2K EEPROM that contained my null-terminated string.

Calling ARRAYNEXT starts off with the HL register pair being pushed onto the 8085's hardware stack. We do this because HL is modified in the function, and it's good practice to preserve registers you might not intend to modify in your calling function. We then load HL with the current pointer to our position in the STRING, using STRINGPTR. Using that pointer, we grab the character at its current location. If it's nonzero, we're not at the end of the array yet, so we increment the pointer in HL and then save it back into RAM. Since we're done with HL in ARRAYNEXT, we can pop its old value off the stack. Then we return to the calling function.

If the value we load from STRINGPTR is zero, then we've reached the end of the array and we need to loop back to its head. Since we've already got the starting location of the array assigned to STRING, we can just move STRING to HL, store it as the new STRINGPTR, and do a recursive call to ARRAYNEXT. After ARRAYNEXT returns, we return as well, with the first value of STRING in A and HL restored to its previous value.

Do note that while this implementation works fine in our case, it has a few shortcomings. An easy one to fix is that of reusability: it's hardwired to rely on STRINGPTR and STRING. We could easily solve this by terminating our circular array with a null, followed by the high and low bytes of the head address, and passing the current array index pointer to the function preloaded in HL. The second problem would require a little more work: if the array contains a null value at its head, or is a string of length 0, the recursive call will get stuck in a loop!

To get the message to scroll smoothly, one character at a time, it was necessary to devise a way to obtain a "sliding window" sample of the string. The window is 8 bytes wide, as that's the width of our character display. As the window moves along the string, it grabs the next character to display and pushes the characters currently in the window down by one, with the first character being pushed out of the window. Sound familiar? It's similar to the function of a First In, First Out, or FIFO, buffer. Our case is slightly different in that we don't care about the character coming out, and we want to dump the entire buffer to the display after a new value has been enqueued.

{% codeblock :language => 'nasm', :title => 'Display Scroll Routine' %}
;Shift the contents of the data buffer down one
;and replace the last character with the next char
;from the circular array.
SHIFT:  LXI H, BUFF     ;buff*
        MOV B, H        ;buff* + 1
        MOV C, L
        INX B   
        MVI D, 07h      
SH1:    LDAX B
        MOV M, A
        INX H
        INX B
        DCR D
        JNZ SH1
        CALL ARRAYNEXT
        MOV M, A
        RET     
{% endcodeblock %}

The critical code in our FIFO can be found in the SHIFT function. What shift does is start at the beginning of the buffer, which is simply a block of memory allocated for the purpose, and shift each value down one position in the buffer. That is, array[1] becomes array[0], array[2] becomes array[1], and so on, until we reach the last position in the buffer. When we get to the last position, as determined by the count in register D, we then need to get the next character from the string and put it in this position. Fortunately, we've already got ARRAYNEXT to both get the next character and deal with wrapping the array around when we get to its end!

SHIFT accomplishes this by loading HL with a pointer to the start of the buffer (BUFF in our case, equated to 0x2004). We then copy HL into BC, and increment BC: this gives us our next position in the buffer. The D register holds our count as to the positions we've shifted down in the buffer, and is fixed at 0x07 for our 8-character display. SHIFT then repeatedly grabs the next position in the buffer and places it in the current position, decrementing D each time and breaking its loop when D == 0. At that point, we call ARRAYNEXT, move the contents of the A register (which now contains the result of ARRAYNEXT) into the address pointed to by HL, and return. Note that if ARRAYNEXT didn't preserve HL before modifying it, and restore it at the end of operation, our SHIFT function wouldn't work as it is!

Of course, the SHIFT function could be further genericised: passing the pointer to the buffer to it preloaded in HL wouldn't be a problem since BC is loaded by copying HL. Getting SHIFT to play well with a genericised ARRAYNEXT would be a little bit of a trick...perhaps we could avoid a direct call to ARRAYNEXT and have SHIFT take its new tail value from a value passed in loaded in the E register. This would require the calling function to preload E with the next character from ARRAYNEXT, but that wouldn't be much of a cost.

The rest of the FIFO implementation is straightforward: a CLEAR method to preload the buffer with a defined byte at every position (we used 0x20, ASCII space, so that the display initializes as blank), and a UPDATE method to dump the entire buffer to the character display. The only other function is the DELAY function I wrote for the SOD blink test. You can find the entire Assembly source for the LED scroller [in the Glitch Works File Dump](http://filedump.glitchwrks.com/8085projects/files/charscroll.asm).

The code was once again assembled with GNUSim8085 and manually programmed into my Intel iUP-201 PROM Programmer -- I really need to get a serial transfer program written for it! The project will get a few modifications before being displayed at the Maker Faire, but you can watch a video with a brief explanation:

<div class='center'><iframe width="560" height="315" src="https://www.youtube.com/embed/P9A4H4YBX-Q" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>

Seeing the display's scroll pattern will help demonstrate the exact function of the FIFO and circular array.
