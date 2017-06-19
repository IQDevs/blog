---
layout: post
title:  Enum and Match Systems in Rust
date:   2017-06-17 00:00:00 -0500
categories: Rust
author: alkass
---

  You've probably worked with `enums` before, but if you haven't, they're basically a way to have a selection out of a number of different options. A `Person` struct could contain a `gender` field that points to an enum of three options (`Male`, `Female`, and `Undisclosed`), i.e.:

  ```rust
  enum PersonGender {
    MALE,
    FEMALE,
    UNDISCLOSED,
  }

  struct Person {
    name: String,
    age: i8,
    gender: PersonGender,
  }

  fn main() {
    let person = Person {
      name: "Fadi Hanna Al-Kass".to_string(),
      age: 27,
      gender: PersonGender::MALE,
    };
  }
  ```

  Now, what if a person so chooses to identify as something else? In that case, you could add a 4th option (`Other`) and attach a value of type `String` to it. Here's what your end result would look like:

  ```rust
  enum PersonGender {
    MALE,
    FEMALE,
    UNDISCLOSED,
    OTHER(String),
  }

  struct Person {
    name: String,
    age: i8,
    gender: PersonGender,
  }

  fn main() {
    let person = Person {
      name: "Jake Smith".to_string(),
      age: 27,
      gender: PersonGender::OTHER("Agender".to_string()),
    };
  }
  ```

 Of course `enums` don't have to be part of a struct, and `enum` values don't have to be primitives either. An `enum` value can point to a `struct` or even another `enum` and so on. For instance, you can write a function that returns a status that's either `PASS` or `FAILURE`. `PASS` can include a string while `FAILURE` can contain more information about the severity of the failure. This functionality can be achieved as so:

  ```rust
  enum SeverityStatus {
    BENIGN(String),
    FATAL(String),
  }

  enum FunctionStatus {
    PASS(String),
    FAILURE(SeverityStatus),
  }

  fn compute_results() -> FunctionStatus {
    // Successful execution would look like the following:
    // return FunctionStatus::PASS("Everything looks good".to_string());

    // While a failure would be indicated as follows:
    return FunctionStatus::FAILURE(SeverityStatus::FATAL("Continuing beyond this point will cause more damage to the hardware".to_string()));
  }
  ```

  Now onto `match`. One of the things I love the most about `match` is its ability to unstructure objects. Let's take a second look at our last code snippet and see how we can possibly handle the response coming back to us from `compute_results()`. For this, I'd definitely use a set of `match` statements, e.g.:

  ```rust
  fn main() {
    let res = compute_results();
    match res {
      FunctionStatus::PASS(x) => {
        // Handling a PASS response
        println!("PASS: {}", x);
      }
      FunctionStatus::FAILURE(x) => {
        // Handling a FAILURE response
        match x {
          SeverityStatus::BENIGN(y) => {
            // Handling a BENIGN FAILURE response
            println!("BENIGN: {}", y);
          }
          SeverityStatus::FATAL(y) => {
            // Handling a FATAL FAILURE response
            println!("FATAL: {}", y);
          }
        };
      }
    };
  }
  ```

  Now, if you happen to add more options to any of the two `enums` (say, a `WARN` option to `FunctionStatus` or `UNCATEGORIZED` to `SeverityStatus`), the compiler will refuse to compile your code until all possible cases are handled. This is definitely a plus as it forces you to think about all the paths your code could take.

  However, there will be times when you really only want to handle specific cases and not the rest. For instance, we may only be interested in handling the case of failure of `compute_results()` and ignore all passes. For that you could use the `_` case. `_` in the case of a `match` statement or expression means "everything else". So, to write our `FunctionStatus` handling functionality in a way when only failures are handled, we could do the following:

  ```rust
  fn main() {
    let res = compute_results();
    match res {
      FunctionStatus::FAILURE(severity) => {
        match severity {
          SeverityStatus::FATAL(message) => {
            println!("FATAL: {}", message);
          }
          SeverityStatus::BENIGN(message) => {
            println!("BENIGN: {}", message);
          }
        };
      }
      _ => {
        // Here goes the handling of "everything else", or it can be left out completely
      }
    };
  }
  ```

  The same thing can be applied to `SeverityStatus`. If you want to ignore benign failures, you can replace that specific case with `_`.

  The only drawback to using `_` is that "everything else" will include any options you include in future instances, so I'd personally strongly advocate against the use of `_`. If you want to leave some cases unhandled, you could still include them and let them point to an empty block of code, e.g.:

  ```rust
  fn main() {
    let res = compute_results();
    match res {
      FunctionStatus::FAILURE(severity) => {
        match severity {
          SeverityStatus::FATAL(message) => {
            println!("FATAL: {}", message);
          }
          SeverityStatus::BENIGN(_) => {
            // Leaving this case unhandled
            // NOTE: you can't print _. If you change your mind and decide to
            // actually handle this case, replace `_` with a valid variable name.
          }
        };
      }
      FunctionStatus::PASS(_) => {
        // Leaving this case unhandled
      }
    };
  }
  ```

  One last thing I wanted to touch on before I wrap up with this post. When using `match` to unstructure objects, you'll come across projects with multiple fields, or even worse, nested object structures. Our `Person` structure can be used as an example here. How would we match this object? following's how.

  Say you're interested in only unstructuring the gender and the age of a person object. You'd do this as follows:

  ```rust
  fn main() {
    let person = Person {
      name: "Fadi Hanna Al-Kass".to_string(),
      age: 27,
      gender: PersonGender::MALE,
    };

    match person {
      Person { age, gender, .. } => {
        println!("age: {}", age);
        match gender {
          PersonGender::MALE => {
            println!("gender is male");
          }
          PersonGender::FEMALE => {
            println!("gender is female");
          }
          PersonGender::UNDISCLOSED => {
            println!("gender Undisclosed");
          }
          PersonGender::OTHER(g) => {
            println!("gender: {}", g);
          }
        };
      }
    }
  }
  ```

  That's all I have for now. Don't hesitate to hit me up if you have questions.
