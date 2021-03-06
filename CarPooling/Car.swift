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
    
    
    var driver: User?
    var name: String
    var image: UIImage?
    var position: CLLocationCoordinate2D
    var age: Int?
    var mileage: Double? //chilometri percorsi
    var services: [String]? //aria condizionata ecc.
    var todayMileage: Double? //chilometri percorsi oggi. NOTA: comm cazz s calcola?
    var risparmioPerChilometro: Double?
    var risparmioGiornaliero: Double?
    var destinazione : (String,CLLocationCoordinate2D)?
    var max_posti: Int
    var passeggeri: [User] = []
    var haPostiLiberi : Bool {
        if (passeggeri.count < max_posti) {
            return true
        }
        return false
    }
    var route : [CLLocationCoordinate2D] = []
    var routePlace : Int = 2
    var efficiency = 0
    
    
    func setEfficiency(){
        
        
        while (efficiency == 0) {
            
            efficiency = Int(arc4random_uniform(UInt32(5)))
            
        }
        
        if name == "Panzer" || name == "Subaru Baracca" {
            
            efficiency = 1
            
        }
        
        
        
    }
    
    init(name: String){
        
        self.name = name
        position = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        age = 0
        mileage = 0
        services = []
        todayMileage = 0
        risparmioPerChilometro = Double(arc4random_uniform(UInt32(1000)))
        risparmioGiornaliero = 0
        max_posti = 4
        setEfficiency()
    }
    
    
    init(name: String, image: UIImage){
        
        self.name = name
        self.image = image
        position = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        age = 0
        mileage = 0
        services = []
        todayMileage = 0
        risparmioPerChilometro = 0
        risparmioGiornaliero = 0
        max_posti = 4
        setEfficiency()
    }
    
    init(name: String, image: UIImage, _ loc : CLLocationCoordinate2D){
        
        self.name = name
        self.image = image
        position = loc
        age = 0
        mileage = 0
        services = []
        todayMileage = 0
        risparmioPerChilometro = 0
        risparmioGiornaliero = 0
        max_posti = 4
        setEfficiency()
    }
    
    
    
    
    

        
    
    
    
    
}
