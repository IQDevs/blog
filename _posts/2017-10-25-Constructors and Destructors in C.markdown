---
layout: post
title:  Constructors and Destructors in C
date:   2017-10-25 00:00:00 -0500
categories: C
author: Fadi hanna Al-Kass
handle: https://github.com/alkass
---

> Everything discussed here is a feature brought to you by the [`GCC`](https://gcc.gnu.org/) compiler. If you happen to be using a different compiler, I'm not sure all or any of this would apply given the fact that these features aren't part of the `C` programming language per se.

When writing programs of considerable size and complexity, we tend to modularize our code. That is, we try to think of all different components as objects that can be easily moved around and fit within existing and future code. In C, it's common practice for developers to divide code into libraries and header files that can be included as needed. When working with someone else's library, you'd normally rather have a getting-started document that's as short and as concise as possible.

Let's consider an example. You're working with a team that's responsible for implementing a stack data structure and is expected to hand you the five essential functions every stack should have: `push()`, `pop()`, `peek()`, `isFull()`, and `isEmpty()`. You're probably already wondering "who's going to initialize the stack? Do I have to? Will they hand me an initialized instance? Is it stack-allocated or heap-allocated? If it's heap-allocated, do I have to worry about freeing it myself?" The stream of questions can literally be endless the more complex the library is. Wouldn't it be better for the library to handle all the heavy lifting of having to instantiate all necessary data objects and do the housekeeping after itself when its job is finished (something of the nature of a constructor that's called automatically once the library is included and a destructor that's called when the library is done with)?

## Constructors

Let's assume we have a header file named 'stack.h':

```c
#ifndef STACK_H
#define STACK_H

#include <stdio.h>   // printf
#include <stdlib.h>  // calloc & free
#include <stdbool.h> // true & false

#define STACK_CAP 12

int* stack;
unsigned int stack_ptr;

bool isEmpty() {
  return stack_ptr == 0;
}

bool isFull() {
  return stack_ptr == STACK_CAP;
}

bool push(int val) {
  if (!isFull()) {
    stack[stack_ptr++] = val;
    return true;
  }
  return false;
}

bool peek(int* ref) {
  if (!isEmpty()) {
    *ref = stack[stack_ptr - 1];
    return true;
  }
  return false;
}

bool pop(int* ref) {
  if (peek(ref)) {
    stack_ptr--;
    return true;
  }
  return false;
}

#endif
```

You've probably already noticed that `stack` and `stack_ptr` are left uninitialized, so if you were to blindly use `push`, `peek`, or `pop`, you're going to run into a segmentation fault as `stack` is a `NULL` pointer, and `stack_ptr` is likely to contain some gibberish that was left behind on the stack. The proper way to use these functions would be to allocate memory for the `stack` pointer and `free` it when you're done. An even better way to do this would be to have this task automatically preformed at the time of including this header file. This is done through a library constructor, and it's done as follows:

```c
/*  Library Constructor
    @Brief: This function is automatically called when
    the containing header file is included.
*/
__attribute__((constructor)) void start() {
   printf("Inside Constructor\n");
   stack_ptr = 0;
   stack = (int*)calloc(STACK_CAP, sizeof(int));
}
```

The function above needs to be located inside your header file and will be automatically called once you've included the header file somewhere in your code.

> In case you didn't know, `#ifndef STACK_H`, `#define STACK_H` and `#endif` are needed to prevent multiple or recursive includes that'll cause the compiler to run into redefinition issue.

Now the following program:

```c
#include <stdio.h>
#include "header.h"

int main() {
    printf("Inside main\n");
    return 0;
}
```


Will generate the following output:

```
Inside Constructor
Inside Main
```

And exit peacefully... Well not really peacefully. At least not in every sense of the word as your program has left some heap-allocated memory un-deallocated. You're not likely going to see your program crash or anything, but you've still introduced a bug to your system that the OS may or may not be able to resolve depending on what OS you happen to be using. The proper way to go about programmatically solve this problem is to use a destructor in your application. A destructor is another function that gets called automatically once you're done with the library. Read ahead to find out how this is done.

## Destructors

You're going to like this part.

We've used `__attribute__((constructor))` to introduce a constructor into our code, so you're probably already thinking a `__attribute__((destructor))` is what we'd use to add a destructor, in which case you'd be absolutely right. Here's our destructor function implementation for our stack library:

```c
/*  Library Destructor
    @Brief: This function is automatically called when
    the containing header file is dismissed (normally
    at the end of the program lifecycle).
*/
__attribute__((destructor)) void finish() {
   printf("Inside Destructor\n");
   free(stack);
   stack = NULL;
}
```

Now if you execute the same tiny program we've written above, you'll get the following output:

```
Inside Constructor
Inside Main
Inside Destructor
```

And there we've achieved a library implementation that takes care of all necessary memory management for us.