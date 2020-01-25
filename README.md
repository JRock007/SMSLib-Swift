# SMSLib-Swift
A Swift library to access a mac's accelerometer data based on [SMSLib](http://www.suitable.com/tools/smslib.html), which uses laptops' Sudden Motion Sensor.

Using Swift 5, XCode 11 and macOS 10.15.

## Usage

```swift
// Create a instance of the swift interface
private let smsLib = SMSLibInterface()

// Callibrate the sensor
do {
    try smsLib.callibrate()
} catch {
    print("SMSLib failed to callibrate: \(error)")
    return
}

// Read from the sensor
do {
	let acceleration = try smsLib.read()
	print(acceleration)
} catch {
    print("Failed to read from sensor: \(error)")
    return
}
```

## Install

1. Copy the contents of the `SMSLib` folder to your project,
2. In your target's Build Settings, set the option `Objective-C Bridging Header` to `SMSLib/SMSLib-Bridging-Header.h`,
3. Either add a `com.apple.security.temporary-exception.sbpl` entitlement with a value of `(allow iokit-open)`, or remove entitlements.

## Limitations

The Sudden Motion Sensor is only included in macs with an HDD. Some more recent laptops, which only contain an SSD, do not have this sensor, and will thus raise an error during calibration.

Usage of IOKit may prevent a macOS app from being released on the AppStore.