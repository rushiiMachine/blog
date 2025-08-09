---
title: "Connecting to a Raspberry Pi over Ethernet"
description: "I was in too much of a rush to do it the right way"
published: 2025-08-07
updated: 2025-08-09
draft: false
tags: [ "Networking", "Raspberry Pi" ]
---

# Introduction

Sometimes there are times where a Raspberry Pi just isn't accessible over WiFi; the connection details could have been misconfigured,
the region might've never been set, or perhaps you have no idea why it broke. Either way, now it requires a physical connection to
reconfigure it. But that becomes challenging when your RPi is already mounted in such a way that makes getting a wired network connection
very difficult. This is typically where you'd hook up a monitor and keyboard, but I was too lazy to do that.

I initially thought it would be much simpler to get a direct shell, where I could simply open one over a serial USB connection.
Unfortunately, only the RPi 4 and RPi Zero support USB gadget mode, and mine (RPi 3B) doesn't! My next course of action was to try the
Ethernet port on my RPi 3B. After pulling out an Ethernet cable and hooking it up to my laptop, I quickly ran into an issue; as my
laptop did not host a DHCP server, there was no address assigned to my RPi.

This is where most guides diverge; usually, there's two approaches that are recommended:
- Configuring a DHCP server such as `dhcpcd` for the RPi to automatically be assigned an address. Unfortuantely, I don't want to spend
  time configuring it and then have to clean it up afterwards. That would mean I have to do it every single time I encounter such
  a scenario.
- Statically assigning an IP to the RPi. The problem with this is that I don't have access to a shell in the
  first place, which makes this impossible.

That left me with trying to locate the RPi's self-assigned [Local-Link address] address. Thanks to Stateless Address
Autoconfiguration ([SLAAC]), each device will generate a local-link address for each IPv6-enabled interface, regardless
of the presence of an explicitly assigned address. The usual way to find this address would be to either run an aggressive
`nmap` scan, or to sniff incoming traffic on the interface. I chose the latter, since brute forcing a `fe80::/10`
(or more commonly a `fe80::/64`) subnet would take literally forever.

# Obtaining a Connection

1. Take note of your machine's Ethernet interface via `ip addr`

```
$ ip addr

4: enp195s0f3u1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether xx:xx:xx:xx:xx:xx brd ff:ff:ff:ff:ff:ff
    altname enxxxxxxxxxxxxx
    inet6 fe80::xxxx::xxff:fexx:xxxx/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever
```

Usually it's something along the lines of `eth0`, but in my case it was `enp195s0f3u1`.

2. Run `tcpdump` to capture incoming packets on that interface:

```shell
$ sudo tcpdump -i <interface> inbound
```

If you don't already have `tcpdump` installed:
```shell
$ sudo apt install tcpdump
$ sudo pacman -S tcpdump
```

3. (Re)connect the Ethernet cable to the RPi

4. Wait and observe the incoming traffic, taking note of the address on incoming announcements.

