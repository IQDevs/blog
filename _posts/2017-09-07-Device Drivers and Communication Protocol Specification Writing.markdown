---
layout: post
title:  Device Drivers and Communication Protocol Specification Writing
date:   2017-09-07 00:00:00 -0500
categories: C
author: alkass
---

Device drivers and protocol design are two areas where one could get really technical and dive into very complex topics, though this guide doesn't need to be. We're going to write a device driver that processes incomming commands and returns responses conforming to a standard specification that we're going to write first.

What device are we targetting? We could design a USB device and write a Linux Kernel module, but that'd be too heaftly of a task for a single blog post, so instead, we're going to stick a device that doesn't require an OS or even a Kernel. I decided to go Arduino, but everything discussed here works just fine with ESP8266 or any boards that allow you to flash Arduino-compiled code.

## Project Setup

I'm also going to use [Platformio](http://platformio.org/) to ease up the build and deployment process. If you don't have `Platformio` installed, the following command should take care of that part for you:

```bash
$ pip install platformio
```

> The techniques discussed here are by no means Arduino-specific. They are applicable to any device with serial or any type of connection for that matter.

Start a `Platformio` project as follows:

```bash
$ mkdir my_device_driver && cd my_device_driver
$ pip init .
```

Add your board to the project:

```bash
# If you're adding an Arduino board run the following
$ pio init --board XXX

# Or the following if you're adding an ESP8266 board
$ pio init --board YYY
```

Add a source file to your project:

```bash
touch src/main.ino
```

Open `src/main.ino` in your preferred code editor and add the following lines of code to it:

```c
void setup()
{
  Serial.begin(9600);
}

void loop()
{
  Serial.println("Hello, Device Driver!");
}
```

Now build your code and make sure everything completes successfully:

```bash
$ pio build
```

Connect your board to your computer over a USB cable and run the following command:

```bash
$ pio run --target upload
```

> The command above may fail due to lack of permission to access the device files. If you happen to be following along on a `Linux` machine (which is what I'd highly recommend), the following should fix your problem:

```bash
$ sudo pio run --target upload
```

Now if you run the following:
```bash
$ pio device monitor # Or sudo pio device monitor
```

You should be seeing an endless stream of the "Hello, Device Driver!" string. This is a clear indicator that everything (project setup, build chain, USB connection, and serial communication) is good to go.

## Specification Writing
Now onto designing our communication protocol specification. Specification documents are written to outline what needs to be done (HLD - short for High-Level Design) in all cases, <b>and how it has to be done</b> (LLD - short for Low-Level Design) in some cases.
Our specification will cover both the HLD and the LLD sides of the project.

### HLD
What would you like your device to do? This is the type of question an HLD can answer. Since I'm the one writing this blog post, I have decided to stick to writing the shortest specification possible. We're going to allow the control of all digital and analog pins remotely. This can be formly written as follows:

```
The device driver will allow serial access to all input and output pins (both analog and digital) on the following boards:
* ESP8266
* Arduino Uno
* Arduino Mega
* Arduino Duemilanove
```

### LLD
Now that we've defined our expected bevaiour in our HLD, we can go ahead and decide how to go about having it all done. This is where LLD comes into place.

* We've decided that our end goal is to allow access to all pins over serial. We know the best way to maniuplate the pins is to use these functions: `pinMode`, `digitalRead`, `analogRead`, `digitalWrite`, and `analogWrite`. So, we can write our LLD specification to limt our use of the pins to these five functions only. This could be formly done as so:

```
All pin manipulation must be limitted to using `pinMode`, `digitalRead`, `analogRead`, `digitalWrite`, and `analogWrite`. No bit togolling is allowed.
```

Now let's talk a little about our inputs (requests) and outputs (responses).

* Every command we send to or recieve from the board MUST start with an agreed-upon hard-coded acknowledgment byte. The purpose of having this byte it so make sure we have a valid command to work with. If, for instance, your last command read less or more bytes that it was supposed to, all upcoming commands coming from thatpoint onward will be messed up. Not having the expeceted acknowledgment byte in place will draw our attention to a stagerring bug if the boards misbehaviour is, for any reason, not obvious. Because 0 is the natural result you get when you zero out a block of memory, making our acknowledgment zero will make our deiver implementation prone to all sorts of defects. So, we could specifically prohibit the use of zero as a valid acknowledgment byte:

```
Every request sent to the board and every response retrieved from the board must start with an agreed-upon hard-coded acknowledgment byte. For the same of conformity across all possible future interfaces, we have decided that our acknowledgment byte is 0xA.
```

* 

* To achieve a smooth experience, we need to decide on an upper byte limit for both requests and responses, that way we don't have to calculate offsets on the fly which will require more processing power. For something as little as an Arduino board, you definitely need to consider solutions that require as little memory and processing power as possible. If you do the math correctly, you'll need one byte for your `acknolwdgment` field, one for the `id`, one for the `pin`, one for the `type` of the pin, one for the `mode` (in the case of setting a pin mode), and one for the `value` (in the case of setting a pin value). Since `mode` and `value` can't coexist, we can safely assume that the maximum size needed for each command is 5 bytes:


## Driver Implementation

