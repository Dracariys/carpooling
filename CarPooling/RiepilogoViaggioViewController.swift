//
//  RiepilogoViaggioViewController.swift
//  CarPooling
//
//  Created by Paolo Patrizio on 01/07/17.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import UIKit

class RiepilogoViaggioViewController: UIViewController, MessageServiceManagerDelegate {

    
    var seiPasseggero: Bool?
    
    @IBOutlet weak var askPasseggero: UIButton!
    @IBOutlet weak var confermaButton: UIButton!
   
    func connectedDevicesChanged(manager: MessageServiceManager, connectedDevices: [String]) {
        
    }
    
    func messageReceived(manager: MessageServiceManager, message: String) {
        
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
