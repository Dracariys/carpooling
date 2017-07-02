//
//  FeedbackViewController.swift
//  CarPooling
//
//  Created by Alessandro Luigi Marotta on 02/07/2017.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    
  
    @IBAction func fineDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "backHome", sender: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func star1Touch(_ sender: Any) {
        
        if star1.imageView?.image == #imageLiteral(resourceName: "stellagrigia"){
            star1.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
        } else {
            star1.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
        }
    }
    
    @IBAction func star2Touch(_ sender: Any) {
        
        if star2.imageView?.image == #imageLiteral(resourceName: "stellagrigia"){
            star2.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
            star1.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
        } else {
            star2.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
            star1.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
        }
        
    }
    
    @IBAction func star3Touch(_ sender: Any) {
        
        if star3.imageView?.image == #imageLiteral(resourceName: "stellagrigia"){
            star3.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
            star2.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
            star1.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
        } else {
            star3.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
            star2.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
            star1.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)        }
        
    }
    
    @IBAction func star4Touch(_ sender: Any) {
        
        if star4.imageView?.image == #imageLiteral(resourceName: "stellagrigia"){
            star4.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
            star3.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
            star2.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
            star1.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
        } else {
            star4.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
            star3.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
            star2.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
            star1.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
        }
        
    }
    
    @IBAction func star5Touch(_ sender: Any) {
        
        if star5.imageView?.image == #imageLiteral(resourceName: "stellagrigia"){
            star5.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
            star4.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
            star3.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
            star2.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)
            star1.setImage(#imageLiteral(resourceName: "stellarancione"), for: .normal)

        } else {
            star5.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
            star4.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
            star3.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
            star2.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
            star1.setImage(#imageLiteral(resourceName: "stellagrigia"), for: .normal)
        }
        
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
