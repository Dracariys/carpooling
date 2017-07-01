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
//Master

var TRAVEL : [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 42.767863, longitude: 11.144630)
    ,CLLocationCoordinate2D(latitude: 43.786133, longitude: 11.225345)
    ] {
    didSet {
        
    }
}
let currentUser = USERS[Int(arc4random()) % USERS.count].name

var START : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:40.849191, longitude: 14.276788)
var DESTINATION : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 45.926094, longitude: 12.302646)
var DROPLOCATION : [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 43.786133, longitude: 11.225345)]

let messageService = MessageServiceManager(serviceName: "ShareSeat")
// up
class ViewController: UIViewController, MessageServiceManagerDelegate {
    fileprivate var POIS = [Place]()
    fileprivate let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    var veicles : [(Car,CarAnnotation)] = []

    @IBAction func showProfile(_ sender: Any) {
        
        performSegue(withIdentifier: "profileSegue", sender: nil)
        
    }
    
    func connectedDevicesChanged(manager: MessageServiceManager, connectedDevices: [String]) {
        
    }
    
    func messageReceived(manager: MessageServiceManager, message: String) {
        let alert = UIAlertController(title: "New passenger", message: "Vuoi accettare \(message). Il viaggio si allungherà di 30:00 minuti, ma acquisirai 10pt", preferredStyle: UIAlertControllerStyle.actionSheet)
        var rect = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(rect)
        let vista = (UIImageView(frame: CGRect(x: 10, y: 10, width: 50, height: 50)))
        vista.image = USERS.filter({$0.name == message}).first?.image
        alert.view.addSubview(vista)
        let action = UIAlertAction(title: "Si!", style: .default, handler: {_ in self.newPlace()})
        let action2 = UIAlertAction(title: "No!", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(action2)
        self.present(alert, animated: true)
    }
    
    func newPlace(){
        mapView.removeOverlays(mapView.overlays)
        let loc = CLLocationCoordinate2D(latitude: 44.786133, longitude: 11.225345)
        TRAVEL.append(loc)
        travelMaking {
        }
    }
    
    func travelMaking(handler: @escaping () -> Void){
        getCompletePath(START,DESTINATION,TRAVEL) { diction, error in
            if let dic = diction {
                let routes = dic.value(forKey: "routes") as! [NSDictionary]
                let geocoded_waypoints = dic.value(forKey: "geocoded_waypoints")
                if let r = routes.first {
                    let bounds = r.value(forKey: "bounds")
                    let summary = r.value(forKey: "summary")
                    let waypoint_order = r.value(forKey: "waypoint_order") as! [Int]
                    let legs = r.value(forKey: "legs") as! [NSDictionary]
                    let warnings = r.value(forKey: "warnings")
                    let overview_polyline = r.value(forKey: "overview_polyline")
                    TRAVEL = ordeBySecond(toOrder: TRAVEL, indexes: waypoint_order) as! [CLLocationCoordinate2D]
                    handler(self.findAndDraw())
                }
            }
        }
    }
    
    func findAndDraw(){
        if(TRAVEL.count < 1) {
            self.getDirections(start: START, arrival: DESTINATION)
            return
        }
        self.getDirections(start: START , arrival: TRAVEL[0])
        if TRAVEL.count > 1 {
            for k in 0..<TRAVEL.count-1 {
                self.getDirections(start: TRAVEL[k] , arrival: TRAVEL[k+1])
                let point = PlaceAnnotation(location: TRAVEL[k], title: "\(k)", subtitle: "paologay")
                if DROPLOCATION.contains(where: {$0 == TRAVEL[k]}) {
                    print("CONTAINS")
                    point.type = 1
                } else {point.type = -1}
                mapView.addAnnotation(point)
            }
        }
        self.getDirections(start: TRAVEL[TRAVEL.count-1] , arrival: DESTINATION)
        let point = PlaceAnnotation(location: TRAVEL[TRAVEL.count-1], title: "end", subtitle: "cftvgybh")
        if DROPLOCATION.contains(where: {$0 == TRAVEL[TRAVEL.count-1]}) {
            print("CONTAINS")
            point.type = 1
        } else {point.type = -1}
        mapView.addAnnotation(point)
    }
    
    override func viewDidLoad() {
        messageService.delegate=self
        super.viewDidLoad()
        print(self)
        mapView.delegate=self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: false)
        loadPoisAziendali()
        travelMaking {
        }
        generateVeicle(CARS.count)
        refreshCar()
        messageService.sendToAll(message: currentUser)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
         //   self.newPlace()
        }
    }
    
    
    
    @IBAction func viaggioDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "viaggioSegue", sender: nil)
        
    }
    
    
    @IBAction func passaggioDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "passaggioSegue", sender: nil)
        
    }
    
    
    func generateVeicle(_ n : Int){
        for car in CARS {
            let annotation = CarAnnotation(car)
            mapView.addAnnotation(annotation)
            veicles.append(car,annotation)
        }
    }
    
    func loadPoisAziendali(){
        for pois in POISAziendali {
            let point = PlaceAnnotation(location: pois.location, title: pois.locationName, subtitle: pois.address)
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
            messageService.sendToAll(message: currentUser)
            //newuser
            self.refreshCar()
        }
    }

    
    func getDirections(start : CLLocationCoordinate2D, arrival : CLLocationCoordinate2D) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: arrival))
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

func getCompletePath(_ departure : CLLocationCoordinate2D,_ arrival : CLLocationCoordinate2D ,_  waypoints : [CLLocationCoordinate2D], handler: @escaping (NSDictionary?, NSError?) -> Void){
    let url = routeUrlCreate(departure,arrival,waypoints)
    let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let dataTask = session.dataTask(with: URL(string:encoded!)!) { data, response, error in
        if let error = error {
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
        let colors = [UIColor.blue,UIColor.red,UIColor.brown]
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
            case 0: // Azienda
                img = #imageLiteral(resourceName: "Roma")
                rect = CGSize(width: 40, height: 40)
            case -1: // Dipendente
                let dipendente = place.image ?? #imageLiteral(resourceName: "paolo")
                img = dipendente
                rect = CGSize(width: 40, height: 40)
            case 1: // drop
                img = #imageLiteral(resourceName: "Page 1-1")
                rect = CGSize(width: 40, height: 40)
            default: // Posti disponibili
                print("NOT RECOGNIZED")
            }
        } else if let car = annotation as? CarAnnotation{
            if car.car.driver == nil {
                img = #imageLiteral(resourceName: "pinsuperfinale")
                rect = CGSize(width: 40, height: 40)
            }
            else if car.car.haPostiLiberi {
                img = #imageLiteral(resourceName: "pinVerde")
                rect = CGSize(width: 40, height: 40)
            }
            else {
                img = #imageLiteral(resourceName: "pinRosso")
                rect = CGSize(width: 40, height: 40)
            }
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
        c.append(toOrder[indexes[i]])
        
    }
    
    return c
}

func randomMove (_ pos : CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    let rnd = (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 100 ) - (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 100 )
    let rnd2 = (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 100 ) - (Double(arc4random()).truncatingRemainder(dividingBy: 10) / 100 )
    return CLLocationCoordinate2D(latitude: pos.latitude + rnd, longitude: pos.longitude + rnd2)
}






