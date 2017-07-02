//
//  Driver.swift
//  CarPooling
//
//  Created by Alessandro Luigi Marotta on 30/06/2017.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import Foundation
import UIKit



class User {
    
    
    var name: String
    var id: String
    var phone: String?
    var image: UIImage?
    var rankings: [Double] = []
    var age: Int?
    var role: String?
    var yearsOfExperience: Int?
    var azienda: String
    
    
    
    func fillRankings(){
        
        
        for _ in 0...arc4random_uniform(10){
            
            var rank: Int = 0
            
            while (rank == 0){
                
                rank = Int(UInt32(arc4random_uniform(10)))
                
            }
            
            rankings.append(Double(rank))
            
        }
        
    }
        
        
        
    
    
    
    init(id: String){
        
        
        
        self.id = id
        name = ""
        phone = ""
        image = #imageLiteral(resourceName: "omino")
        age = 0
        role = ""
        yearsOfExperience = 0
        azienda = ""
     
        fillRankings()
        
        
    }
    
    
    init(id: String, name: String) {
        
        self.name = name
        self.id = id
        phone = ""
        image = #imageLiteral(resourceName: "omino")
        age = 0
        role = ""
        yearsOfExperience = 0
        azienda = ""
        
        fillRankings()
        
        
    }
    
    init(id: String, name: String, image: UIImage) {
        
        self.name = name
        self.id = id
        phone = ""
        self.image = image
        age = 0
        role = ""
        yearsOfExperience = 0
        azienda = ""
        
        fillRankings()
        
    }
    
    func getAverageRanking()->Int{
        
        var sum = 0.0
        
        for num in rankings {
            
            sum += num
            
        }
        
        return Int(sum) / rankings.count
        
        
    }
    
   

    
    
}
