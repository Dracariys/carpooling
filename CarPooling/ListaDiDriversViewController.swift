//
//  ListaDiDriversViewController.swift
//  CarPooling
//
//  Created by Alessandro Luigi Marotta on 01/07/2017.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import UIKit

class ListaDiDriversViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var drivers: [User]?
    var cars: [Car]?
    
    
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        drivers = [
            User(id: "0123456", name: "Gino D'Acampo", image: #imageLiteral(resourceName: "driver2")),
            User(id: "0123477", name: "Richard Ayoade", image: #imageLiteral(resourceName: "driver3")),
            User(id: "0123428", name: "Paul Patrick", image: #imageLiteral(resourceName: "paolo")),
            User(id: "0123439", name: "Alex M. Routa", image: #imageLiteral(resourceName: "driver4")),
            User(id: "0123490", name: "Dave S. Avel", image: #imageLiteral(resourceName: "driver5"))
        ]
        
        cars = [
            Car(name: "Alfa Romeo Giulietta", image: #imageLiteral(resourceName: "car1")),
            Car(name: "Ford Foucs", image: #imageLiteral(resourceName: "car2") ),
            Car(name: "Fiat Punto", image: #imageLiteral(resourceName: "car3") ),
            Car(name: "Subaru Baracca", image: #imageLiteral(resourceName: "car4")),
            Car(name: "Panzer", image: #imageLiteral(resourceName: "car5"))
        ]
        
        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "riepilogoSegue", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (drivers?.count)!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "driverCell") as! DriverDetailsCell
        
        cell.driverName.text = drivers![indexPath.row].name
        cell.carImage.image = cars![indexPath.row].image
        cell.carName.text = cars![indexPath.row].name
        cell.idLabel.text = "ID: " + drivers![indexPath.row].id
        cell.distanceLabel.text = String(arc4random_uniform(UInt32(1000.d))) + " km"
        
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
