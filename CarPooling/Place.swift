//
//  ClassPlaces.swift
//  CarPooling
//
//  Created by Andrea Tofano on 30/06/17.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


class Place {
    
    
    var address: String
    var location: CLLocation
    var locationName: String
    var image: UIImage?
    var phone: String?
    
    
    
    init(address: String, location: CLLocation, locationName: String){
        
        
        self.address = address
        self.location = location
        self.locationName = locationName
        image = #imageLiteral(resourceName: "defaultLocation")
        phone = ""
        
        
        
    }
    
    
    
}
