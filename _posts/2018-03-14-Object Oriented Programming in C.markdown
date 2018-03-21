---
layout: post
title:  Object Oriented Programming in C
date:   2018-03-14 00:00:00 -0500
categories: C
author: Fadi Hanna Al-Kass
handle: https://github.com/alkass
---

Before C++ was called C++, it was called "[C with Classes](http://www.cplusplus.com/info/history/)" for reasons that will be obvious to anyone familiar with both C and C++. Yet, C still not only widely used but is also the preferred language to many. Why that is the case is not what I'm here to address today. That might be the topic to another blog post.

What I'm here to discuss today, however, are a few ways to have some of the features and characteristics of C++ in C, and we shall begin with the OOP model. After you will have read this blog post, you will be able to mimic ...........


Structs in C take the most basic form of an objects. They can contain a group of object-related characteristics together. For instance, a newborn baby's object may contain the following fields of data:

```c
typedef struct {
  char name[128];
  char date_of_birth[16]; // format: MIN:HR-MM:DD:YYYY
  float weight;
  char blood_type[2];
} Baby;
```

> I write `typedef struct {...} Baby;` instead of `struct Baby {...};` so I can use `Baby baby;` to declare a `Baby` object instead of `struct Baby baby;`. I find the first form cleaner than the latter.

You might be used to implementing a toString function that takes stringifies an object for you, e.g.:

```c
char* toString(Baby* baby) {
  char* str = (char*)calloc(1, sizeof(Baby));
  sprintf(str, "{ %s, %s, %2lf, %s }", baby->name, baby->date_of_birth, baby->weight, baby->blood_type);
  return str;
}
```

And now, to stringify our `Baby` object, we'd need the do to the following:

```c
#include <stdio.h>  // needed for printf
#include <stdlib.h> // needed for sprintf

char* toString(Baby* baby) {
  char* str = (char*)calloc(1, sizeof(Baby));
  sprintf(str, "{ %s, %s, %.1lf, %s }", baby->name, baby->date_of_birth, baby->weight, baby->blood_type);
  return str;
}

int main() {
  Baby baby = {"John Smith", "47:12-01:12:2017", 3, "O+"};
  printf("%s\n", toString(&baby));
}
```

A problem arises when your `Baby` object is part of a system (say, a Hospital) where `Doctor` and `Nurse` objects not only exist, but also want to have a stringify mechanism implemented. You'd normally end up writing a seperate `toString` function for each object, e.g.: `babyToString`, `doctorToString`, and `nurseToString`.

Another option that's also available is a generic function; one that takes a generic object of any type and finds a way to deal with it. The bost basic form of a generic object in `C` is a `void*` object. Functions that take `void*` as a parameter can essentially recieve an object of any type. Things aren't that clean in `C` though.
