//
//  SMSVector4.swift
//  Rezo Heatmap
//
//  Created by Jean-Romain on 25/01/2020.
//  Copyright © 2020 JustKodding. All rights reserved.
//

import Cocoa

// swiftlint:disable identifier_name

class SMSVector4: NSObject {

    let x: Double
    let y: Double
    let z: Double
    let t: TimeInterval

    static var zero: SMSVector4 {
        return SMSVector4(x: 0, y: 0, z: 0, t: 0)
    }

    convenience init(accel: sms_acceleration, t: TimeInterval) {
        // Convert the values to m.s-1
        self.init(x: Double(10 * accel.x),
                  y: Double(10 * accel.y),
                  z: Double(10 * accel.z),
                  t: t)
    }

    init(x: Double, y: Double, z: Double, t: TimeInterval) {
        self.x = x
        self.y = y
        self.z = z
        self.t = t
        super.init()
    }

    override var description: String {
        return "(x: \(x), y: \(y), z: \(z), t: \(t))"
    }
}

extension SMSVector4 {

    static prefix func - (vector: SMSVector4) -> SMSVector4 {
        return SMSVector4(x: -vector.x,
                        y: -vector.y,
                        z: -vector.z,
                        t: -vector.t)
    }

    static func + (lhs: SMSVector4, rhs: SMSVector4) -> SMSVector4 {
        let newX = lhs.x + rhs.x
        let newY = lhs.y + rhs.y
        let newZ = lhs.z + rhs.z
        let newT = lhs.t + rhs.t

        return SMSVector4(x: newX, y: newY, z: newZ, t: newT)
    }

    static func - (lhs: SMSVector4, rhs: SMSVector4) -> SMSVector4 {
        return lhs + (-rhs)
    }

    static func * (lhs: SMSVector4, rhs: Double) -> SMSVector4 {
        let newX = lhs.x * rhs
        let newY = lhs.y * rhs
        let newZ = lhs.z * rhs
        let newT = lhs.t * rhs

        return SMSVector4(x: newX, y: newY, z: newZ, t: newT)
    }

    static func / (lhs: SMSVector4, rhs: Double) -> SMSVector4 {
        return lhs * (1 / rhs)
    }

    // swiftlint:disable shorthand_operator
    static func += (lhs: inout SMSVector4, rhs: SMSVector4) {
        lhs = lhs + rhs
    }

    static func *= (lhs: inout SMSVector4, rhs: Double) {
        lhs = lhs * rhs
    }

    static func /= (lhs: inout SMSVector4, rhs: Double) {
        lhs = lhs / rhs
    }
    // swiftlint:enable shorthand_operator

    static func == (lhs: SMSVector4, rhs: SMSVector4) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.t == rhs.t
    }

}

// swiftlint:enable identifier_name
