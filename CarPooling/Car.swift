//
//  ClassAuto.swift
//  CarPooling
//
//  Created by Andrea Tofano on 30/06/17.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


class Car {
    
    
    var driver: Driver
    var name: String
    var position: CLLocation
    var age: Int?
    var mileage: Double? //chilometri percorsi
    var services: [String]? //aria condizionata ecc.
    var todayMileage: Double? //chilometri percorsi oggi. NOTA: comm cazz s calcola?
    var risparmioPerChilometro: Double?
    var risparmioGiornaliero: Double?
    
    
    init(name: String, driver: Driver){
        
        self.name = name
        self.driver = driver
        position = CLLocation(latitude: 0, longitude: 0)
        age = 0
        mileage = 0
        services = []
        todayMileage = 0
        risparmioPerChilometro = 0
        risparmioGiornaliero = 0
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
