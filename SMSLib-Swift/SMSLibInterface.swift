//
//  SMSLibInterface.swift
//  Rezo Heatmap
//
//  Created by Jean-Romain on 25/01/2020.
//  Copyright © 2020 JustKodding. All rights reserved.
//

import Cocoa

/// Swift interface for the packaged SMSLib.
///
/// Recent laptops may be unsupported by the underlying SMSLib library.
/// Embedding this library in the app will also probably get it rejected from the AppStore.
/// Indeed, it relies on IOKit, which Apple bans for safety reasons.
class SMSLibInterface: NSObject {

    private(set) var isCalibrated = false
    private(set) var isReadable = false

    /// Enum used to identify a thrown error when interacting with the accelerometer.
    public enum KMotionError: Error {
        case notReady
        case calibrationFailed(underlyingError: SMSLibError)
        case readAccessRefused(underlyingError: SMSLibError)
        case readError(underlyingError: SMSLibError)
    }

    /// Swift enum representing the error codes passed by SMSLib
    public enum SMSLibError: Error {
        /// Alias to `SMS_SUCCESS` (error code 0)
        case success

        /// Alias to `SMS_FAIL_ACCESS` (error code -1)
        ///
        /// Failure if couldn't access connction using given function and size.
        /// This is where the process would probably fail with a change in Apple's API.
        /// Driver problems often also cause failures here.
        case failAccess

        /// Alias to `SMS_FAIL_CONNECTION` (error code -2)
        ///
        /// Failure if device opened, but didn't get a connection
        case failConnection

        /// Alias to `SMS_FAIL_OPENING` (error code -3)
        ///
        /// Failure if error opening device.
        /// The process generally fails here if entitlements don't allow `IOServiceOpen`.
        /// See https://stackoverflow.com/a/35138155.
        case failOpening

        /// Alias to `SMS_FAIL_NO_SERVICES` (error code -4)
        ///
        /// Failure if list of services is empty.
        /// The process generally fails here if run on a machine without a Sudden Motion Sensor.
        case failNoService

        /// Alias to `SMS_FAIL_LIST_SERVICES` (error code -5)
        ///
        /// Failure getting list of services.
        case failListServices

        /// Alias to `SMS_FAIL_DICTIONARY` (error code -6)
        ///
        /// Failure getting dictionary matching desired services.
        case failDictionary

        /// Alias to `SMS_FAIL_MODEL` (error code -7)
        ///
        /// Failure getting the device's model.
        case failModel

        /// Unknown error received from SMSLib.
        case unknown
    }

    deinit {
        smsShutdown()
    }

    /// Calibrate the motion sensor.
    /// - Throws:
    ///     - `KMotionError.calibrationFailed` if the calibration fails.
    ///     - `KMotionError.readAccessRefused` if the test reading after callibration fails.
    func callibrate() throws {
        let result = smsStartup(self, #selector(debugPrint(message:)))

        guard result == SMS_SUCCESS else {
            let error = smsError(from: result)
            throw KMotionError.calibrationFailed(underlyingError: error)
        }

        isCalibrated = true

        try testSensor()
    }

    /// Read values from the accelerometer.
    /// - Throws:
    ///     - `KMotionError.notReady` if `callibrate` was not called (or failed).
    ///     - `KMotionError.readError` if the reading fails.
    /// - Returns: A `SMSLibAcceleration` object.
    ///
    /// See section "Determining a PowerBook's Orientation" of http://osxbook.com/book/bonus/chapter10/sms/
    func read() throws -> SMSVector4 {
        guard isCalibrated, isReadable else {
            throw KMotionError.notReady
        }

        let accel = UnsafeMutablePointer<sms_acceleration>.allocate(capacity: 1)
        defer {
            accel.deallocate()
        }

        let result = smsGetData(accel)
        guard result == SMS_SUCCESS else {
            let error = smsError(from: result)
            throw KMotionError.readError(underlyingError: error)
        }

        let timestamp = NSDate.timeIntervalSinceReferenceDate
        return SMSVector4(accel: accel.pointee, t: timestamp)
    }

    private func testSensor() throws {
        do {
            // Try to read from the sensor once
            isReadable = true
            _ = try read()
        } catch KMotionError.readError(underlyingError: let error) {
            isReadable = false
            throw KMotionError.readAccessRefused(underlyingError: error)
        }
    }

    @objc private func debugPrint(message: String) {
        print("[SMSLib]", message)
    }

    private func smsError(from code: Int32) -> SMSLibError {
        switch code {
        case 0:
            return .success
        case -1:
            return .failAccess
        case -2:
            return .failConnection
        case -3:
            return .failOpening
        case -4:
            return .failNoService
        case -5:
            return .failListServices
        case -6:
            return .failDictionary
        case -7:
            return .failModel
        default:
            return .unknown
        }
    }

}
