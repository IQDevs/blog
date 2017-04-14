---
layout: post
title:  Rust for High-Level Programming Language Developers
date:   2017-04-12 00:00:00 -0500
categories: Rust
author: alkass
---

So you've been doing high-level programming all your life, and you've been eyeing Rust for some time now, and you're not sure where to start (or how to start). Well, this walk-through-like post will guide you through some of the common tasks you preform in high-level languages like JavaScript, Python, or even C#. I'll try to stay away from C++ for reasons I won't get to discuss here. Just know that this is a C++-free post.

### So, JSON in Rust?
#### The short answer is 'no built-in support for JSON but...'
Well, Rust has no built-in support for JSON objects, but before you let that throw you off, Rust `struct`s are ~ 99% identical to JSON objects in their outer structure and the way they are defined and used. Let's look at an example.

Say you want to define a Person JSON object with fields holding things like the `full name`, `date of birth`, and `gender` of a person. Here's how you'd likely define your object in a language like JavaScript:

```js
var person = {
  fullName: 'Fadi Hanna Al-Kass',
  dateOfBirth: '01-01-1990',
  gender: 'MALE'
};
```

Here's how you'd write this in Rust:

```rust
// Our pseudo-JSON object skeleton
struct Person {
  full_name: String,
  date_of_birth: String,
  gender: String
}

fn main () {
  let person = Person {
    full_name: "Fadi Hanna Al-Kass".to_string(),
    date_of_birth: "01-01-1990".to_string(),
    gender: "MALE".to_string()
  };
}
```

You've probably already noticed two differences between the two code snippets:

1. We had to define a skeleton for our pseudo-JSON object
2. We used lowerCamelCase with JavaScript and snake_case with our Rust code snippet. This is really nothing more than a naming convention that the Rust compiler will throw a bunch of warnings at you if you don't follow, but it shouldn't have an effect on the execution of your program if you so choose not to follow.

Now back to the first (and perhaps, more obvious) difference. Rust is a very (and I mean very) strongly typed programming language. That said, it needs to own as much information about your object types during the compilation process as possible. Of course, `struct`s are no exception, and you can really consider two ways (or more, depending on how imaginational you are) of looking at this: it is either (1) `limiting` or (2) `validating`. I wouldn't be putting this post together had I considered strong-typing limiting.

> You can always replace a strongly typed pseudo-JSON object with a `HashMap` to get around the static typing issue, but I'd advice against that, and I believe I can convince you to stick to the `struct` approach. You may, at this point, still don't think so, but wait until we get to these magical little thingies called `traits` and then we'll see ;-)

### Nested pseudo-JSON Objects?
#### Sure, forward we go

Let's design our `Person` JSON object in a more modern fashion. Instead of having a field containing the `full_name`, we can turn `full_name` into a sub-`struct` that has two fields (`first_name` and `last_name`). Instead of storing `date_of_birth` as a string that we may, at some point, need to parse down to extract the day, month, and the year from, we can store this information in a `struct` with three separate fields. And for our `gender` field, we can reference an `enum` value.

```rust
struct FullName {
    first_name: String,
    last_name: String
}

struct DateOfBirth {
    day: i8,  // 8-bit integer variable
    month: i8,
    year: i16 // 16-bit integer variable
}

enum Gender {
    MALE,
    FEMALE,
    NotDisclosed
}

struct Person {
  full_name: FullName,
  date_of_birth: DateOfBirth,
  gender: Gender
}

fn main () {
  let person = Person {
      full_name: FullName {
          first_name: "Fadi".to_string(),
          last_name: "Hanna Al-Kass".to_string()
      },
      date_of_birth: DateOfBirth {
          day: 1,
          month: 1,
          year: 1990
      },
      gender: Gender::MALE
  };
}
```

Our pseudo-JSON object is now looking much cleaner and even easier to utilize. Speaking of utilization, how do we reference our fields? Well, you've probably guessed it already. Yes, it's the dot operator. If you're interested in, say, printing the full name of your person object. Here's how you'd do that:

