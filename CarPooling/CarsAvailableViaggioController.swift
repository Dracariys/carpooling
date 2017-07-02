//
//  CarsAvailableViaggioController.swift
//  CarPooling
//
//  Created by Alessandro Luigi Marotta on 01/07/2017.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import UIKit

class CarsAvailableViaggioController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return CARS.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let arrayOfCars = CARS.sorted { $0.efficiency > $1.efficiency }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "carCell") as! CarsAvailableCell
        
        cell.autoName.text = arrayOfCars[indexPath.row].name
        cell.carImage.image = arrayOfCars[indexPath.row].image
        cell.consumi.text = "Risparmio evargetico: " + String(arc4random_uniform(UInt32(150))) + "%"
        
        
        
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
//            cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta6")
//        case 7:
//            cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta7")
//        case 8:
//            cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta8")
//        case 9:
//            cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta9")
//        case 10:
//            cell.livelloEcologico.image = #imageLiteral(resourceName: "pianta10")
        default:
            cell.livelloEcologico.image = UIImage()
        }
        
        
        
        
        return cell
        
    }
    
    
 
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "riepilogoSegue", sender: nil)
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
