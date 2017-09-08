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

> The techniques discussed here are by no means Arduino-specific. They are applicable to any device with serial or any type of connection for that matter.

Now onto designing our communication protocol specification. What would you like your device to do? Since I'm the one writing this blog post, I have decided to stick to writing the shortest specification possible. We're going to allow the control of all digital and analog pins remotely.

Our specification looks like the following:

* Basically, we are interested in panipulating our board with 5 main functions: `pinMode`, `digitalRead`, `analogRead`, `digitalWrite`, and `analogWrite`.

* Every command we send MUST start with an agreed-upon hard-coded acknowledgment byte. The purpose of having this byte it so make sure we have a valid command to work with. If, for instance, your last command read less or more bytes that it was supposed to, all upcoming commands will be messed up. Not having the expeceted acknowledgment byte in place will draw our attention to a stagerring bug if the boards misbehaviour is by any means not obvious.

