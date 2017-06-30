//
//  Driver.swift
//  CarPooling
//
//  Created by Alessandro Luigi Marotta on 30/06/2017.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import Foundation
import UIKit

class Driver {
    
    
    var name: String
    var id: String
    var phone: String?
    var image: UIImage?
    var rankings: [Double]
    var age: Int?
    var role: String?
    var yearsOfExperience: Int?
    
    
    init(id: String){
        
        self.id = id
        name = ""
        phone = ""
        image = #imageLiteral(resourceName: "omino")
        rankings = []
        age = 0
        role = ""
        yearsOfExperience = 0
        
        
    }
    
    init(id: String, name: String) {
        
        self.name = name
        self.id = id
        phone = ""
        image = #imageLiteral(resourceName: "omino")
        rankings = []
        age = 0
        role = ""
        yearsOfExperience = 0
        
        
        
    }
    
    func getAverageRanking()->Double{
        
        var sum = 0.0
        
        for num in rankings {
            
            sum += num
            
        }
        
        return sum / Double(rankings.count)
        
        
    }
    
   

    
    
}
