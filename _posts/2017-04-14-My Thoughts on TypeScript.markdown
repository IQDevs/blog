---
layout: post
title:  My Thoughts on TypeScript
date:   2017-04-14 00:00:00 -0500
categories: TypeScript
author: alexcorvi
---

I was introduced to TypeScript when it first came with angular 2. However, I tried to avoid it as much as possible. This was actually the main reason of why I left angular in favor of Vue. "A new quirky front-end language is the last thing I would need," I thought.

That was true until I was deep into my [NLP](https://github.com/finnlp/) project in late 2016. The code base was relatively large, so many modules and functions. A friend of mine, recommended TypeScript, and I tried it. I've been working with it for the last 4 months, and here's my thoughts.


## Type checking is more important than what you think

You might ask: why would anyone spend their time and energy writing:

```typescript
function add (a: number, b: number): number {
	return a + b;
}
```

Instead of:

```javascript
function add (a, b) {
	return a + b;
}
```

The TL:DR; answer is:

- Reduced bugs.
- Compile time errors instead of runtime errors.
- Better tooling.
- Code completion.

As for time and energy, developers usually spend more time reading code than writing it. TypeScript is clean and well-designed (a Microsoft product by Anders Hejlsberg the author of C#, Turbo Pascal and Delphi). So while you're going to spend a little bit extra time writing code, but with better tooling you'll be reading less. Especially when working in a team.

### Reduced bugs and compile time errors

Take the previous example for instance:

```typescript
let a = 1;
let b = "string";
add(a, b);
```

In javascript, the aforementioned code will act like nothing is wrong and would just return `"1string"`, i.e. It will fail silently, not even a runtime error will be produced. Which is the last thing you would want.

A wise man once said:

> Well engineered solutions fails early, fails fast, fails often.

And I can't emphasize enough how true this statement is.

You might argue that "no one would pass a string to a function called `add`, that's too obvious". I agree, however, imagine for a second a larger code base, many functions, classes, abstractions, on multiple modules. Things can get out of hands in JavaScript pretty quickly.

Have a look at this code for instance:

```javascript

function getAuthorLines(text) {
	return text.match(/^author: (.*)$/gmi);
}

function getAuthorNames(line) {
	return lines.map((line)=>line.substr(8))
}

let text = `
Paper title: TypeScript for the Win
Author: Alex Corvi
Author: John Doe
Author: Jane Doe
`;

console.log(getAuthorNames(getAuthorLines(text)));

```

What do you expect the result? You guessed it, it's:

```javascript
[
	"Alex Corvi",
	"John Doe",
	"Jane Doe",
]
```

Now add the following line:

```javascript
console.log(getAuthorNames(getAuthorLines(text.substr(0,30))));
```

Ouch! That's a runtime error! That's because `String.match` doesn't always return an array, it might return `null`.

Here's another code, can you spot what's wrong?

```javascript
var theThing = null;
var replaceThing = function () {
	var priorThing = theThing;
	var unused = function () {
		if (priorThing) {
			console.log("hi");
		}
	};
	theThing = {
		longStr: new Array(1000000).join('*'),
		someMethod: function () {
			console.log("abc");
		}
	};
};
setInterval(replaceThing, 1000);
```

That was a classic example of how you can cause memory leaks in JavaScript. This one leaks 1 MegaByte per second. In TypeScript, You can't reassign the `theThing` variable from `null` to `Object`.

That doesn't mean your applications will be bug-free. That's never true, for any language. But surely, using TypeScript you can avoid a whole class of bugs.

One might argue, that being an experienced developer will help to avoid such bugs. Again, I agree, but:

- TypeScript (or static typing in general) is like a seat belt, not matter how good driver you are, you should always wear one.
- The JavaScript community, is heavily reliant on modules (node modules) and those have a huge variance in quality.

> Static typing is like a seat belt, no matter how good driver you are, you should always wear one.

### Better tooling and code completion

Code analysis, like abstract syntax trees, helps a lot with tooling. Code analysis is what makes code completion, linting, debugging tools, tree shaking tools possible. However, the dynamic nature of JavaScript makes it really hard for such tools to truly understand your code.

Take for example [rollup](https://github.com/rollup/rollup), a bundling tool, have been recently integrated into Vue.js and React, that is supposed to tree-shake your bundles making them lighter by removing inaccessible and dead code. The author of which, Rich Harris, [mentions](https://github.com/rollup/rollup/wiki/Troubleshooting#tree-shaking-doesnt-seem-to-be-working):

> Because static analysis in a dynamic language like JavaScript is hard, there will occasionally be false positives [...] Rollup's static analysis will improve over time, but it will never be perfect in all cases – that's just JavaScript.

So there's really a limit to what can be achieved in JavaScript tooling.

One of TypeScript's goals was to remove such limits, and they sure did.

Here are my favorites:

- Great code completion, with __Intellisense__.
- Goto symbol and show all symbols.
- Better code reformatting.
- A bunch of features that are provided with TSLint but not in ESLint.
- [Easy refactoring (e.g. renaming a symbol).](https://johnpapa.net/refactoring-with-visual-studio-code/)

> __IntelliSense__ is the general term for a number of features: List Members, Parameter Info, Quick Info, and Complete Word. These features help you to learn more about the code you are using, keep track of the parameters you are typing, and add calls to properties and methods with only a few keystrokes.
> Microsoft Developer Network

## The Syntax

### But I like ES6...

I hope I've convinced you enough to try out TypeScript. The syntax shouldn't be alien to a JavaScript programmer. Especially those who have tried ES6/ES7.

TypeScript brands itself as a _"JavaScript Superset"_, so all valid JavaScript (ES3, ES5, ES6, ES7 ...etc) is valid TypeScript. Everything you've been accustomed to, from flow controls to assignments.

So instead of having a totally new syntax (like PureScript, Elm and Dart), TypeScript builds on top of JavaScript syntax. Yet, it adds it's own flavor on top.

### Enough talk, show me the code

I can easily bet that all javascript developers will be able to understand the following piece of code:

```typescript

let x: number = 1;
let y: number = 500;

function getRand (min: number, max: number): number {
	return Math.floor(Math.random() * (max - min)) + min;
}

console.log(getRand(x, y));

```

So is this:

```typescript

class House {
	address: string;
	bedrooms: number;
	area: number;
	safeNeighborhood:boolean;
	goodCondition:boolean;
	private priceCoefficient: number = 65;
	get price(): number {
		return ((this.bedrooms * this.area) +
			(this.safeNeighborhood ? 1000 : 0 ) +
			(this.goodCondition ? 1000 : 0 )) * this.priceCoefficient;
	}
}

let myHouse = new House();
myHouse.bedrooms = 4;
myHouse.area = 300;
myHouse.safeNeighborhood = true;
myHouse.goodCondition = true;

console.log(myHouse.price)

```

That was a major portion of what you'll find in a TypeScript project.

### Interfaces

Interfaces, simply put, is a way to declare JSON object types.

You can write your object type definition like this:

```typescript
let myObj: { a: number; str: string; } = {
	a: 123,
	str: "my string"
}
```

Or you can declare a re-usable interface:

```typescript
interface MyObj {
	a: number;
	str: string;
}

let myObj1: MyObj = {
	a: 123,
	str: "string"
}


let myObj2: MyObj = {
	a: 456,
	str: "another string"
}
```

### Compilation

To be able to work in the browser & node, TypeScript compiles to JavaScript. Now you may have this preconceived notion of the compiled code being unreadable and uglified, but reality is exactly the opposite.

After type-checking, the compiler will emit very clean and readable code. So this:

```typescript
let x: number = 1;
let y: number = 500;
function getRand (min: number, max: number): number {
	return Math.floor(Math.random() * (max - min)) + min;
}
console.log(getRand(x, y));
```

Will compile to this:

```javascript
var x = 1;
var y = 500;
function getRand(min, max) {
	return Math.floor(Math.random() * (max - min)) + min;
}
console.log(getRand(x, y));
```

Have a look at the [TypeScript Playground](http://www.typescriptlang.org/play/) where you can compile TypeScript immediately in your browser. Yes, it's being compiled in the browser. This is possible since the TypeScript compiler is written in TypeScript.

And while you're at it, you'll notice 2 things:

- TypeScript compiler is really fast!
- You can compile your ES6/ES7 code all the way down to ES3. No Babel required.

> You won't have to use Babel, buble anymore. TypeScript bridges the gap between the recent versions of JavaScript and what's available on every modern browser, by compiling your code down to even ES3. However, you still have the option to compile to any ES version you like.

## Type inference

One of the killer features of TypeScript, is a really good type inference. Meaning that sometimes you don't even have to declare the type of the variable.

For example:

```typescript

let a = 1; // inferred as a number
let str = "string"; // inferred as a string

// function return type will also be inferred
function add (a:number, b:number) {
	return a + b;
}

let b = add(1, 3); // type inferred as a number
let x = add(c, b); // compiler will produce an error
```

Another advanced example:

```typescript
// Notice how we won't declare any types:
function myFunc (param) {
	return {
		n: 0,
		str: "myString",
		obj: {
			obj: {
				obj: {
					someVal: param > 5 ? "myString" : param > 4 ? {a:5} : ["myString", 14]
				}
			}
		}
	}
}
// hover over someVal
myFunc(10).obj.obj.obj.someVal
```

Now when hovering over `someVal` you'll notice that it's type is declared as:

```
string | Array<string|number> | {a: number;}
```

[Try it](https://goo.gl/Zw11Yv)


## Node and TypeScript

Node.JS support was a priority when developing TypeScript. Your TypeScript code can be distributed as a node module, consumed in JavaScript just like any JavaScript module, and consumed in TypeScript with type definitions included, all while writing only once.

### Authoring and distributing TypeScript Node Modules

When compiling your javascript you can tell the compiler to emit type definitions (only type definitions, no logic) in a separate file that can be discoverable by TypeScript, yet does not affect your module when consumed in a JavaScript project (unless your editor wanted to be smart about it).

All that you have to do is include the `declaration:true` in your `tsconfig.json` file:

```javascript
{
	"declarations":true
}
```

then refer to this file in your `package.json`:

```javascript
{
	"types":"./dist/index.d.ts"
}
```

### Consuming JavaScript Node Modules In TypeScript

What if you wanted to consume a module that was written in JavaScript? Express for example. Your editor (e.g. VSCode) can only try to have an idea about the imported module, but as we've discussed above, tools are actually limited by the dynamic nature of JavaScript.

So your best bet is head to [the DefinitelyTyped repository](https://github.com/DefinitelyTyped/DefinitelyTyped) and find if a there's a type definition for the module you're consuming.

The good news is that [the DefinitelyTyped repository](https://github.com/DefinitelyTyped/DefinitelyTyped) have over 3000 modules. Chances are you're going to find the module you're about to use.

#### Example: Consuming Express in TypeScript

Install the types:

```
npm i --save-dev @types/express
```

```typescript
// import
import { Request, Response, NextFunction } from "@types/express";
// declare
function myMiddleWare (req: Request, res: Response, next:NextFunction) {
	// middleware code
}
```

## React and TypeScript

TypeScript, being an open-source community driven project, have added support for react in a really nice way.

Just like you're going to rename your `.js` files to `.ts`, your `.jsx` files should be `.tsx`. And that's it, now install React's type declarations from the definitely typed repository, and feel how good it is to have everything in your project to be strong-typed. Yes! Even HTML! and CSS!

## Dart, Flow, PureScript, Elm

- __Flow__: Is a facebook product. However, it's not a language, it's just a type-checker. TypeScript does what Flow does in addition to many other features. Also it has a larger community.
- __Dart__: Although very powerful, but Dart's syntax is different from JavaScript. I think that's the main reason why it didn't catch up with the community as TypeScript did. TypeScript embraced the new ES6/ES7 features and built it's foundation on top of them.
- __PureScript__ & __Elm__: Are trying to achieve different thing, pure functional programming language, that compiles to JavaScript.

## Closing statement

I've been developing with JavaScript for at least 5 years. However, After trying TypeScript for mere 4 months, working with JavaScript feels like walking on thin ice, you may make it for 10 meters or so, but you shouldn't go any longer.

I can now understand why there are so many well-educated developers disliking the dynamic nature of JavaScript.

## Resources

- [The official documentation](http://www.typescriptlang.org/docs/tutorial.html).
- Anders Hejlsberg Talks about TypeScript: [1](http://video.ch9.ms/ch9/4ae3/062c336d-9cf0-498f-ae9a-582b87954ae3/B881_mid.mp4) [2](https://www.youtube.com/watch?v=s0ecDXWvLmU) [3](https://www.youtube.com/watch?v=eX2PXjj-KDk).
- [Definitely Typed](http://definitelytyped.org/).
- Editors and IDEs plugins: [Sublime Text](https://github.com/Microsoft/TypeScript-Sublime-Plugin) [Atom](https://atom.io/packages/atom-typescript) [Eclipse](https://github.com/palantir/eclipse-typescript) [Vim](https://github.com/Microsoft/TypeScript/wiki/TypeScript-Editor-Support#vim).
