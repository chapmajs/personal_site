---
layout: post
title: Shiva LanRover/E PLUS
topic: Shiva LanRover/E PLUS Repair and Setup
category: vintage-misc
description: The Shiva LanRover/E PLUS is a fairly standard remote access/dialin/dialout/terminal server from the 90s. It requires firmware loads from the network but fortunately those files have been preserved! Let's take a look at some minor cleanup and repairs, and what it takes to bring up the LanRover/E PLUS.
image: shiva_lanrover-icon.jpg
---

We found this old Shiva LanRover/E PLUS in some of the networking leftovers at the old ITI Audio/Sontec building:

{% linked_images :files => ['front.jpg', 'back.jpg'], :alt_texts => ['Shiva LanRover/E PLUS, front', 'Shiva LanRover/E PLUS, back'] %}

It's a pretty typical remote access server from the early 90s. These devices typically allow serial and/or modem connections in, sometimes out, and support a handful of common LAN and WAN protocols of the era. The main features of the LanRover/E PLUS are:

* Supports interface cards for async and sync serial connections
* Supports integrated modem cards
* Serves terminal sessions for local or remote serial terminals
* Can allow dialout from the Ethernet through a serial port/modem
* Talks PPP and SLIP over established connections
* Can Telnet or RLOGIN from established sessions
* Talks TCP/IP, IPX, and AppleTalk over the Ethernet port
* Allows local and RADIUS authentication
* Supports some sort of LAN-to-LAN bridging

The interfaces can be mixed and matched per slot, and the LanRover/E PLUS supports eight interface cards. Non-modem cards support DE9 and RJ45 serial connections. Modem cards have a RJ11 jack for direct connection to a phone line.

