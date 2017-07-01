//
//  CarsAvailableViaggioController.swift
//  CarPooling
//
//  Created by Alessandro Luigi Marotta on 01/07/2017.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import UIKit

class CarsAvailableViaggioController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cars = [
        Car(name: "Toyota Corolla", image: #imageLiteral(resourceName: "car6")),
        Car(name: "Citroen Picasso", image: #imageLiteral(resourceName: "car7") ),
        Car(name: "Volkswagen Golf", image: #imageLiteral(resourceName: "car8") ),
        Car(name: "Lotus Elise", image: #imageLiteral(resourceName: "car9")),
        Car(name: "Jeep Wrangler", image: #imageLiteral(resourceName: "car10"))
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return cars.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "carCell") as! CarsAvailableCell
        
        cell.autoName.text = cars[indexPath.row].name
        cell.carImage.image = cars[indexPath.row].image
        cell.consumi.text = "Risparmio energetico: " + String(arc4random_uniform(UInt32(150))) + "%"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