```shell
00:58:44.366691 IP 0.0.0.0.bootpc > 255.255.255.255.bootps: BOOTP/DHCP, Request from b8:27:eb:e1:9d:f6 (oui Unknown), length 342
00:58:44.576478 IP6 :: > ff02::16: HBH ICMP6, multicast listener report v2, 2 group record(s), length 48
00:58:45.136588 IP6 fe80::2c65:ff96:60ca:4b30 > ff02::16: HBH ICMP6, multicast listener report v2, 2 group record(s), length 48
00:58:45.137339 IP6 fe80::2c65:ff96:60ca:4b30 > ff02::2: ICMP6, router solicitation, length 16
00:58:45.594741 IP6 fe80::2c65:ff96:60ca:4b30 > FRAMEWORK: ICMP6, neighbor advertisement, tgt is fe80::2c65:ff96:60ca:4b30, length 32
00:58:45.595286 IP6 fe80::2c65:ff96:60ca:4b30.llmnr > FRAMEWORK.42190: Flags [R.], seq 0, ack 2280251028, win 0, length 0
00:58:45.856426 IP6 fe80::2c65:ff96:60ca:4b30 > ff02::16: HBH ICMP6, multicast listener report v2, 2 group record(s), length 48
00:58:48.661006 IP 0.0.0.0.bootpc > 255.255.255.255.bootps: BOOTP/DHCP, Request from b8:27:eb:e1:9d:f6 (oui Unknown), length 342
00:58:49.138758 IP6 fe80::2c65:ff96:60ca:4b30 > ff02::2: ICMP6, router solicitation, length 16
00:58:49.366745 ARP, Request who-has 169.254.233.103 tell 0.0.0.0, length 46
00:58:50.656576 IP6 fe80::2c65:ff96:60ca:4b30 > FRAMEWORK: ICMP6, neighbor solicitation, who has FRAMEWORK, length 32
00:58:51.229898 ARP, Request who-has 169.254.233.103 tell 0.0.0.0, length 46
00:58:52.694541 ARP, Request who-has 169.254.233.103 tell 0.0.0.0, length 46
00:58:53.140167 IP6 fe80::2c65:ff96:60ca:4b30 > ff02::2: ICMP6, router solicitation, length 16
00:58:54.698083 ARP, Request who-has 169.254.233.103 tell 169.254.233.103, length 46
00:58:54.726525 IP 169.254.233.103 > 224.0.0.22: igmp v3 report, 1 group record(s)
00:58:55.536351 IP 169.254.233.103 > 224.0.0.22: igmp v3 report, 1 group record(s)
00:58:55.667159 IP 0.0.0.0.bootpc > 255.255.255.255.bootps: BOOTP/DHCP, Request from b8:27:eb:e1:9d:f6 (oui Unknown), length 342
00:58:56.699392 ARP, Request who-has 169.254.233.103 tell 169.254.233.103, length 46
00:58:57.141116 IP6 fe80::2c65:ff96:60ca:4b30 > ff02::2: ICMP6, router solicitation, length
```

*(mDNS traffic omitted for brevity)*

There's two lines that are of interest:

```shell
00:58:53.140167 IP6 fe80::2c65:ff96:60ca:4b30 > ff02::2: ICMP6, router solicitation, length 16
00:58:56.699392 ARP, Request who-has 169.254.233.103 tell 169.254.233.103, length 46
```

On the first line, the RPi is announcing that its local-link IPv6 address is `fe80::2c65:ff96:60ca:4b30`,
and then it's also announcing that it's assigning itself a local-link IPv4 address of `169.254.233.103`.

:::warn
The RPi may or may not assign itself an IPv4 local-link address, depending on the network stack running on it!
My RPi 3B that utilized `isc-dhcp-client` did not assign itself a local-link IPv4 address, but my RPi 3B+
running `dhcpcd` did do so.
:::

1. Connect to the RPi over ssh. When using using the RPi's IPv6 local-link address, the interface it's accessible over also
   needs to be specified.
	- `ssh pi@169.254.233.103`
	- `ssh pi@<ipv6>%<interface>`
	- `ssh pi@fe80::2c65:ff96:60ca:4b30%eth0`

Enjoy!

# Notes

:::warning
I observed frequent timeouts while actively using my ssh session, but only on one of my RPis. This would could always be resolved by
reconnecting the Ethernet cable, after which the session would usually resume within a couple of seconds. This to me looked like some
sort of power saving mode, given that this issue always occurs exactly 3 minutes after connecting.

**UPDATE**: While finishing this blog post, I realized what the correlation was between between my two RPis! The one I have having
timeout issues on ran `NetworkManager` + `isc-dhcp-client` (a deprecated DHCP client). I tried swapping both of these components for
`dhcpcd` (and configuring WiFi authentication through `wpa_supplicant` instead) and it worked like a charm! This also unexpectedly 
fixed the frequent connection issues to my router!

I'm not sure why `isc-dhcp-client` was the default on 64-bit Raspberry Pi OS Lite, but if you do encounter this, then switching over
to `dhcpcd` should resolve everything :)
:::

:::tip
Please note that the MAC address of the RPi will always prefixed with one of the following:

- `28:CD:C1:xx:xx:xx`
- `B8:27:EB:xx:xx:xx`
- `D8:3A:DD:xx:xx:xx`
- `DC:A6:32:xx:xx:xx`
- `E4:5F:01:xx:xx:xx`
  
If you are struggling to pinpoint the address of the RPi, this might help you in further debugging.
:::


<!-- Links -->

[Local-Link address]: https://en.wikipedia.org/wiki/Link-local_address
[SLAAC]: https://en.wikipedia.org/wiki/IPv6_address#Stateless_address_autoconfiguration_(SLAAC)
