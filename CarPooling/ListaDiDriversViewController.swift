//
//  ListaDiDriversViewController.swift
//  CarPooling
//
//  Created by Alessandro Luigi Marotta on 01/07/2017.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import UIKit
import MapKit

class ListaDiDriversViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "riepilogoSegue" {
            
            let destination = segue.destination as! RiepilogoViaggioViewController
            
            destination.seiPasseggero = true
            
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "riepilogoSegue", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return USERS.count
        
    }
    
    func distanceBetweenPoints(_ from: CLLocationCoordinate2D,_ to: CLLocationCoordinate2D) -> Int {
        let fromL = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toL = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return Int(toL.distance(from: fromL))
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var arrayOfCars = CARS.sorted { $0.efficiency > $1.efficiency }
        arrayOfCars = arrayOfCars.sorted(by: {distanceBetweenPoints($0.position,ROMA)/$0.efficiency/1000 < distanceBetweenPoints($1.position,ROMA)/$1.efficiency/1000})
        let cell = tableView.dequeueReusableCell(withIdentifier: "driverCell") as! DriverDetailsCell
        
        cell.driverName.text = "Autista: " + USERS[indexPath.row].name
        cell.carImage.layer.cornerRadius = cell.carImage.frame.size.width / 16
        cell.carImage.layer.masksToBounds = true
        cell.carImage.image = arrayOfCars[indexPath.row].image
        cell.carName.text = arrayOfCars[indexPath.row].name
        cell.idLabel.text = "ID: " + USERS[indexPath.row].id
        cell.distanceLabel.text = "Distanza: " + String(distanceBetweenPoints(arrayOfCars[indexPath.row].position,ROMA)/1000) + " km"
        cell.rankLabel.text = "Share Rank: " + String(USERS[indexPath.row].getAverageRanking())
        
        switch arrayOfCars[indexPath.row].efficiency {
        case 1:
            cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta1")
        case 2:
             cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta2")
        case 3:
             cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta3")
        case 4:
             cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta4")
        case 5:
             cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta5")
//        case 6:
//             cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta6")
//        case 7:
//             cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta7")
//        case 8:
//             cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta8")
//        case 9:
//             cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta9")
//        case 10:
//             cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta10")
        default:
             cell.livelloEcologico.image = UIImage()
        }
        
        return cell
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
