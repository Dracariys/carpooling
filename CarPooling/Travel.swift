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
    var startTime:
    var stopTime:
    var distance: Double?
    var travelTime:
    var chilometriRisparmiati: Double?
    var consumiRisparmiati: Double?
    var emissioniCO2Evitate: Double?
    var feedback: String?
    
    init(car: Car, startLocation: CLLocation, stopLocation: CLLocation, startTime: , stopTime: ){
        
        
        self.car = car
        self.startLocation = startLocation
        self.stopLocation = stopLocation
        self.startTime = startTime
        self.stopTime = stopTime
        
        
        
        
    }
    
    
    
    
    
    
    
    
}