```rust
// The following line of code goes inside your main function right after
// your person object has been instantiated, or really anywhere after the
// object has been declared.

println!("{} {}", person.full_name.first_name, person.full_name.last_name);
```

and you're probably seeing a problem here already. It would absolutely be tedious to use this approach to print out the full name of a person especially if you were to do this from multiple places in your program let alone the fact the way the print is done looks really primitive. There must be a different (perhaps, even, better) way you say. You bet there is. In fact, there not only is but are many ways you can go about handling this issue, which one of which would be the use of `traits`. A trait is a programmatical way of telling the compiler how to carry out specific functionalities during the build process. We're going to use one here and learn how to write our own further below. The trait we're about to use in a moment is called the `Debug` trait which basically sets out a specific printing layout for your defined `enum`, `struct` or what have you.

If you simply add `#[derive(Debug)]` right on top of your `FullName` `struct` definition: i.e.:

```rust
#[derive(Debug)]
struct FullName {
    first_name: String,
    last_name: String
}
```

and replace:

```rust
println!("{} {}", person.full_name.first_name, person.full_name.last_name);
```

with:

```rust
println!("{:?}", person.full_name);
```

You'll end up with:

```rust
FullName { first_name: "Fadi", last_name: "Hanna Al-Kass" }
```

Cool, isn't it? Well, it gets even cooler in a bit.

