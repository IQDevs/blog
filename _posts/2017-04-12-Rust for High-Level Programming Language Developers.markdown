---
layout: post
title:  Rust for High-Level Programming Language Developers
date:   2017-04-12 00:00:00 -0500
categories: Rust
author: alkass
---

So you've been doing high-level programming all your life, and you've been eyeing Rust for some time now, and you're not sure where to start (or how to start). Well, this walk-through-like post will guide you through some of the common tasks you preform in high-level languages like JavaScript, Python, or even C#.

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

1. We had to define a skeleton for our pseudo-JSON object.
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

But hang on a second, why did I have to replace `{}` with `{:?}` in my `println` statement? Or an even more proper question to ask is: what is the difference between the two?
Well, so Rust has two ways of printing out stuff (or maybe more than two that I still haven't discovered yet!): a (1) `Display` and a `Debug`. `Display` is what you'd probably want to use to allow the program to communicate some meaningful output to your user, and `Debug` is what you could use during the development process. Each one of these two is a separate `trait` that can co-exist without overlapping each other. By that I mean, you can allow your object to print something with `{}` and something entirely different with `{:?}`, but that's to be covered when we get down to writing our own `trait`s.

So is it possible to use `#[derive(Debug)]` to print out nested objects? Yes, it is, and following is how. Simply add `#[derive(Debug)]` right on top of your main object and every object that's part of it and then print the object as a whole by passing it to a  `println` function using the `{:?}` notation, i.e.:

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
  let res = Response {
    code: 200,
    message: "OK".to_string()
  };
}
```

Now let's add a `Drop` `trait` to our object and see when `Drop` is invoked:

```rust
impl Drop for Response {
  fn drop (&mut self) {
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
  fn drop (&mut self) {
    println!("I ran out of scope. I'm about to be destroyed")
  }
}

fn main () {
  let res = Response {
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

Then we add the `constructor`:

```rust
impl Vector {
    fn new (a: i32, b: i32) -> Vector {
        return Vector {
            a: a,
            b: b
        };
    }
}
```

We, then, add the `+` operation overloaded to our `Vector` `struct` as follows:

```rust
use std::ops::Add;

impl Add for Vector {
  type Output = Vector;
  fn add (self, other_vector: Vector) -> Vector {
    return Vector {
      a: self.a + other_vector.a,
      b: self.b + other_vector.b
    };
  }
}
```

At this point, we can have the following in our `main` function:

```rust
let v1 = Vector::new(1, 2);
let v2 = Vector::new(5, 7);
let v3 = v1 + v2;
```

But we can't print quite yet. Let's implement this:

```rust
use std::fmt::{Debug, Formatter, Result};
impl Debug for Vector {
  fn fmt(&self, f: &mut Formatter) -> Result {
    return write!(f, "Vector({}, {})", self.a, self.b);
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

impl Vector {
    fn new (a: i32, b: i32) -> Vector {
        return Vector {
            a: a,
            b: b
        };
    }
}

use std::ops::Add;
impl Add for Vector {
  type Output = Vector;
  fn add (self, other_vector: Vector) -> Vector {
    return Vector {
      a: self.a + other_vector.a,
      b: self.b + other_vector.b
    };
  }
}

use std::fmt::{Debug, Formatter, Result};
impl Debug for Vector {
  fn fmt(&self, f: &mut Formatter) -> Result {
    return write!(f, "Vector({}, {})", self.a, self.b);
  }
}

fn main () {
  let v1 = Vector::new(1, 2);
  let v2 = Vector::new(5, 7);
  let v3 = v1 + v2;
  println!("{:?}", v3);
}
```

Oh, and you know how I said `{}` is used to communicate output to the user while `{:?}` is usually used for debugging purposes? Well, it turns out you can overload the `Display` trail (available under `std::fmt` as well) to print your object using `{}` instead of `{:?}`.

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
fn sum (a: i32, b: i32) -> i32 {
  return a + b;
}
```

or you could have the shorthand notation of the function by using an expression instead of a statement:

```rust
fn sum (a: i32, b: i32) -> i32 {
  a + b
}
```

From this point on, I will be using expressions whenever possible.

### Our Journey into the Specifics
We're now going to dive into the basics of Rust.

#### Variable/Object Declaration
We've been declaring objects and variables all over the place already, but perhaps there's more to them than what's been covered already. If you want to declare an integer `x` and assign the value `2` to it, you could do so as follows:

```rust
let x = 2;
```

But if you were to write an operating system, a kernel module, and/or an application that runs on an embedded system, the size of your object really matters, and chances are you'll need to control these sizes. Unless you dive into the specifics of the design of the compiler of Rust, you really have no idea how many bits are used to store your variable. There must be a better way to carry this out, and here's how. Rust allows you to specify the type of your object with a slight edit to your statement. Instead of writing your variable declaration like this:

```rust
let x = 2;
```

You could write it like this:

```rust
let x: i8 = 2;
```

And you know for sure that your variable is stored as an 8-bit integer.

Read more about Primitive Types and Object Declaration [here](https://doc.Rust-lang.org/book/primitive-types.html)

#### Mutability
By default, objects and variables in Rust are immutable (not modifiable after they've been declared). Something like the following won't work:

```rust
let x: i8 = 2;
x = 3;
```

To be able to change the value of `x`, we need to tell the compiler to mark our variable as mutable (able to change value after it's been declared). This introduces a slight change to our declaration that's pretty intuitive; you simply add the keyword `mut` on the left side of your object declaration statement like this:

```rust
let mut x: i8 = 2;
```

And now the following will work like a charm!

```rust
x = 3;
```

#### Type Aliases
Rust has a keyword called `type` used to declare aliases of other types.
Say you want to use `i32` across a whole `class`, `module` or even across your whole application, and for clarity's sake you'd rather use `Int` instead of `i32` to reference 32-bit integers. You could define your `Int` type as follows:

```rust
type Int = i32;
```

And now to use your new type, you could define your variables like this:

```rust
let var1: Int = 10;
let var2: Int = 20;
```

And so on.

#### Functions
Function declarations are pretty intuitive and straightforward. Say you want to write a `greeting` function that prints out the test `"hello there!"` over `stdio`. You'd write your function as follows:

```rust
fn greeting () {
    println!("hello there!");
}
```

What if you want to pass the string to the function instead of hard-coding a specific value? Then, you'd write it like this:

```rust
fn greeting (message: String) {
    // TODO: Implement me
}
```

Multiple function arguments? Sure! Here's how:

```rust
fn greeting (name: String, message: String) {
    // TODO: Implement me
}
```

Functions with return values? Here's how:

```rust
fn add (a: i32, b: i32) -> i32 {
 a + b
}
```

> i32 is a 32-bit integer type in Rust. You can read more about Rust's support for numeric types [here](https://doc.Rust-lang.org/book/primitive-types.html#numeric-types).

Remember that we're using an `expression` in the code snippet above. If you wanted to replace it with a statement `return a + b;` will do.

#### Closures
The easiest definition of a `closure` I can give is that a `closure` is a function with untyped arguments. If you were to write a function that multiplies two numbers together and return the product, you'd do so as follows:

```rust
fn mul (a: i32, b: i32) -> i32 {
	a * b
}
```

This function can be written as a closure as follows:

```rust
let mul = |a, b| a * b;
```

And then you can call it the exact same way you'd call a function, i.e.:

```
println!("{}", mul(10, 20));
```

If you, for whatever reason, want to strongly-type your closure arguments, you can do so by defining their types the same way you'd define function arguments, e.g.:

```rust
let mul = |a: i32, b: i32| a * b;
```

And you can even strongly-type your closure return type as follows:

```rust
let mul = |a: i32, b: i32| -> i32 {a * b};
```

But that'll require you to wrap your closure content within two curly brackets (`{` and `}`).

You can read more about most of the cool stuff you can do with `closure`s [here](https://doc.Rust-lang.org/book/closures.html).

#### Function Pointers
If you're coming from a solid background in languages like C and C++, chances are you've worked with function pointers a lot. You've probably even worked with function pointers in languages like JavaScript and Python without ever coming across the name.
At its core, a function pointer is a variable holding access to a specific memory location representing the beginning of function. In JavaScript, if you were to have the following:

```js
function callee () {
  // TODO: Implement me
}

function caller (callback) {
  // TODO: Implement a task
  callback();
}

caller(callback);
```

It can be said that "`caller` is a function that takes an argument of type function pointer (which in this case is our `callee` function)".

Rust isn't that flexible when it comes to function pointers though. If you were to pass a function pointer to a function, the calling function needs to have a somewhat hard set on callback function specifications; your calling function needs to specify the arguments and the return type of the callee function. Let's discuss a use case where you may want to use a function pointer.

Say you're creating a struct called `CommandInterface` that will contain two fields: (1) a command string, and (2) a function pointer pointing to the function to be executed with the specified command. Let's start by defining the outer skeleton of our interface `struct`:

```rust
struct CommandInterface {
	str: String,
	exec: fn() -> i8
}
```

Here we're telling the compiler to expect our function pointer to have no arguments and return an 8-bit integer. Let's now define a function according to these specifications:

```rust
fn ls () -> i8 {
	// TODO: Implement me
	return 0;
}
```

> Our function needs not have a specific name. I'm only naming it after the command you're about to see below to maintain a convention.

Let's now define our function, set the function pointer, and see how we could use the function pointer in calling our function.

```rust
let cmd = CommandInterface {
	str: "ls".to_string(),
	exec: ls // points to the ls function declared above
};

(cmd.exec)();
```

> The parenthesis (`()`) around `cmd.exec` are a syntax requirement. If you forget to add them, the compiler will throw an error at you.

But what about functions with arguments? Say we want to pass some command arguments to our function, how would we do that? Well, this is pretty easy and it'll require very slight changes. You could replace:

```rust
exec: fn() -> i8
```

with:

```rust
exec: fn(arg1: String, arg2: String) -> i8
```

and:

```rust
fn ls (arg1: String, arg2: String) -> i8
```

with:

```rust
(cmd.exec)();
```

with something like this:

```rust
(cmd.exec)("-a".to_string(), "-l".to_string());
```

> In a practical world, it'd be better to pass a vector of arguments but I intentionally ignored vectors just to keep things clean.

#### Conditionals
When it comes to code path redirection, Rust has the three keywords you'll likely find in most programming languages out there: `if`, `else`, and `else if`. If you've worked with languages like `C`, `C++`, `C#`, `Java`, and `JavaScript`, then you already know how to work with conditional expressions in Rust. Here's the trick: conditional expressions in Rust are done exactly the way they're done in the languages I just mentioned, except without the wrapping parenthesis, e.g.:

The following JavaScript code:

```js
if (x == 0 || x == 2) {
	// TODO: Implement me
}
else if (x == 1) {
	// TODO: Implement me
}
else {
	// TODO: Implement me
}
```

is written in Rust as follows:

```rust
if x == 0 || x == 2 {
	// TODO: Implement me
}
else if x == 1 {
	// TODO: Implement me
}
else {
	// TODO: Implement me
}
```

And that's really all there is to it when it comes to code path redirection.

You might, however, be used to using the `?` operator for quick things like "if `x` is even do this and if `x` is odd do that", e.g.:

```js
// The following JavaScript statement sets `res` to 'even' if `x` is an even value, and 'odd' if `x` is an odd value

var res = x % 2 == 0 ? 'even' : 'odd';
```

In Rust, the same can be written as follows:

```rust
let res = if x % 2 == 0 {"even"} else {"odd"};
```

#### Matching (aka pseudo-Switch-Case Statements)
Matching is your typical `switch` case code block plus the ability to return something. If you were to compare integer `x` against a number of different values, using classical `if - else -- else if` gets pretty tedious really quickly, so developers tend to resort to `switch` case statements. Referring back to our `x` example, the following JavaScript compares `x` against 5 different values (cases):

```js
switch (x) {
  case 1:
    console.log('x is 1');
    break;
  case 2:
    console.log('x is 2');
    break;
  case 3:
    console.log('x is 3');
    break;
  case 4:
    console.log('x is 4');
    break;
  default:
    console.log('x is something else');
    break;
}
```

The snipper above can be written in Rust as follows:

```rust
match x {
    1 => println!("x is 1"),
    2 => println!("x is 2"),
    3 => println!("x is 3"),
    4 => println!("x is 4"),
    5 => println!("x is 5"),
    _ => println!("x is something else")
  };
```

> _ is how you handle `default` cases

But things don't end here; there's more to `match` statements. Like I mentioned above, you can actually return a value or an object from a `match` statement. Let's do some refactoring to our code snippet above and make it return the actual string instead of printing it to screen:

```rust
let res = match x {
    1 => "x is 1",
    2 => "x is 2",
    3 => "x is 3",
    4 => "x is 4",
    5 => "x is 5",
    _ => "x is something else"
  };
  println!("{}", res);
```

That will print the exact same thing except it handed you back the string instead of printing it, and you printed it.

`match` can work with sophisticated objects and patterns. Read more about it [here](https://doc.rust-lang.org/book/match.html).

#### Loops
Loops are a very interesting subject in Rust. The language currently has three approaches to any kind of iterative activity. These three approaches use three separate keywords: `for`, `while`, and `loop`.

The `for` loop is used when you've already decided the number of times you'd like to iterate. For example, the following will loop 9 times and print the values `0` through `9`:

```rust
for i in 0..10 {
    println!("{}", i);
}
```

This interprets to the following Python code:

```python
for i in range(0, 10):
    print("%d" % i)
```

You can also iterate over a list using a `for` loop as follows:

```rust
for i in &[10, 20, 30] {
    println!("{}", i);
}
```

This is equivalent to the following Python code:

```python
for i in [10, 20, 30]:
    print("%d" % i)
```

`for` loops can also preform some sophisticated tasks. For instance, if you have the string `"hello\nworld\nmy\nname\nis\nFadi"` and you want it up split it up using the linefeed (`\n`) delimiter, you can use the `lines()` function. This function returns an enumerator containing both the substring and the line number. So something like the following:

```rust
let my_str_tokens = "hello\nworld\nmy\nname\nis\nFadi".lines();
for (line_no, term) in my_str_tokens.enumerate() {
    println!("{}: {}", line_no, term);
}
```

Results in this:

```
0: hello
1: world
2: my
3: name
4: is
5: Fadi
```

The above example is equivalent to the following Python code:

```python
myStrTokens = "hello\nworld\nmy\nname\nis\nFadi".split("\n")
for i in range(0, len(myStrTokens)):
    print("%d: %s" % (i, myStrTokens[i]))
```

The `while` loop is used when you're not sure how many times you need to loop. It works the exact same way a `while` loop works in languages like C, C++, C#, Java, JavaScript, and Python. Here's a JavaScript example:

```js
bool status = true;
while (status) {
  // add some case that can set `status` to false
}
```

The snippet above can be translated into Rust and look like the following:

```rust
let status: bool = true;
while status {
  // add some case that can set `status` to false
}
```

The `loop` loop is used when you want to run your loop indefinitely until a terminating statement is reached. An example of when this would come in handy is when you have a web server with request handlers each assigned a thread. In a case like this you wouldn't want to have this:

```rust
let status: bool = true;

while true {
  // add some case that can set `status` to false
}
```

When you could actually have this:

```rust
loop {
  // add some case that can break out of the loop
}
```

> "Rust’s control-flow analysis treats this construct differently than a while true, since we know that it will always loop. In general, the more information we can give to the compiler, the better it can do with safety and code generation, so you should always prefer loop when you plan to loop infinitely" - Quoted from https://doc.rust-lang.org/book/loops.html

Here's one more thing you'd probably like about loops in Rust. Loops can have labels. Labels are extremely useful when working with nested loops. Here's a JavaScript example:

```rust
var status1 = true;
var status2 = true;

while (status1) {
  while (status2) {
    status1 = false;
    status2 = false;
  }
}
```

The snippet above can be written with labels as follows:

```rust
'outer_loop: loop {
  'inner_loop: loop {
    break 'outer_loop;
  }
}
```

Read more about loops [here](https://doc.rust-lang.org/book/loops.html).

I think I've covered enough in this post and will stop right here.
