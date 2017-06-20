---
layout: post
title:  Crafting Code - Building Common Interfaces
date:   2017-06-20 00:00:00 -0500
categories: Rust
author: alkass
---

When writing Libraries, APIs, and SDKs, the less stuff you ask your user to memorize the better it looks to you and feels to them. For instance, if you were to write a Math library that performs some arithmetic operations, you could write your library functions ass so:

```rust
fn add(op1: f32, op2: f32) -> f32 {
  op1 + op2
}

fn sub(op1: f32, op2: f32) -> f32 {
  op1 - op2
}

fn mul(op1: f32, op2: f32) -> f32 {
  op1 * op2
}

fn div(op1: f32, op2: f32) -> f32 {
  op1 / op2
}
```

And that'll require the user to import his/her desired function or set of functions when needed. This is fine, but wouldn't it be better if you could provide only one function that does all these operations? We're going to call this function a common interface, but this procedure is called a passthrough in the professional field. A passthrough function is a multi-purpose entry point to a set of different classes or functions. In the case of our Math library, we could have our passthrough function written as follows:

```rust
fn passthrough(operation: &'static str, op1: f32, op2: f32) -> f32 {
  return match operation {
    "+" => add(op1, op2),
    "-" => sub(op1, op2),
    "*" => mul(op1, op2),
    "/" => div(op1, op2),
    _ => 0 as f32,
  };
}
```

That allows us to do something like this:

```rust
let res = passthrough("+", 10 as f32, 12.3);
```

Instead of this:

```rust
let res = add(32.4, 12 as f32);
```

But there's more we could do here. So, for instance, instead of specifiny the operation as a string and expose our code to all sorts of correctness bugs (afterall, our `passthrough()` function won't warn us about an invalid operation), we could do something like this:

```rust
enum OperationType {
    ADD,
    SUB,
    MUL,
    DIV,
}

fn passthrough(operation: OperationType, op1: f32, op2: f32) -> f32 {
  return match operation {
    OperationType::ADD => add(op1, op2),
    OperationType::SUB => sub(op1, op2),
    OperationType::MUL => mul(op1, op2),
    OperationType::DIV => div(op1, op2),
  };
}
```

That will at least force the user to select one of many options, and anything that's not on the list won't slide. But that's not all either. There's still more that can be done to tweak our code.

Notice how `passthrough` will always take two operands, no more or less parameters. What if, in the future, you decide to add an operation that requires only one operand (a square root function for example). You may be able to get away with something as easy as ```passthrough(OperationType::SQRT, 25, 0)```, but neither looks clean not is something a team of professional developers would approve of. Perhaps we could turn our operands into a flexible object, and for the sake of simplicity we shall call our object `Request` and have it implemented as follows:

```rust
enum Request {
    NoOps,
    OneOp(f32),
    TwoOps(f32, f32),
    ThreeOps(f32, f32, f32),
}
```

And re-implement our `passthrough()` function to work with a `Request` object as follows:

```rust
fn passthrough(operation: OperationType, req: Request) -> f32 {
  return match operation {
    OperationType::ADD => add(req),
    OperationType::SUB => sub(req),
    OperationType::MUL => mul(req),
    OperationType::DIV => div(req),
  };
}
```

And re-implement our arithmetic functions to use our `Request` object instead of straight operands:

```rust
fn add(req: Request) -> f32 {
  return match req {
    Request::NoOps => 0 as f32,
    Request::OneOp(a) => a,w
    Request::TwoOps(a, b) => a + b,
    Request::ThreeOps(a, b, c) => a + b + c,
  };
}
```

And the resulting code will then allow us to do something like this:

```rust
let res = passthrough(OperationType::ADD, Request::NoOps);
```

Or this:

```rust
let res = passthrough(OperationType::ADD, Request::TwoOps(10.1, 40.5));
```

Or this:

```rust
let res = passthrough(OperationType::ADD, Request::ThreeOps(10.1, 40.5));
```

There's still more room for improvement, but you get the point.

So, "why should I consider a passthrough design?", you may wonder! Here are some reasons why:

* Passthroughs allow you to completely maintain your own code when working with a team of developers.
*
