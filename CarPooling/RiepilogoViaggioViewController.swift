//
//  RiepilogoViaggioViewController.swift
//  CarPooling
//
//  Created by Paolo Patrizio on 01/07/17.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import UIKit
import MapKit

class RiepilogoViaggioViewController: UIViewController, MessageServiceManagerDelegate {

    
    var seiPasseggero: Bool?
    
    @IBOutlet weak var askPasseggero: UIButton!
    @IBOutlet weak var confermaButton: UIButton!
   
    func connectedDevicesChanged(manager: MessageServiceManager, connectedDevices: [String]) {
        
    }
    
    func messageReceived(manager: MessageServiceManager, message: String) {
        let opCodes = message.components(separatedBy: "_")
        print(opCodes)
        let part = CLLocationCoordinate2D(latitude: Double(opCodes[1])!, longitude: Double(opCodes[2])!)
        let arr = CLLocationCoordinate2D(latitude: Double(opCodes[3])!, longitude: Double(opCodes[4])!)
        if(opCodes[0] == "MAP"){
            if(opCodes.count>4){
                START=part
                DESTINATION=arr
                for k in 5..<opCodes.count{
                    if(k%2==1){
                        TRAVEL.append((CLLocationCoordinate2D(latitude: Double(opCodes[k])!, longitude: Double(opCodes[k+1])!),"Waypoint"))
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageService.delegate=self
        askRide(partenza, arrivo)
        print(partenza,arrivo)
        if seiPasseggero == true {
            
            askPasseggero.isEnabled = false
            askPasseggero.isHidden = true
            
            confermaButton.layer.position.y = 577
            
        }else{
            
            askPasseggero.isEnabled = true
            askPasseggero.isHidden = false
            
            confermaButton.layer.position.y = 632
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
