---
layout: post
title:  ZGPS - Achieving Abstraction with Golang
date:   2020-05-30 00:00:00 -0500
categories: Golang
author: Fadi Hanna Al-Kass
handle: https://github.com/alkass
---

One of the early design challenges we faced when designing the DSP (Device Service Provider) project is coming up with a plug-and-play architecture. DSP's main responsibility is to read data from a specific tracking device, process and store the data, or send commands and process responses. But then different devices come with different protocols, though they share common traits like they all (all the ones we now support at least) are TCP based.

Devices, when connected to DSP, are expected to be recognized so they're handed to the proper protocol handler.
Our silver bullet here is abstraction, but then we're using Go, and Go doesn't have native support for abstractions. So how do we solve this?

We came up with a list of functions every device --no matter how distinct-- must support, and we created an interface called `DeviceProtocol` that encompasses all these functions. Our interface will include functions like `SetDeviceConnection`, `SetLogger`, `Read`, `Write`, `GetIMEI`, `SetUnit`, `Acknowledge`, `Reject`, `Handle`, `StoreRecord`, and `Disconnect`.

```go

// DeviceProtocol is a set of functions all supports protocols need to implement.
type DeviceProtocol interface {
	// SetDeviceConnection is called to hand the connection over to the device
	// protocol instance. This is the first thing that happens once a new
	// device is connected.
	SetDeviceConnection(net.Conn)

	// SetLogger keeps a copy of a provided Logger for the protocol to consume.
	SetLogger(logger.Logger)

	// Read allows the protocol to read a specified number of bytes directly
	// from the device. Refer to the ReadParameters structure to find out
	// and/or alter the capabilities of the Read function.
	Read(ReadParameters) (Buffer, error)

	// Write allows the protocol to send byte streams directly to the device.
	// If the number of bytes written does NOT comport with the number of bytes
	// in the slice passed to the function, an error is returned.
	Write([]byte) error

	// GetIMEI does what is necessary for the protocol to retrieve the IMEI from
	// the device. Failures can be expected, and tend to be more occasional, then
	// they need to be, so the caller needs to always watch out for errors. That
	// is, if `error` is anything other than nil, the proper action is to reject
	// the connection and bailout.
	GetIMEI() (int64, error)

	// Acknowledge is automatically called once an IMEI is retrieved and
	// authenticated.
	// NOTE: Units that are marked off as disabled in the database won't
	// be acknowledged.
	Acknowledge() error

	// Reject is automatically called if the device fails to send an IMEI
	// within a specified period of time, or if the IMEI is not found in
	// the database or if the database object is marked off as disabled.
	// This function is automatically called right before Disconnect is.
	Reject() error

	// SetUnit is called once a device is acknowledged. The point of this
	// call is to hand over the Unit object to the protocol so that the
	// protocol is capable of inferring the Unit identifier.
	SetUnit(ms.Unit)

	// Handle is the entry point to a device handler. Every supported protocol
	// needs to implement this function. <b>No abstraction version of this
	// function is provided</b> for the sole reason that different devices
	// come with different protocols.
	Handle() error

	// StoreRecord is responsible for processing one device Record at a time.
	// Record (defined in Record.go) is supposed to at least have a Unit
	// object (defined in ms/Unit.go) and a Position object (defined in
	// ms/Position.go). Whether the Position is valid or not is decided by
	// its own microservice later.
	StoreRecord(*Record) error

	// Disconnect is the last function called towards the end of the lifecycle
	// of a protocol instance. That is, the function is called before the
	// protocol instance is dismissed forever. Protocol lifecycle comes to an
	// end when the device has been idle (no data received from a device within a
	// designated timeframe), or if the device fails to send an IMEI or if the
	// device IMEI is not associated with any Unit objects in the database, or
	// if the Unit object is marked as disabled.
	Disconnect() error
}
```

Soon after a tracking device connects, we call `SetDeviceConnection` with our connection object, we then call `GetIMEI` that'll internally compose a device identifier request and send it to the device using the `Write` function. The response is then retrieved with the `Read` function. Our `GetIMEI` function returns either the device unique identifier or an error (happens when the client fails to provide its IMEI within a designated timeframe, or when invalid data is provided or when the function identifies a suspicious activity).

A lot of these functions will have identical internal implementations. For instance,
* SetDeviceConnection, SetLogger and SetUnit are a common one-liner across all protocol implementations.
* Read and Write will be identical across all protocols given Read is flexible with its ReadParameters and Write blindlessly transmits a given slice of bites. No device-specific intelligence required.
* StoreRecord treats is a device-agnostic microservice-consuming function that doesn't need to be reimplemented for every protocol.
* Disconnects performs some Record-related actions (device-agnostic, remember?) and closes the TCP connection generically.

