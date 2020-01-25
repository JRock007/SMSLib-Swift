//
//  ViewController.swift
//  SMSLib-Swift
//
//  Created by Jean-Romain on 25/01/2020.
//  Copyright © 2020 JustKodding. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var xAccelLabel: NSTextField!
    @IBOutlet var yAccelLabel: NSTextField!
    @IBOutlet var zAccelLabel: NSTextField!

    /// Frequency at which the accelerometer is polled.
    ///
    /// Value must be between 1 mHz and 1 kHz. Default is 60 Hz.
    var pollingFrequency: Double {
        get {
            return freq
        }
        set {
            freq = max(0.001, min(newValue, 1000))
        }
    }

    /// The frequency at which to poll the accelerometer.
    private var freq: Double = 60

    /// Swift interface to the SMSLib, which polls the accelerometer.
    private let smsLib = SMSLibInterface()

    private(set) var acceleration: SMSVector4 = .zero

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        do {
            try smsLib.callibrate()
            pollAccelerometer()
        } catch {
            print("SMSLib failed to callibrate: \(error)")
        }
    }

    private func pollAccelerometer() {
        do {
            acceleration = try smsLib.read()
            xAccelLabel.stringValue = "x: \(acceleration.x)"
            yAccelLabel.stringValue = "y: \(acceleration.y)"
            zAccelLabel.stringValue = "z: \(acceleration.z)"
        } catch {
            print("Read error: \(error)")
        }

        let nextUpdate: DispatchTime = .now() + 1 / freq
        DispatchQueue.main.asyncAfter(deadline: nextUpdate, execute: {
            self.pollAccelerometer()
        })
    }

}
