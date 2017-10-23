---
layout: post
title:  Remote Procedure Calls in C
date:   2017-10-22 00:00:00 -0500
categories: C
author: alkass
---

I have recently put together a quick Remote Procedure Call (RPC) demo in C and checked it into [my Github account](https://github.com/Alkass/cRPC), then I realized I still have a couple of minutes left on my hands, so I decided to write a walk-through blog post.

Remote Procedure Calls, if you're not familiar with them, are library implementations that allow you to remotely host some code (normally in the form of classes and functions) and invoke those classes and functions as needed.

Why would you ever want to do that? I mean, what benefit do you get from having pieces of your code run on a remote server? There actually are a number of valid reasons why that would be the case, but I'm only interested in addressing two as I don't want to run off topic. One reason is performance. Say a mobile app you've been writing requires high processing power availability to compute some complex mathematical equations. Most mobile devices aren't meant to be cutting-edge processing devices that are able to scale up to any task you hand to them. In a case like this, you'd probably better off hand the calculation task to a more processing-ready device and ask for the results since that's all you're really interested in. Another reason is security. If you're developing a banking solution, for instance, chances are you want to make it as hard as possible for reverse engineers to hack into your code and find out how deposits, withdraws, and transactions are made. RPCs are a viable option here.

Now onto some technical stuff...

If you've ever written TCP-based projects in your life, chances are you've serialized data at one end and deserialized it at the other end. Serialization often takes the form of a string that is supposedly safe to parse. If you're a performance rat like myself, you're probably seeing a problem already. String parsing is expensive and error prone. Having to parse a string on the fly means more code, more code (in most cases) means (1) slower code and (2) more possible bugs. More bugs means more time on debugging and less on productivity. You see where I'm going with this.

What I'd suggest as a better alternative is communicating through a stream of bytes that conform to a set of standards.

Say you're building a remote controller calculator with the most four basic operations (addition, subtraction, multiplication, and division). Now to be honest, I don't know why you'd ever want to build this calculator. That'd be stupid. But for the sake of clarity, I couldn't have thought of an easier example.

To properly send a request to your server, you'll need to have an agreement on a request standard. Our request standard can be implemented as a `C` `struct` with a pre-determined number of bytes. All requests sent to the server must be fit within this number of byte count so the server will always know how many bytes to read at a time that make up a single request.

Before we implement our `Request` `struct`, let's first decide what fields we need to include.

What we could do is always start with a conventional acknowledgment byte that helps both the server and the client decide whether the number of bytes read make up a valid request/response to be processed. This is extremely useful when debugging cases when one side of your project starts to misbehave, then you could do some debugging and make sure outgoing requests or incoming responses are valid by checking against the acknowledgment byte. We shall call this field `ack` for ease of writing.

Another useful field we could include is a request identifier. Identifiers are useful in cases when the client isn't reading the responses right away and may have difficulty telling the responses apart. What we could do here is include the identifier as part of the response we send back as a server.

Our third field will be the operation field. This field tells us what function the user wants to execute.

We'll also need two fields for the parameters.

Sounds about it!

Now, 1 field for `ack`, 1 for `id`, 1 for `op` and 2 for `params` add up to 5 bytes. Every time the server attempts to read a request, it'll read exactly 5 bytes.

Our `strcut` will look like so:

```c
typedef struct {
  char ack;
  char id;
  char op;
  char params[2];
} Request;
```

Characters in `C` are 1 byte (8-bit) integers. because `byte` isn't a valid data type in `C`, we can type-define it as follows:

```c
typedef char byte;
```

and use it as so:

```c
typedef struct {
  byte ack;
  byte id;
  byte op;
  byte params[2];
} Request;
```

Our acknowledgment byte is consensual between the server and the client. We'll make it 10 and set it as follows:

```c
#define ACK 0xA
```

Our operations can be part of an `OpType` `enum` as follows:

```c
typedef enum {
  ADD = 0,
  SUB,
  MUL,
  DIV
} OpType;
```

Which allows us to replace the `byte` type in our `Request` `struct` with `OpType`, except we'll run into a problem that is `enums` in `C` are of type integer (4-bytes long), but this issue can be overcome by enabling the `-fshort-enums` `GCC` switch that reduces the size of enums to 1 byte. Now we can re-write our `Request` `struct` as follows:

```c
typedef struct {
  byte ack;
  byte id;
  OpType op;
  byte params[2];
} Request;
```

Now let's define our `Response` `struct`.

We'll need a starting acknowledgment byte, so that's one.

We'll also need to include the request identifier. That's two.

Not every request sent to the server is a valid request. The user may be requesting a functionality that has not been yet implemented or does not exist. For this, we could include a status field that helps the client decide whether the request was handled successfully.

If the request is handled successfully, we'll need to return some data to the user. We'll need a data field to contain the result.

That adds up to four bytes. Here's what our `Response` object will look like:

```c
typedef struct {
  byte ack;
  byte id;
  byte status;
  byte data;
} Response;
```

Now assume you have a server up and running waiting to process some requests. You'd declare a `Request` object and `Response` object as follows:

```c
Request req  = {0};
Response res = {0};
```

> The `{0}` is syntactic sugar that tells the compiler to set all values within the structure to zero.

You'd then be reading the request as follows:

```c
read(comm_fd, (byte*)&req, sizeof(Request));
```

> The `(byte*)&req` typecasts our `Request` struct into a byte pointer.

After a so number of bytes (5 in our case) has been read and converted to a `Request` object, we can go ahead and verify that the request is valid by checking against our consensual acknowledgment byte as follows:

```c
if (req.ack == ACK) {
  // Request is successful. Move forward
}
```

The first thing we could do is prepare the `ack` and `id` fields in our Response object as follows:

```c
res.ack = req.ack;
res.id = req.id;
```

Then call a `handleRequest` function that's responsible for handling the request and handing back the data. This function (and its callees) are implemented as follows:

```c
int handleAdd(const Request* req, Response* res) {
  printf("res->data = %d + %d\n", req->params[0], req->params[1]);
  res->data = req->params[0] + req->params[1];
  return true;
}

int handleSub(const Request* req, Response* res) {
  printf("res->data = %d - %d\n", req->params[0], req->params[1]);
  res->data = req->params[0] - req->params[1];
  return true;
}

int handleMul(const Request* req, Response* res) {
  printf("res->data = %d * %d\n", req->params[0], req->params[1]);
  res->data = req->params[0] * req->params[1];
  return true;
}

int handleDiv(const Request* req, Response* res) {
  printf("res->data = %d / %d\n", req->params[0], req->params[1]);
  res->data = req->params[0] / req->params[1];
  return true;
}

int handleRequest(const Request* req, Response* res) {
  switch (req->op) {
    case ADD:
      return handleAdd(req, res);
    case SUB:
      return handleSub(req, res);
    case MUL:
      return handleMul(req, res);
    case DIV:
      return handleDiv(req, res);
    default:
      return false;
  }
}
```

And can be called as follows:

```c
if (handleRequest(&req, &res)) {
  res.status = true;
}
else {
  res.status = false;
}
```

The response can be sent to the client as follows:

```c
write(comm_fd, (byte*)&res, sizeof(Response));
```

And there we have a fully functional RPC server implementation capable of performing just about anything when expanded.