Like many small devices of the era, the LanRover/E PLUS loads its firmware over Ethernet. This means that the unit is useless without a server to load firmware from, and the firmware files themselves. Fortunately, [dosdude1 on YouTube](https://www.youtube.com/user/dosdude1) has the firmware, and has made the files available through his website. He's also done [a video on configuring the LanRover/E PLUS](https://www.youtube.com/watch?v=MvpJA80VgVk):

<div class='center'><iframe width="560" height="315" src="https://www.youtube.com/embed/MvpJA80VgVk" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div>

The above video contains links to the firmware files and configuration tools in its description. dosdude1 uses the Windows 9x utilities that Shiva provided to both bootload and configure the LanRover/E PLUS. We'll be doing it another way.

### Cleanup and Repair

This LanRover/E PLUS had been in storage for quite some time. Burgess didn't remember buying it in particular, and said it may have been a leftover from some larger lot of networking equipment, or perhaps from his stretch of doing [Novell NetWare](https://en.wikipedia.org/wiki/NetWare) installations as a side-business. In any case, it was pretty dirty, and got a cleanup and going-through.

The system disassembled easily, with two #1 Philips screws holding the top of the case on, located on the sides of the chassis. Inside, there's a motherboard, power supply, and up to eight interface cards. As seen from the back, this unit has seven cards with DE9 connectors, and one modem card with a RJ11 connector:

{% linked_image :file => 'ports.jpg', :alt_text => 'LanRover/E PLUS ports' %}

Each card was removed and cleaned up. There was some light surface oxidization on the DE9 connectors, which was removed with a wire brush. Mostly the cards just required dust removal. Here's the modem card:

{% linked_images :files => ['modem.jpg', 'modem_closeup.jpg'], :alt_texts => ['Shiva V.34 modem module', 'Shiva V.34 modem module, closeup'] %}

This is a typical Rockwell V.34 modem chipset, laid out to conform to the Shiva interface card form factor. From the chip dates, this one is probably original V.34, which should mean a top speed of 28.8 kbps.

Here's one of the seven identical serial interfaces:

{% linked_images :files => ['sync_serial.jpg', 'sync_serial_closeup.jpg'], :alt_texts => ['Shiva sync serial board', 'Shiva sync serial board, closeup'] %}

Note that this one is marked as sync serial. Both sync and async were available. These happen to be RS-232, I don't know if different signaling standards were available. As seen above, these modules use 16C550 UARTs, which are commonly found in PC compatible systems, though nowadays they're usually embedded in a southbridge, or present on a PCI/PCIe card.

These sync serial cards work fine in async mode, as well. There's a configuration flag for sync, which defaults to false.

The power supply cover was removed, and the power supply checked for leaking capacitors and RIFA line filter capacitors:

{% linked_image :file => 'power_supply.jpg', :alt_text => 'Shiva LanRover/E PLUS power supply' %}

No apparent problems here. Do note that while the mainboard connector looks like a Molex drive plug, it carries a negative rail, too. *Do not attempt to power a LanRover mainboard with a PC power supply Molex connector!*

The LanRover/E PLUS contains a 1/2AA 3.6V lithium battery, which was of course dead:

{% linked_image :file => 'old_battery.jpg', :alt_text => 'Dead 3.6V lithium battery' %}

One could probably snip the battery free and solder a holder to the stubs without removing the mainboard from the chassis, but I ended up removing it to attach a holder properly. To do so, there are several screws holding the mainboard down, one of which also holds the power supply shield. The back plate that holds the network connectors must come off, there are two screws and a plastic expanding fastener holding it on. The mainboard can then be wiggled free from its DIN connector and carefully maneuvered out of the chassis, without removing the interface backplane.

The battery present in this unit is soldered, though it does look like the footprint may accommodate some model of 1/2AA holder. I don't know what part is supposed to fit there, but we do stock Eagle 1/2AA holders with flying leads, which were made to work with a little epoxy:

{% linked_images :files => ['holder_positive.jpg', 'holder_negative.jpg'], :alt_texts => ['Battery holder, positive side wiring', 'Battery holder, negative side wiring'] %}

It's a little tough to see (click to make larger), but the hole in the holder for the positive lead lines up perfectly with an existing hole in the circuit board. The negative lead attaches easily to the second negative pad. If you go this route, cut/strip/solder the negative lead first. Once that's soldered, apply some epoxy to the circuit board under the holder. Finally, thread the positive lead through the board, press the holder into the epoxy, and let it cure. The epoxy will flow up through the holes in the holder and down through the holes in the PCB, creating a very strong attachment. Here's a look from the bottom:

{% linked_image :file => 'holder_bottom.jpg', :alt_text => 'New battery holder, from the bottom' %}

The middle holes are clearly filled with epoxy, which is good. The positive lead can be bent over and soldered to the positive terminal, as seen. Now, a new battery can be easily inserted and removed. It should be removed if the LanRover is going to be switched off for a long time. Use a high-quality hermetically sealed lithium thionyl chloride cell: junk cells leak and destroy equipment! Just ask any classic Mac owner. We stock Tadiran TL-5101 cells:

{% linked_image :file => 'new_battery.jpg', :alt_text => 'Tadiran TL-5101 installed' %}

That completes cleanup and repair of the LanRover/E PLUS. On to making it actually do something!

### Loading Firmware and Configuration Files

dosdude1's video contains information on using Shiva's Windows 9x tools to both load firmware and configure the LanRover/E PLUS. That's fine, and likely the most common way it was done when these were current hardware, but I wanted to try loading firmware from a \*NIX host. This would allow loading from a boot server, rather than having to start up a Windows 9x machine every time I wanted to use the terminal server and it had been switched off. Fortunately I'd just [cleaned up an old VA Linux server](/~glitch/2022/10/27/va-linux-server), which would work fine for the purpose!

The firmware archives found on dosdude1's site included some marked as UNIX-compatible, which contained a text file that explains some of the file naming conventions, and which files are used for what, along with the Shiva products they apply to. It is also mentioned that BOOTP and TFTP are used by the LanRover to download firmware.

LanRover boot involves loading the VROM image, the actual operating system image, and a configuration file. The VROM and OS images are in [Motorola S-Record format](https://en.wikipedia.org/wiki/SREC_(file_format)), and the configuration file is plaintext. None of the archives provide an example configuration file.

The text file includes information about naming files; however, I could not get the LanRover to pull files based on its hostname. I ended up sniffing the Ethernet to figure out what the LanRover was looking for.

### BOOTP Configuration

Having sniffed the startup process, I discovered the LanRover was looking for something to talk to on IPX, AppleTalk, and finally TCP/IP. It was sending BOOTP requests, which can be answered by many DHCP servers, as DHCP is effectively a superset of BOOTP. NetBSD ships with the [ISC DHCP daemon](https://man.netbsd.org/dhcpd.8), which does support BOOTP mode. The following is how I've configured ISC DHCPd to boot the LanRover:

{% textblock :title => '/etc/dhcpd.conf' %}
# ISC DHCP server config for booting Shiva LanRover

deny unknown-clients;
ddns-update-style none;

allow bootp;

subnet 192.168.0.0 netmask 255.255.255.0 {
        
        group {
                option broadcast-address 192.168.0.255;
                option domain-name "example.glitchworks.net";
                option domain-name-servers 192.168.0.1;
                option routers 192.168.0.1;
                option subnet-mask 255.255.255.0;

                host shiva {
                        hardware ethernet 00:80:d3:c0:ff:ee;
                        fixed-address 192.168.0.253;
                        option host-name "shiva";
                        next-server 192.168.0.254;
                }
        }
}
{% endtextblock %}

The above block configures ISC DHCPd to hand out leases only to hosts with defined entries. It configures a host declaration for the LanRover, with the MAC address from its Ethernet adapter specified (yours will be different). The LanRover is given the IP of `192.168.0.253/24`, and told that the `next-server` is `192.168.0.254`, which is the boot server. Note that the DHCP and TFTP servers can be running on different IPs, but the DHCP server *must be on the same layer 2 network as the LanRover* as DHCP won't route.

It's also possible to configure the LanRover to look for a specific boot file via its BOOTP/DHCP entry; however, I chose not to for the sake of keeping the configuration generic.

### TFTP Files

As mentioned, LanRovers want three files to boot. The default filenames it looks for, determined by packet capture, are as follows:

* `nme3vrom.srec` -- VROM image in Motorola S-Record format
* `nme3imag.srec` -- OS image in Motorola S-Record format
* `nme3conf.conf` -- plaintext configuration file

The VROM and OS images are present in several of the archives on dosdude1's site. To get started, the configuration file can be empty, but it does need to exist. I just `touch`ed the file on the TFTP server.

On NetBSD, place the required files in your TFTP serving directory (`/tftpboot` by default). Enable the TFTP daemon in `/etc/inetd.conf` if you haven't already. Restart/reload `inetd` if you had to edit the configuration.

### Booting the LanRover/E PLUS

dosdude1 mentions having issues getting the LanRover to go into firmware load mode (chasing green LEDs). I experienced this as well basically every time I booted it, until replacing the battery. The solution was to "pin reset" the unit, by poking a straightened paperclip into the reset hole near the Ethernet connectors. Hold it in until the unit reboots. If you have modem cards, you'll hear the relays click.

The LanRover will take a while to boot from BOOTP/TFTP when first powered up. It tries to find something to talk to on IPX and AppleTalk before giving up and making a BOOTP request on TCP/IP. Once it loads the VROM image, it will reboot and load the next bit. One can observe the process through packet capture.

### Battery Replacement

As shown above, I did eventually replace the battery in my LanRover/E PLUS with a 1/2AA holder and a new 3.6V lithium cell. This appears to keep the VROM and OS images loaded into memory, allowing the LanRover to boot without talking to the BOOTP/TFTP server(s). It's possible to configure the LanRover to fetch the various files every time.

### Configuring Without the Windows Program

It's possible to configure the LanRover from the command line: simply connect via Telnet to its IP, or attach a terminal to one of the serial ports. You'll be greeted with a login prompt. I've been unable to find a copy of the manual, but I did find something almost as good: a 90s hacker phile!

The textfile can be found [here, on Packet Storm Security](https://packetstormsecurity.com/files/17602/shiva.txt.html). It's written by Hybrid, who used to have a subdomain on dtmf.org which is currently down. I did manage to find a [capture through the Internet Archive](https://web.archive.org/web/20000118182713/http://hybrid.dtmf.org/myfiles.html) from January 2000.

Apparently LanRover and related Shiva devices were common enough on the PSTN that folks were finding them while [wardialing](https://en.wikipedia.org/wiki/Wardialing), and the linked textfile explains how one might get in (username: `root` with no password being default), the command structure and syntax, etc. It's pretty complete and will probably get you far enough along to get a LanRover up and going. There's also built-in command line help, once you've established a connection.

I have not yet attempted to persist a configuration back to the TFTP server. It's not clear if there's a command to send it back. I am also not sure of the format, but I'd guess that it's probably the same as the output from `show config`, since inputting the configuration from the command line involves repeating that format.

At some point I may set up the Windows 9x configuration utility and attempt to capture the configuration it transmits. This would reveal the format that the configuration tool itself uses. From dosdude1's video, it looks like the configuration tool does at least the initial configuration of the LanRover using BOOTP and TFTP too, so capturing that would probably show the missing pieces. 

{% counter :text => 'terminals served' %}