But hang on a second, why did I have to replace `"{}"` with `"{:?}"` in my `println` statement? Or an even more proper question to ask is: what is the difference between the two?
Well, so Rust has two ways of printing out stuff (or maybe more than two that I still haven't discovered yet!): a (1) `Display` and a `Debug`. `Display` is what you'd probably want to use to allow the program to communicate some meaningful output to your user, and `Debug` is what you could use during the development process. Each one of these two is a separate `trait` that can co-exist without overlapping each other. By that I mean, you can allow your object to print something with `"{}"` and something entirely different with `"{:?}"`, but that's to be covered when we get down to writing our own `trait`s.

So is it possible to use `#[derive(Debug)]` to print out nested objects? Yes, it is, and following is how. Simply add `#[derive(Debug)]` right on top of your main object and every object that's part of it and then print the object as a whole by passing it to a  `println` function using the `"{:?}"` notation, i.e.:

```rust
#[derive(Debug)]
struct FullName {
    first_name: String,
    last_name: String
}

#[derive(Debug)]
struct DateOfBirth {
    day: i8,  // 8-bit integer variable
    month: i8,
    year: i16 // 16-bit integer variable
}

#[derive(Debug)]
enum Gender {
    MALE,
    FEMALE,
    NotDisclosed
}

#[derive(Debug)]
struct Person {
  full_name: FullName,
  date_of_birth: DateOfBirth,
  gender: Gender
}

fn main () {
  let person = Person {
      full_name: FullName {
          first_name: "Fadi".to_string(),
          last_name: "Hanna Al-Kass".to_string()
      },
      date_of_birth: DateOfBirth {
          day: 1,
          month: 1,
          year: 1990
      },
      gender: Gender::MALE
  };
  println!("{:?}", person);
}
```

And your output will look like:

```rust
Person { full_name: FullName { first_name: "Fadi", last_name: "Hanna Al-Kass" }, date_of_birth: DateOfBirth { day: 1, month: 1, year: 1990 }, gender: MALE }
```

Our output is looking pretty verbose already, and you may not like that. Is there a way to manipulate this output in terms of re-arranging its layout or limiting the amount of information being displayed? You bet there is, and it's through writing our own `Debug` `trait` instead of using a `derive`d one. I think it's better to introduce one more thing right before we get down to business with `trait`s, and that is Rust's `OOP`-like paradigm. I call it `OOP`-like because Rust doesn't consider itself an Object-Oriented Programming Language, but sure that in no way means we can't do `OOP` in Rust. It just means `OOP` is done differently. To be more precise, `OOP` in Rust is done in a way Rust wouldn't consider `OOP`.

Up until now, we've only been working with `struct`s and `enum`s. You've probably already noticed that we used them to store data, but no logic (constructors, function, destructors, etc) was added to them. That's because that's not where the functions go. before I further explain this, let's look at a tiny Python class and discuss how its alternative can be written in Rust.
Say you have a `Person` `class` with a constructor that takes a `first_name` and a `last_name` and provides two separate getter functions that give you these two string values whenever you need them. You'd write your class something as follows:

```python
class Person:
  def __init__(self, firstName, lastName):
    self.firstName = firstName
    self.lastName = lastName
  def getFirstName(self):
    return self.firstName
  def getLastName(self):
    return self.lastName
```

Notice how we have our fields and functions mixed together inside a single class. Rust separates the two. You'd have your fields defined inside a `struct` and an `impl` containing all relevant functions. So, when interpreted, our Python class would look in Rust as follows:

```rust
struct Person {
    first_name: String,
    last_name: String
}

impl Person {
    fn new (first_name: String, last_name: String) -> Person {
        return Person {
            first_name: first_name,
            last_name: last_name
        };
    }
    fn get_first_name (&self) -> &str {
        return &self.first_name;
    }

    fn get_last_name (&self) -> &str {
        return &self.last_name
    }
}
 ```

And to instantiate the object and access/utilize its functions, we do the following:

```rust
let person = Person::new("Fadi".to_string(), "Hanna Al-Kass".to_string());
println!("{}, {}", person.get_last_name(), person.get_first_name());
```

You've probably already looked at the code and thought to yourself "aha, `Person::new()` must be the constructor" to which you'd definitely be right. however, one thing you need to keep in mind is that Rust has no concept of a `constructor` per se. Instead, we define a static function that we use to instantiate our object. This also means `new` is not a keyword nor is it the required name of your entry point to your object; it can really be anything but `new` is the convention.

> In short, your class constructor is a static function located inside an `impl` and turns an object of the type of the class you're instantiating (Person in our case).

### Traits
#### If this doesn't turn you into a Rust fanatic, I don't think anything will. *Sad :-(*

A `trait` is nothing but a language feature that tells the compiler about a type-specific functionality. The definition of a `trait` may be confusing as heck to you, but it'll all settle for you with the first example or two.

Remember how we were talking about classes with constructors, functions, and destructors? Well, we've already discussed how constructors and functions are done in Rust. Let's talk a little about destructors. A `destructor` is normally a class function that invokes itself once the class is out of scope. In some low-level programming languages like C++, a class destructor is normally used to deallocate all allocated memory and preform some house cleaning. Rust has an `impl` destruction functionality (`trait`) called `Drop`. Let's look at how this trait can be implemented and invoked:

Let's say you have a `Response` object you return to a HTTP validation layer that sends it to an end-client. Once this operation is complete, you have no business in maintaining this `Response` object, so it'll delete itself once it's out of scope. Let's start by defining this structure:

```rust
struct Response {
  code: i32,
  message: String
}

fn main () {
  let res = Response{
    code: 200,
    message: "OK".to_string()
  };
}
```

Now let's add a `Drop` `trait` to our object and see when `Drop` is invoked:

```rust
impl Drop for Response {
  fn drop(&mut self) {
    println!("I ran out of scope. I'm about to be destroyed")
  }
}
```

If you try to run the complete program now, i.e.:

```rust
struct Response {
  code: i32,
  message: String
}

impl Drop for Response {
  fn drop(&mut self) {
    println!("I ran out of scope. I'm about to be destroyed")
  }
}

fn main () {
  let res = Response{
    code: 200,
    message: "OK".to_string()
  };
}
```

You'll see the following output right before the program finishes executing:

```
I ran out of scope. I'm about to be destroyed
```

Let's look at another example.
If you've ever done any scientific computation in Python, chances are you've overloaded some of the arithmetic operations (`+`, `-`, `*`, `/`, `%`, etc). A vector class with `+` overloaded would look something like the following:

```python
class Vector:
  def __init__(self, a, b):
    self.a = a
    self.b = b
  def __add__(self, otherVector):
    return Vector(self.a + otherVector.a, self.b + otherVector.b)
  def __str__(self):
    return "Vector(%s, %s)" % (self.a, self.b)
```

And if you were to add two `Vector` objects, you'd so something like the following:

```python
v1 = Vector(1, 2)
v2 = Vector(5, 7)
v3 = v1 + v2
```

And print the result as follows:

```python
print(v3)
```

This will print the following:

```python
Vector(6, 9)
```

Hmm.. Let's see how we could go about implementing this in Rust. First, we'd need to somehow find a way to add objects (i.e., overload the `+` operator). Second, we'd need to be able to give our object to `println` and see it print something like `Vector(#, #)`. Lucky for us, both of these features are available as `trait`s we can implement. Let's chase them one at a time. We'll start with the `Add` `trait`.

Here's our Rust `Vector` object:

```rust
struct Vector {
  a: i32,
  b: i32
}
```

We, then, add the `+` operation overloaded to our `Vector` `struct` as follows:

```rust
use std::ops::Add;

impl Add for Vector {
  type Output = Vector;
  fn add(self, other_vector: Vector) -> Vector {
    return Vector {
      a: self.a + other_vector.a,
      b: self.b + other_vector.b
    };
  }
}
```

At this point, we can have the following in our `main` function:

```rust
let v1 = Vector {
  a: 1,
  b: 2
};
let v2 = Vector {
  a: 5,
  b: 7
};
let v3 = v1 + v2;
```

But we can't print quite yet. Let's implement this:

```rust
use std::fmt::{Debug, Formatter, Result};
impl Debug for Vector {
  fn fmt(&self, f: &mut Formatter) -> Result {
    write!(f, "Vector({}, {})", self.a, self.b)
  }
}
```

Now we can print `v3` as follows:

```rust
println!("{:?}", v3);
```

And get the following output:

```rust
Vector(6, 9)
```

Your final program should look like the following:

```rust
struct Vector {
  a: i32,
  b: i32
}

use std::ops::Add;

impl Add for Vector {
  type Output = Vector;
  fn add(self, other_vector: Vector) -> Vector {
    return Vector {
      a: self.a + other_vector.a,
      b: self.b + other_vector.b
    };
  }
}

use std::fmt::{Debug, Formatter, Result};
impl Debug for Vector {
  fn fmt(&self, f: &mut Formatter) -> Result {
    write!(f, "Vector({}, {})", self.a, self.b)
  }
}

fn main () {
  let v1 = Vector {
    a: 1, b: 2
  };
  let v2 = Vector {
    a: 5, b: 7
  };
  let v3 = v1 + v2;
  println!("{:?}", v3);
}
```

Oh, and you know how I said `"{}"` is used to communicate output to the user while `"{:?}"` is usually used for debugging purposes? Well, it turns out you can overload the `Display` trail (available under `std::fmt` as well) to print your object using `{}` instead of `"{:?}"`.

So, simply replace:

```rust
use std::fmt::{Debug, Formatter, Result};
```

With:

```rust
use std::fmt::{Display, Formatter, Result};
```

And:

```rust
impl Debug for Vector {
```

With:

```rust
impl Display for Vector {
```

And:

```rust
println!("{:?}", v3);
```

With:

```rust
println!("{}", v3);
```

And voila, you're all set.

### Statements vs. Expressions?
At this point, I'm a bit tired of having to included unnecessary keywords in my code snippets, so I thought I'd introduce the concept of statement-vs-expression in Rust.

So, basically statements that don't end with a semi-colon (`;`) return something and they even have a special label: `expressions`. Without getting into too much detail and get you all confused, let me instead throw a little snippet at you and let you sort it out in your head.

So, let's say you have a function that takes two `i32` arguments and returns the sum of the two values. You could have your function written like this:

```rust
fn sum(a: i32, b: i32) -> i32 {
  return a + b;
}
```

or you could have the shorthand notation of the function by using an expression instead of a statement:

```rust
fn sub(a: i32, b: i32) -> {
  a + b
}
```

From this point on, I will be using expressions whenever possible.

### Our Journey into the Specifics
To be added

### pseudo-Switch-Case Statements
To be added

#### Loops
To be added

#### Object Wrapping/Unwrapping
To be added

#### Generics
To be added
