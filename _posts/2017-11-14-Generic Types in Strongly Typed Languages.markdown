---
layout: post
title:  Generic Types in Strongly Typed Languages
date:   2017-04-11 00:00:00 -0500
categories: TypeScript
author: Alex Corvi
handle: https://github.com/alexcorvi
---

Few days ago, I wrote [mongots](https://github.com/alexcorvi/mongots), an alternative API for [MongoDB](https://www.mongodb.com/) to make it work better with [TypeScript](https://www.typescriptlang.org/) (a strongly-typed language that compiles to JS) on the NodeJS environment.

"Alternative" is an overstatement, since it is totally built on top of the native MongoDB driver, and it's not an ODM like [Mongoose](http://mongoosejs.com/), and it doesn't provide any new functionality.

Then why did I write it? The answer is: "stronger types". The native MongoDB driver has [its type definitions in the DefinitelyTyped repository](https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/mongodb), can be easily installed, but I was annoyed by all the `any` keywords it was littered with. It's not that the authors don't know how to make it more strongly typed, it's just that MongoDB native driver API has been designed in a way (for JavaScript) that makes strong typing almost impossible with some cases.

My journey in creating this library has given me an insight on how generic types can be so helpful in some cases, and after seeing some tweets criticizing TypeScript's generic types, I've decided to write this post.

Throughout this post, I'll use TypeScript as an example, because everyone with a JavaScript background can comprehend the code, and personally, it's my language of choice.

## Introduction to Generic Types

Let's start with an example, a common pattern for JavaScript developers is to copy JSON objects using `JSON.stringify` and `JSON.parse`, like this:


```javascript
function copyObject (obj) {
    const string = JSON.stringify(obj);
    const theCopy = JSON.parse(string);
    return theCopy;
}
```

The parameter `obj` in the above example can be anything, it can be a number, a string, an array, object literal ...etc. So adding type definitions might be quite useless (without generic types):

```typescript
function copyObject (obj: any): any {
    const string = JSON.stringify(obj);
    const theCopy = JSON.parse(string);
    return theCopy;
}
```

But with generic types, our function becomes as strongly typed as any function can be:

```typescript
function copyObject<T>(obj: T): T {
    const string = JSON.stringify(obj);
    const theCopy = JSON.parse(string);
    return theCopy;
}

const myObject = { a: 0, b: 3 };

const theCopy = copyObject(myObject);

console.log(theCopy.a); // OK!
console.log(theCopy.b); // OK!
console.log(theCopy.c); // Compile Error!
```

The syntax for writing generic types is like many languages, before the parameters using the angle brackets.

Another example of how you can make use of generic types is when requesting data from a server.

```typescript
function getFromServer<DataSchema>(url: string): Data {
    // make the request
    // and return the data
}

interface Employees {
    departmentA: string[];
    departmentB: string[];
};

const employees = getFromServer<Employees>("http://www.example.com/api/employees.json");

console.log(employees.departmentA); // OK!
console.log(employees.departmentB); // OK!
console.log(employees.departmentC); // Compile error!
console.log(employees.departmentA.length) // OK!
console.log(employees.departmentA + employees.departmentB);
// ^ Compile errors because they are arrays
```

The previous example shows how generic types are treated like additional arguments in the function. And that's what they really are, _additional arguments_. In the first example, however, TypeScript was smart enough to determine the type of the passed value, and we did not need to pass any generic type values in angle brackets. Typescript can also be smart and notify you when you do something like this:

```typescript
function copyObject<T>(obj: T): T {
    const string = JSON.stringify(obj);
    const theCopy = JSON.parse(string);
    return theCopy;
}

const myObject = { a: 0, b: 3 };

const theCopy = copyObject<number>(myObject);
// ^ Compile Error:
// Argument of type '{ a: number; b: number; }'
// is not assignable to parameter of type 'number'.
```

Now if you're writing your server and your front end with typescript you don't have to write the interface `Employees` twice, what you can do is structure your project in a way that the server (back-end) and the front-end share a directory where you keep type definitions.

So, in the types directory, you can have this file `interface.employee.ts`

```typescript
export interface Employee {
    name: string;
    birth: number;
}
```

In your server:

```typescript
import { Employee } from "../types/interface.employee.ts"
const employeesCollection = new myDB.collection<Employee>("employees");
```

And in your front end:

```typescript
import { Employee } from "../types/interface.employee.ts"
const employees = getFromServer<Employee>("http://www.example.com/api/employees/ahmed.json");
```

And that barely scratches the surface of how powerful generic types can be.


## Restricting Generic Types

You can also restrict how generic your generic types can be, for example, let's say that we have a function that logs the length of the passed value (whatever it is):

```javascript
function logLength (val) {
    console.log(val.length);
}
```

But there are only two built-in types in javascript that have the length property, `String` and `Array`. So what we can do is set a constraint on the generic type like this:

```typescript
interface hasLength {
    length: number;
}

function logLength <T extends hasLength> (val: T) {
    console.log(val.length);
}

logLength("string"); // OK
logLength(["a","b","c"]); // OK
logLength({
    width: 300,
    length: 600
}); // Also OK because it has the length property
logLength(17); // Compile Error!
```

## Index Types With Generic Types

A more elaborate example is a function that copies (Using `JSON.stringify` and `JSON.parse`) a property of any object that it receives.

```typescript
function copyProperty<OBJ, KEY extends keyof OBJ>(obj: OBJ, key: KEY): OBJ[KEY] {
    const string = JSON.stringify(obj[key]);
    const copied = JSON.parse(string);
    return copied;
}

const car = { engine: "v8", milage: 123000, color: "red" };
const animal = { name: "Domestic Cat", species: "silvestris" };

copyProperty(car, "engine"); // OK
copyProperty(car, "color").length; // OK
copyProperty(car, "milage").length; // Compile error, because it's a number!
copyProperty(animal, "color"); // Compile error, because "color" is not a property on that object!
// so you can only pass the object's property names and
// typescript will be smart enough to determine their values
```

Now let's step it up a bit, by making our `copyProperty` able to copy multiple properties on the same call, so the second argument, will be an array of property names that will be copied and returned as an array.

```typescript
function copyProperties<OBJ, KEY extends keyof OBJ>(obj: OBJ, keys: Array<KEY>): Array<OBJ[KEY]> {
	return keys
		.map(x => JSON.stringify(obj[x]))
		.map(x => JSON.parse(x))
}

const car = { engine: "v8", milage: 123000, color: "red" };

const a: string[] = copyProperties(car, ["engine", "color"]); // OK
const b: string[] = copyProperties(car, ["engine", "milage"]);
// ^ Compile Error! because one of the array values is a number
// and that's because one of the properties
// we're copying is "milage".
```

## Mapped Generic Types

Sometimes, we'd like to modify the values of the object while copying it. For example, we have this document object:

```typescript
const document = {
    title: "New Document",
    content: "document content ...",
    createdAt: 1510680155148
};
```

We'd like the copy to hold a different value for the `createdAt` property. So we'll write a function that copies objects and takes a second argument that will be property names and values to be edited.

```typescript

// this is a generic type, it takes any type (object)
// as an argument and returns the same type
// but with every property being optional
type Partial<T> = {
	[P in keyof T]?: T[P]
}

function copyAndModify<T>(obj: T, mods:Partial<T>): T {
	const string = JSON.stringify(obj);
	const copy = JSON.parse(string);
	Object.keys(mods).forEach(key => {
		copy[key] = mods[key];
	});
	return copy;
}


const doc = {
    title: "New Document",
    content: "document content ...",
    createdAt: 1510680155148
};


copyAndModify(doc, { createdAt: new Date().getTime() }) // OK
copyAndModify(doc, { title: "New title" }) // OK
copyAndModify(doc, { content: 0 })
// Compile Error!
// Because content is a string, so we must
// put a string when modifying it


copyAndModify(doc, { author: "Some one" })
// Compile Error!
// Because we did have the property author on the original document

```

So those were some of the ways that you can utilize generic types to write a more safe and expressive code.

Finally, I'd like to finish this post with one of my favorite quotes:

> Well engineered solutions fail early, fail fast, fail often.

Happy coding!
