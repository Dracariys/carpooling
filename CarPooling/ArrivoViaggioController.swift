//
//  ArrivoViaggioController.swift
//  CarPooling
//
//  Created by Alessandro Luigi Marotta on 01/07/2017.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import UIKit

class ArrivoViaggioController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var arrivoLuoghi = ["Napoli", "Roma", "Bologna", "Milano"]
    var arrivoFoto = [UIImage(named: "Napoli"), UIImage(named: "Roma"), UIImage(named: "Bologna"), UIImage(named: "Milano")]
    
    var indicePartenza: Int = 0
    
    
    
    override func viewDidLoad() {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrivoLuoghi.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellaArrivo", for: indexPath as IndexPath) as! ArrivoCell
        
        //impostiamo l'immagine e il testo della label con quelli precedentemente dichiarati nelle due variabili
        cell.arrivoImage?.image = self.arrivoFoto[indexPath.row]
        cell.arrivoLabel?.text = self.arrivoLuoghi[indexPath.row]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "carsAvailableListSegue", sender: nil)
        
        
    }
}
