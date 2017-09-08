---
layout: post
title:  Device Drivers and Communication Protocol Specification Writing
date:   2017-09-07 00:00:00 -0500
categories: C
author: alkass
---

Device drivers and protocol design are two areas wheere one could get really technical and dive into very complex details, though this guide doesn't need to be. We're going to write a device driver that process incomming commands and send responses conforming to a standard specification that we're going to write first.

What device are we targetting? We could design a USB device and write a Linux Kernel module, but that'd be too heaftly of a task, so we're going to stick a device that doesn't require an OS or even a Kernel. I decided to go Arduino, but everything discussed here applies to my preferred module, the almighty ESP8266. I'm also going to use [Platformio](http://platformio.org/) to ease up my build and deployment process. If you don't have `Platformio` installed, the following command should take care of that part for you:

```bash
$ pip install platformio
```

Now onto designing our communication protocol specification. What would you like your device to do? Since I'm the one writing this blog post, I have decided to stick
