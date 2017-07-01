//
//  Extensions.swift
//  CarPooling
//
//  Created by Andrea Tofano on 30/06/17.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

extension Int {
    var f: Float { return Float(self) }
    var cgf: CGFloat { return CGFloat(self) }
    var d: Double { return Double(self) }
}

extension Double {
    var cgf: CGFloat { return CGFloat(self) }
    var i: Int { return Int(self) }
    var f: Float { return Float(self) }
}

extension CGFloat {
    var f: Float { return Float(self) }
    var i: Int { return Int(self) }
    var d: Double { return Double(self) }
}

extension Float {
    var d: Double { return Double(self) }
    var cgf: CGFloat { return CGFloat(self) }
    var i: Int { return Int(self) }
}

extension CLLocationDegrees
{
    func truncate(places : Int)-> CLLocationDegrees{
        return CLLocationDegrees(floor(pow(10.0, CLLocationDegrees(places)) * self)/pow(10.0, CLLocationDegrees(places)))
    }
}

func != (_ op1 : CLLocationCoordinate2D,_ op2 : CLLocationCoordinate2D) -> Bool {
    if (op1.latitude == op2.latitude && op1.longitude == op2.longitude){
        return false
    }
    return true
}
func == (_ op1 : CLLocationCoordinate2D,_ op2 : CLLocationCoordinate2D) -> Bool {
    if (op1.latitude == op2.latitude && op1.longitude == op2.longitude){
        return true
    }
    return false
}
