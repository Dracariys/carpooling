//
//  ViewController.swift
//  CarPooling
//
//  Created by Andrea Tofano on 30/06/17.
//  Copyright © 2017 Andrea Tofano. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
// update
class ViewController: UIViewController {
    fileprivate var POIS = [Place]()
    fileprivate let locationManager = CLLocationManager()
    let start = CLLocationCoordinate2D(latitude: 40.836087, longitude: 14.305694)
    let arrival = CLLocationCoordinate2D(latitude: 40.847360, longitude: 14.281893)
    let wp = CLLocationCoordinate2D(latitude: 40.837102 , longitude: 14.301563)
    let wp2 = CLLocationCoordinate2D(latitude: 40.837102 , longitude: 14.331563)
    @IBOutlet weak var mapView: MKMapView!
    var veicles : [(Car,CarAnnotation)] = []

    @IBAction func showProfile(_ sender: Any) {
        
        performSegue(withIdentifier: "profileSegue", sender: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self)
        mapView.delegate=self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: false)
        loadPoisAziendali()
        //makeTravel()
        generateVeicle(10)
        refreshCar()
    }
    
    
    
    @IBAction func viaggioDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "viaggioSegue", sender: nil)
        
    }
    
    
    @IBAction func passaggioDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "passaggioSegue", sender: nil)
        
    }
    
    
    func generateVeicle(_ n : Int){
        for _ in 0...n {
            let veicle = Car(name: "prova")
            veicle.position = CLLocationCoordinate2D(latitude: 40 + (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 100 ), longitude: 14 + (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 100 ))
            let annotation = CarAnnotation(veicle)
            mapView.addAnnotation(annotation)
            veicles.append(veicle,annotation)
            
        }
    }
    
    func loadPoisAziendali(){
        for pois in POISAziendali {
            let point = PlaceAnnotation(location: pois.location, title: pois.locationName, type: pois.address)
            mapView.addAnnotation(point)
        }
    }
    
    func refreshCar(){
        for k in 0..<veicles.count {
            veicles[k].0.position = randomMove(veicles[k].0.position)
            if(veicles[k].0.position != veicles[k].1.coordinate){
                mapView.removeAnnotation(veicles[k].1)
                veicles[k].1 = CarAnnotation(veicles[k].0)
                mapView.addAnnotation(veicles[k].1)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            self.refreshCar()
        }
    }
    
    func randomMove (_ pos : CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let rnd = (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 100 ) - (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 100 )
        let rnd2 = (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 100 ) - (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 100 )
        return CLLocationCoordinate2D(latitude: pos.latitude + rnd, longitude: pos.longitude + rnd2)
    }
    
    func makeTravel(){
        let travel = [start]
        for k in 0..<travel.count-1 {
            self.getDirections(start: travel[k], arrival: travel[k+1])
            let point = PlaceAnnotation(location: travel[k], title: "\(k)", type: "paologay")
            mapView.addAnnotation(point)
        }
        let point = PlaceAnnotation(location: travel.last!, title: "end", type: "cftvgybh")
        mapView.addAnnotation(point)
    }
    
    func getDirections(start : CLLocationCoordinate2D, arrival : CLLocationCoordinate2D) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: wp))
        request.requestsAlternateRoutes = false
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: {(response, error) in
            
            if error != nil {
                print("Error getting directions")
            } else {
                self.showRoute(response!)
            }
        })
    }
    
    func showRoute(_ response: MKDirectionsResponse) {
        
        for route in response.routes {
            
            mapView.add(route.polyline,
                        level: MKOverlayLevel.aboveRoads)
            
            for step in route.steps {
            }
        }
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

func routeUrlCreate(_ departure : CLLocationCoordinate2D,_ arrival : CLLocationCoordinate2D , _ waypoints : [CLLocationCoordinate2D]) -> String{
    var basicUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=\(departure.latitude),\(departure.longitude)&destination=\(arrival.latitude),\(arrival.longitude)&key=AIzaSyAGjTDcNLXG5OVuluxG3MvSNiMbDJMUlns"
    if waypoints.count != 0 {
        basicUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=\(departure.latitude),\(departure.longitude)&destination=\(arrival.latitude),\(arrival.longitude)&waypoints=optimize:true"
        for wp in waypoints {
            basicUrl.append("|\(wp.latitude),\(wp.longitude)")
        }
        basicUrl.append("&key=AIzaSyAGjTDcNLXG5OVuluxG3MvSNiMbDJMUlns")
    }
    return basicUrl
}

func load(departure : CLLocationCoordinate2D, arrival : CLLocationCoordinate2D , waypoints : [CLLocationCoordinate2D], handler: @escaping (NSDictionary?, NSError?) -> Void){
    let url = routeUrlCreate(departure,arrival,waypoints)
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let dataTask = session.dataTask(with: URL(string: url)!) { data, response, error in
        if let error = error {
            print(error)
        } else if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                
                do {
                    let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    guard let responseDict = responseObject as? NSDictionary else {
                        return
                    }
                    
                    handler(responseDict, nil)
                    
                } catch let error as NSError {
                    handler(nil, error)
                }
            }
        }
    }
    
    dataTask.resume()

}



extension ViewController: CLLocationManagerDelegate {
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0 {
            let location = locations.last!
            if location.horizontalAccuracy < 100 {
                manager.stopUpdatingLocation()
            }
        }
    }
}




extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        let colors = [UIColor.blue,UIColor.red,UIColor.cyan,UIColor.brown]
        renderer.strokeColor = colors[Int(arc4random()) % colors.count]
        renderer.lineWidth = 2.0
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.canShowCallout=true
        var rect = CGSize(width: 40, height: 40)
        var img = #imageLiteral(resourceName: "pinfinalebianco")
        if let place = annotation as? PlaceAnnotation {
            switch place.type {
            case -3: // Macchina libera 
                img = #imageLiteral(resourceName: "pinBianco")
                rect = CGSize(width: 40, height: 40)
            case -2: // Azienda
                img = #imageLiteral(resourceName: "PinRifornimento")
                rect = CGSize(width: 40, height: 40)
            case -1: // Dipendente
                img = #imageLiteral(resourceName: "paolo")
                rect = CGSize(width: 40, height: 40)
            case 0: // Macchina piena
                img = #imageLiteral(resourceName: "pinfinalebianco")
                rect = CGSize(width: 40, height: 40)
            default: // Posti disponibili
                img = #imageLiteral(resourceName: "pinVerde")
                rect = CGSize(width: 40, height: 40)
            }
        } else if let car = annotation as? CarAnnotation{
            
        } else {print("NOT RECOGNIZED")}
        UIGraphicsBeginImageContext(rect)
        img.draw(in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        pin.image = UIGraphicsGetImageFromCurrentImageContext()
        return pin
    }
}

func ordeBySecond(toOrder: [Any], indexes: [Int])->[Any]{
    
    var c: [Any] = []
    
    for i in 0..<indexes.count{
        
        c[i] = toOrder[indexes[i]]
        
    }
    
    return c
}







