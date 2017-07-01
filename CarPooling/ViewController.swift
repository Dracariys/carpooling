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

class ViewController: UIViewController {
    fileprivate var POIS = [Place]()
    fileprivate let locationManager = CLLocationManager()
    let start = CLLocationCoordinate2D(latitude: 40.836087, longitude: 14.305694)
    let arrival = CLLocationCoordinate2D(latitude: 40.847360, longitude: 14.281893)
    let wp = CLLocationCoordinate2D(latitude: 40.837102 , longitude: 14.301563)
    let wp2 = CLLocationCoordinate2D(latitude: 40.837102 , longitude: 14.331563)
    @IBOutlet weak var mapView: MKMapView!

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
        makeTravel()
    }
    
    func makeTravel(){
        let travel = [start,wp,wp2,arrival,arrival]
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
        // Dispose of any resources that can be recreated.
    }
    /*
    func showInfoView(forPlace place: Place) {
        let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 50, width: 50, height: 50))
        imageView.image = getImageForType(place.type)
        alert.view.addSubview(imageView)
        arViewController.present(alert, animated: true, completion: nil)
    }
 */
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
                //drawPointsOfInterest(location: location)
            }
        }
    }
    //bun
    /*
    func drawPointsOfInterest(location: CLLocation) {
        /* let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
         let region = MKCoordinateRegion(center: location.coordinate, span: span)
         mapView.region = region */
        let loader = PlacesLoader()
        loader.loadPOIS(location: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), radius: RANGE) {
            placesDict, error in
            if let dict = placesDict {
                guard let placesArray = dict.object(forKey: "results") as? [NSDictionary]  else { return }
                
                for placeDict in placesArray {
                    let latitude = placeDict.value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
                    let longitude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
                    let reference = placeDict.object(forKey: "reference") as! String
                    let name = placeDict.object(forKey: "name") as! String
                    let typeList = placeDict.object(forKey: "types") as! [String]
                    let address = ""//placeDict.object(forKey: "vicinity") as! String
                    let type = getPlaceType(typeList)
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    let place = Place(location: location, reference: reference, name: name, address: address , type: type)
                    if(self.places.appendUnique(place)){
                        let annotation = PlaceAnnotation(location: place.location!.coordinate, title: place.placeName, type : place.type)
                        DispatchQueue.main.async {
                            self.mapView.addAnnotation(annotation)
                        }
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001, execute:{self.downloadDequeue()} )
        }
    }
 */
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
        var rect = CGSize(width: 30, height: 30)
        var img = #imageLiteral(resourceName: "paolo")
        if(annotation.title??.contains("plane"))!{
            img = #imageLiteral(resourceName: "paolo")
            rect = CGSize(width: 50, height: 50)
        }else if let t = annotation.subtitle{
            if let type = t {
                if(type.contains("park")){
                    img = #imageLiteral(resourceName: "paolo")
                }
                else if(type.contains("monument")){
                    img = #imageLiteral(resourceName: "paolo")
                }
            }
        }
        UIGraphicsBeginImageContext(rect)
        img.draw(in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        pin.image = UIGraphicsGetImageFromCurrentImageContext()
        return pin
    }
}

