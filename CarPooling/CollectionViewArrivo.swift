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
    
    var arrivoLuoghi = ["Napoli", "Roma", "Bologna", "Milano","Torino","Firenze","Cosenza","Livorno","Bari","Genova","Trento"]
    var arrivoFoto = [#imageLiteral(resourceName: "Napoli2"),#imageLiteral(resourceName: "Roma2"),#imageLiteral(resourceName: "Bologna2"),#imageLiteral(resourceName: "Milano2"),#imageLiteral(resourceName: "Torino2"),#imageLiteral(resourceName: "Firenze2"),#imageLiteral(resourceName: "Cosenza2"),#imageLiteral(resourceName: "LIvorno2"),#imageLiteral(resourceName: "Bari2"),#imageLiteral(resourceName: "Genova2"),#imageLiteral(resourceName: "Trento2")]
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

