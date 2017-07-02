//
//  CollectionViewArrivo.swift
//  CarPooling
//
//  Created by Paolo Patrizio on 01/07/17.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import Foundation
import UIKit
//3
//collection View per la selezione per l'arriv


class CollectionViewArrivo: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var arrivoLuoghi = ["Napoli", "Roma", "Bologna", "Milano"]
    var arrivoFoto = [UIImage(named: "Napoli"), UIImage(named: "Roma"), UIImage(named: "Bologna"), UIImage(named: "Milano")]
    
    var indicePartenza: Int = 0
    var nomeDaPassare: String!

    
    
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
        nomeDaPassare = cell.arrivoLabel.text
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "driversListSegue", sender: nil)

        arrivo = nomeDaPassare

        arrivo = self.arrivoLuoghi[indexPath.row]
        
        print(arrivo)
        print(arrivo)
    }
    
    
    
    
    
}

