//
//  PoisAziende.swift
//  CarPooling
//
//  Created by Andrea Tofano on 01/07/17.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import Foundation
import MapKit

let POISAziendali : [Place] = [
    Place(address: "Via Marcora 52", location: MILANO, locationName: "Sede Milano"),
    Place(address: "Trav. Strettola S.Anna alle Paludi 11", location: NAPOLI, locationName: "Sede Napoli"),
    Place(address: "Piazza Garibaldi  14", location: CLLocationCoordinate2D(latitude:40.838443, longitude:8.402086), locationName: "Sede Sassari")
]

let USERS : [User] = [
    User(id: "0123456", name: "Gino D'Acampo", image: #imageLiteral(resourceName: "driver2")),
    User(id: "0123477", name: "Richard Ayoade", image: #imageLiteral(resourceName: "driver3")),
    User(id: "0123428", name: "Paul Patrick", image: #imageLiteral(resourceName: "driver")),
    User(id: "0123439", name: "Alex M. Routa", image: #imageLiteral(resourceName: "driver4")),
    User(id: "0123490", name: "Dave S. Avel", image: #imageLiteral(resourceName: "driver5"))
]

let CARS : [Car] = [
    Car(name: "Alfa Romeo Giulietta", image: #imageLiteral(resourceName: "car1"),randomMove(POISAziendali[0].location)),
    Car(name: "Ford Foucs", image: #imageLiteral(resourceName: "car2"),randomMove(POISAziendali[0].location)),
    Car(name: "Fiat Punto", image: #imageLiteral(resourceName: "car3"),randomMove(POISAziendali[0].location)),
    Car(name: "Subaru Baracca", image: #imageLiteral(resourceName: "car4"),randomMove(POISAziendali[1].location)),
    Car(name: "Panzer", image: #imageLiteral(resourceName: "car5"),randomMove(POISAziendali[1].location)),
    Car(name: "Toyota Corolla", image: #imageLiteral(resourceName: "car6"),randomMove(POISAziendali[1].location)),
    Car(name: "Citroen Picasso", image: #imageLiteral(resourceName: "car7"),randomMove(POISAziendali[0].location)),
    Car(name: "Volkswagen Golf", image: #imageLiteral(resourceName: "car8"),randomMove(POISAziendali[2].location)),
    Car(name: "Lotus Elise", image: #imageLiteral(resourceName: "car9"),randomMove(POISAziendali[2].location)),
    Car(name: "Jeep Wrangler", image: #imageLiteral(resourceName: "car10"),randomMove(POISAziendali[2].location))
]

// roba
