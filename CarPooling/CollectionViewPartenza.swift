//
//  CollectionViewPartenza.swift
//  CarPooling
//
//  Created by Paolo Patrizio on 01/07/17.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import Foundation
import UIKit
//2
///Collection view con selezione per la partenza


class CollectionViewPartenza : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet weak var collectionView: UICollectionView!
    
    var partenzaLuoghi = ["Napoli", "Roma", "Bologna", "Milano","Torino","Firenze","Cosenza","Livorno","Bari","Genova","Trento"]
    var partenzaFoto = [#imageLiteral(resourceName: "Napoli2"),#imageLiteral(resourceName: "Roma2"),#imageLiteral(resourceName: "Bologna2"),#imageLiteral(resourceName: "Milano2"),#imageLiteral(resourceName: "Torino2"),#imageLiteral(resourceName: "Firenze2"),#imageLiteral(resourceName: "Cosenza2"),#imageLiteral(resourceName: "LIvorno2"),#imageLiteral(resourceName: "Bari2"),#imageLiteral(resourceName: "Genova2"),#imageLiteral(resourceName: "Trento2")]
    var indicePartenza: Int = 0
    var nomeDaPassare: String!

    
    override func viewDidLoad() {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //questo valore serve per far capire alla Collection View quante celle devono essere visualizzate
        return POISAziendali.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cella", for: indexPath as IndexPath) as! PartenzaCell
        
        //impostiamo l'immagine e il testo della label con quelli precedentemente dichiarati nelle due variabili
        cell.partenzaImage?.image = partenzaFoto[indexPath.row]
        cell.partenzaLabel?.text = partenzaLuoghi[indexPath.row]
        nomeDaPassare = cell.partenzaLabel.text

        return cell
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "partenzaToArrivoSegue" {
            
        
            let destination = segue.destination as! CollectionViewArrivo
            
            destination.indicePartenza = indicePartenza
            

            
            
            }
        }
        
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        partenza = nomeDaPassare

        indicePartenza = indexPath.row
        performSegue(withIdentifier: "partenzaToArrivoSegue", sender: nil)
        partenza = self.partenzaLuoghi[indexPath.row]
        print(partenza)

        
    }
    
    


}
