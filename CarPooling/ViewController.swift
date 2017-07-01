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
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.startUpdatingLocation()
//        locationManager.requestWhenInUseAuthorization()
//        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: false)

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
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.canShowCallout=true
        var rect = CGSize(width: 30, height: 30)
        var img = #imageLiteral(resourceName: "pin_city")
        if(annotation.title??.contains("plane"))!{
            img = #imageLiteral(resourceName: "airplane")
            rect = CGSize(width: 50, height: 50)
        }else if let t = annotation.subtitle{
            if let type = t {
                if(type.contains("park")){
                    img = #imageLiteral(resourceName: "pin_parchiNaturali")
                }
                else if(type.contains("monument")){
                    img = #imageLiteral(resourceName: "pin_monumento")
                }
            }
        }
        UIGraphicsBeginImageContext(rect)
        img.draw(in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        pin.image = UIGraphicsGetImageFromCurrentImageContext()
        return pin
    }
}