The way around the issue is to have a form of abstraction that allows protocols to adopt at will and override when needed. Problem is Go isn't an OOP language (that's not to say OOP can't be employed in the language), and so class abstraction isn't a first-class construct in the language. What we do here is we create a DeviceProtocolHeader with our common functions defined and implemented, and aggregate the object in every protocol object we create:

```go


// DeviceProtocolHeader has a set of abstract functions that device protocols tend to have
// in common. Instead of having to re-implement the same errorprocedures for every
// Protocol implementation, it is recommended to include this header and have
// the extra functionality at no cost.
type DeviceProtocolHeader struct {
	logger.Logger
	client     net.Conn
	Unit       ms.Unit
	lastRecord Record
}

// SetConnection ...
func (proto *DeviceProtocolHeader) SetDeviceConnection(client net.Conn) {
	proto.client = client

	// Set timeout to however many seconds ReadTimeout has.
	readParams := DefaultReadParameters()
	proto.client.SetReadDeadline(time.Now().Add(readParams.Timeout))
}

// SetLogger ...
func (proto *DeviceProtocolHeader) SetLogger(logger logger.Logger) {
	proto.Logger = logger
}

// Read ...
func (proto *DeviceProtocolHeader) Read(params ReadParameters) (Buffer, error) {
	buf := make([]byte, params.ByteCount)
	for i := 0; i <= params.MaxTimeoutAttempts; i++ {
		if bufLen, _ := proto.client.Read(buf); bufLen > 0 {
			return Buffer{buf[:bufLen]}, nil
		}
		time.Sleep(params.Timeout)
	}
	return Buffer{}, errors.New("Device read timeout")
}

// Write ...
func (proto *DeviceProtocolHeader) Write(data []byte) error {
	if bCount, err := proto.client.Write(data); err != nil {
		return err
	} else if bCount != len(data) {
		return fmt.Errorf("Failed to write some or all bytes. Expected count: %d, written count: %d", len(data), bCount)
	}
	return nil
}

// SetUnit ...
func (proto *DeviceProtocolHeader) SetUnit(unit ms.Unit) {
	proto.Unit = unit
}

// StoreRecord ...
func (proto *DeviceProtocolHeader) StoreRecord(record *Record) error {
	if record == nil {
		return errors.New("Expected a Record. Received nil")
	}

	record.Unit = proto.Unit

	record.SetLogger(proto.Logger)
	if err := record.Store(); err != nil {
		return err
	}

	if record.Position.Timestamp.After(proto.lastRecord.Position.Timestamp) {
		// Prepare the last possible Record.
		proto.lastRecord.Flags.Set(ms.Last)
		proto.lastRecord.Unit = record.Unit
		proto.lastRecord.Position = record.Position
		proto.lastRecord.Position.ID = 0
		proto.lastRecord.Position.Speed = 0
		// NOTE: Modifying the last Record can be done here.

		proto.Log(logger.INFO, "Last known Position timestamp: %v", proto.lastRecord.Position.Timestamp)
	}

	return nil
}

// Disconnect ...
func (proto *DeviceProtocolHeader) Disconnect() error {
	proto.client.Close()
	if proto.lastRecord.Flags.Has(ms.Last) {
		// Store last record. Whether this is a valid last trip or not
		// is left for upper layers to decide.
		if err := proto.StoreRecord(&proto.lastRecord); err != nil {
			proto.Log(logger.ERROR, "Error: %v", err)
			return err
		}
	}
	return nil
}

```

So, when introducing a new protocol object (say a proprietary ZGPS protocol), we do the following

```go

type ZGPS struct {
    DeviceProtocolHeader
}

func (proto *ZGPS) GetIMEI() (int64, error) {
    // TODO: Here goes our proprietary IMEI retrieval implementation
}


// Acknowledge ...
func (proto *ZGPS) Acknowledge() error {
    // TODO: Here goes our proprietery device/request acknowledgment implementation
}

// Reject ...
func (proto *ZGPS) Reject() error {
	// TODO: Here goes our proprietery device/request rejection implementation
}

// Handle ...
func (proto *ZGPS) Handle() error {
    // TODO: Here goes our proprietary data/request processing implementation
}

```

What have we objectively achieved here?
1. We've set ourselves up for a zero-duplication code base.
2. We've added the ability to introduce higher-level system-wide business logic (take `lastRecord` for example) that future SMEs don't even have to know about, making it easier to specialize at their own space.
3. Bug hunting is now easier given the code is modularized yet cohesive, and fixes will often be made in one place.
