//
//  Travel.swift
//  CarPooling
//
//  Created by Andrea Tofano on 30/06/17.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


class Travel{
    
    
    
    var car: Car
    var startLocation: CLLocation
    var stopLocation: CLLocation
    var startTime:  String
    var stopTime:   String
    var distance: Double = 0
    var travelTime: String = ""
    var chilometriRisparmiati: Double = 0
    var consumiRisparmiati: Double = 0
    var emissioniCO2Evitate: Double = 0
    var feedback: String = ""
    
    init(car: Car, startLocation: CLLocation, stopLocation: CLLocation, startTime: String , stopTime: String ){
        
        
        self.car = car
        self.startLocation = startLocation
        self.stopLocation = stopLocation
        self.startTime = startTime
        self.stopTime = stopTime
        
        
        
        
    }
    
    
    
    
    
}
