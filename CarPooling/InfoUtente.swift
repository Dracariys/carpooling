//
//  InfoUtente.swift
//  CarPooling
//
//  Created by Paolo Patrizio on 01/07/17.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import Foundation
import UIKit
//8
//Informazioni utente (possiamo usare un semplice bottone)

class InfoUtente: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var profileImage: UIImageView!
    
//    @IBOutlet weak var nameLabel: UILabel!
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
        // return array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rickCell", for: indexPath) as! RickDirectorCell
            
            cell.rickNameLabel.text = "Rick D. Rector"
            cell.aziendaLabel.text = "Tecno Srl"
            cell.phoneLabel.text = "333 42 35 678"
            
            return cell
        case 1:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rickCell2", for: indexPath) as! RickDirectoCell2
            
//            cell.barraProgresso.image = #imageLiteral(resourceName: "barraProgresso")
//            cell.livelloLabel.text = "Livello 3"
//            cell.punteggioLabel.text = "55 / 100"
//            cell.prossimoPremioLabel.text = "Prossimo premio: 12 buoni pasto"
//            cell.Rectangle4.image = 
            
            return cell
            
            
        default:
            return UICollectionViewCell()
        }
        
    }
    
    override func viewDidLoad() {
        
    }
    
    
    
    
    
    
}
