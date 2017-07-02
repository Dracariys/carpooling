//
//  PartenzaViaggioController.swift
//  CarPooling
//
//  Created by Alessandro Luigi Marotta on 01/07/2017.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

var partenza = ""
var arrivo = ""

import UIKit

class PartenzaViaggioController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var partenzaLuoghi = ["Napoli", "Roma", "Bologna", "Milano","Torino","Firenze","Cosenza","Livorno","Bari","Genova","Trento"]
    var partenzaFoto = [#imageLiteral(resourceName: "Napoli2"),#imageLiteral(resourceName: "Roma2"),#imageLiteral(resourceName: "Bologna2"),#imageLiteral(resourceName: "Milano2")]
    var indicePartenza: Int = 0
    var nomeDaPassare: String!
    
    
    override func viewDidLoad() {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //questo valore serve per far capire alla Collection View quante celle devono essere visualizzate
        return partenzaLuoghi.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cella", for: indexPath as IndexPath) as! PartenzaCell
        
        //impostiamo l'immagine e il testo della label con quelli precedentemente dichiarati nelle due variabili
        cell.partenzaImage?.image = self.partenzaFoto[indexPath.row]
        cell.partenzaLabel?.text = partenzaLuoghi[indexPath.row]
        nomeDaPassare = cell.partenzaLabel.text
        return cell
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "partenzaToArrivoSegue2" {
            
            
            let destination = segue.destination as! ArrivoViaggioController
            
            destination.indicePartenza = indicePartenza
            
            
        partenza = nomeDaPassare
            
            
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        indicePartenza = indexPath.row
        performSegue(withIdentifier: "partenzaToArrivoSegue2", sender: nil)
        partenza = self.partenzaLuoghi[indexPath.row]
        print(partenza)

    }


}
