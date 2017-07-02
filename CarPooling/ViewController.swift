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

var TRAVEL : [(CLLocationCoordinate2D,String)] = [
    (ROMA,"USER Gino D'Acampo")
    ,(FIRENZE,"DROP Gino D'Acampo")
    ]



var BARI = CLLocationCoordinate2D(latitude: 41.123683, longitude: 16.868231)
var NAPOLI = CLLocationCoordinate2D(latitude: 40.872206, longitude: 14.282761)
var TORINO = CLLocationCoordinate2D(latitude: 45.028762, longitude: 7.619877)
var LIVORNO = CLLocationCoordinate2D(latitude: 43.633870, longitude: 10.501126)
var ROMA = CLLocationCoordinate2D(latitude: 41.9027835, longitude: 12.496365500000024)
var GENOVA = CLLocationCoordinate2D(latitude: 44.4056499, longitude: 8.946255999999948)
var FIRENZE = CLLocationCoordinate2D(latitude: 43.7695604, longitude: 11.25581360000001)
var COSENZA = CLLocationCoordinate2D(latitude: 39.2982629 , longitude: 16.253735699999993)
var MILANO = CLLocationCoordinate2D(latitude: 45.4654219 , longitude: 9.18592430000001)
var TRENTO = CLLocationCoordinate2D(latitude: 46.0747793 , longitude: 11.121748600000046)
var BOLOGNA = CLLocationCoordinate2D(latitude: 44.500992 , longitude: 11.353307)



let currentUser = USERS[Int(arc4random()) % USERS.count].name
var rejectedUsers : [String] = []
var acceptedUsers : [(String,Int)] = []
var distanceNewPercorso = 200000 + Int(arc4random()) % 150000

var START : CLLocationCoordinate2D = NAPOLI
var DESTINATION : CLLocationCoordinate2D = BOLOGNA
var Distances : [Int] = []

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
   
    @IBAction func showAlert(_ sender: Any) {
        let alertController = UIAlertController(title: "Sei arrivato a destinazione", message: "Tempo \(calculateEfficiency().0) Minuti, Emissioni Co2 evitate : \(calculateEfficiency().1*100) (mg/km)", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in self.performSegue(withIdentifier: "backToSignIn", sender: self)})
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func messageReceived(manager: MessageServiceManager, message: String) {
        print(message)
        let opCodes = message.components(separatedBy: "_")
        let part = CLLocationCoordinate2D(latitude: Double(opCodes[1])!, longitude: Double(opCodes[2])!)
        let arr = CLLocationCoordinate2D(latitude: Double(opCodes[3])!, longitude: Double(opCodes[4])!)
        getDistance(start: part, arrival: arr)
        var ut : [String] = []
        for user in USERS {
            ut.append(user.name)
        }
        for accepted in acceptedUsers {
            ut = ut.filter({$0 != accepted.0})
        }
        for rejected in rejectedUsers {
            ut = ut.filter({$0 != rejected})
        }
        if(ut.contains(opCodes[0])){
            let newLenght = distanceNewPercorso
            let alert = UIAlertController(title: "New passenger", message: "Vuoi accettare \(opCodes[0]).Il viaggio si allungherà di \(newLenght/500)km, \(newLenght/850):00 minuti, ma acquisirai \(10 + newLenght/1000 % 100)pt", preferredStyle: UIAlertControllerStyle.actionSheet)
            var rect = CGSize(width: 50, height: 50)
            UIGraphicsBeginImageContext(rect)
            let vista = (UIImageView(frame: CGRect(x: 10, y: 10, width: 50, height: 50)))
            vista.image = USERS.filter({$0.name == message}).first?.image
            alert.view.addSubview(vista)
            let action = UIAlertAction(title: "Si!", style: .default, handler: {_ in
                acceptedUsers.append((opCodes[0],100000))
                self.newPlace(part,arr,opCodes[0])
            })
            let action2 = UIAlertAction(title: "No!", style: .cancel, handler: {_ in
                rejectedUsers.append(opCodes[0])
            })
            alert.addAction(action)
            alert.addAction(action2)
            self.present(alert, animated: true)
        }
    }
    
    func newPlace(_ part : CLLocationCoordinate2D,_ arr : CLLocationCoordinate2D,_ user : String){
        Distances = []
        mapView.removeOverlays(mapView.overlays)
        TRAVEL.append((part,"USER "+user))
        TRAVEL.append((arr,"DROP "+user))
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
                    TRAVEL = ordeBySecond(toOrder: TRAVEL, indexes: waypoint_order) as! [(CLLocationCoordinate2D,String)]
                    handler(self.findAndDraw())
                }
            }
        }
    }
    
    func findAndDraw(){
        if(TRAVEL.count < 1) {
            self.getDirectionsAndDraw(start: START, arrival: DESTINATION)
            return
        }
        self.getDirectionsAndDraw(start: START , arrival: TRAVEL[0].0)
        if TRAVEL.count > 1 {
            for k in 0..<TRAVEL.count-1 {
                self.getDirectionsAndDraw(start: TRAVEL[k].0 , arrival: TRAVEL[k+1].0)
                var point = PlaceAnnotation(location: TRAVEL[k].0, title: "\(k)", subtitle: TRAVEL[k].1)
                if TRAVEL[k].1.contains("DROP") {
                    point = PlaceAnnotation(location: TRAVEL[k].0, title: "Arrivo Passeggero", subtitle: TRAVEL[k].1.replacingOccurrences(of: "DROP", with: ""))
                    point.type = 1
                } else if TRAVEL[k].1.contains("USER"){
                    point = PlaceAnnotation(location: TRAVEL[k].0, title: "Salita Passeggero",subtitle: TRAVEL[k].1.replacingOccurrences(of: "USER ", with: ""))
                    point.type = -1
                } else {point.type = 0}
                mapView.addAnnotation(point)
            }
        }
        self.getDirectionsAndDraw(start: TRAVEL[TRAVEL.count-1].0 , arrival: DESTINATION)
        var point = PlaceAnnotation(location: TRAVEL[TRAVEL.count-1].0, title: "end", subtitle: "nil")
        if TRAVEL[TRAVEL.count-1].1.contains("DROP") {
            point = PlaceAnnotation(location: TRAVEL[TRAVEL.count-1].0, title: "Arrivo Passeggero", subtitle: TRAVEL[TRAVEL.count-1].1.replacingOccurrences(of: "DROP", with: ""))
            point.type = 1
        } else if TRAVEL[TRAVEL.count-1].1.contains("USER"){
            point = PlaceAnnotation(location: TRAVEL[TRAVEL.count-1].0, title: "Salita Passeggero", subtitle: TRAVEL[TRAVEL.count-1].1.replacingOccurrences(of: "USER ", with: ""))
            point.type = -1
        } else {point.type = 0}
        mapView.addAnnotation(point)
    }
    
    override func viewDidLoad() {
        Distances = []
        acceptedUsers.append(("Dave S. Avel",200000))
        messageService.delegate=self
        super.viewDidLoad()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
        }
    }
    
    
    
    
    @IBAction func viaggioDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "viaggioSegue", sender: nil)
        
    }
    
    
    @IBAction func passaggioDidTouch(_ sender: Any) {
        
        performSegue(withIdentifier: "passaggioSegue", sender: nil)
        
    }
    
    
    func generateVeicle(_ n : Int){
        CARS[0].route=array1.reversed()
        CARS[1].route=array1
        CARS[2].route=array2
        CARS[3].route=array2
        CARS[4].route=array2.reversed()
        CARS[5].route=array2.reversed()
        
        CARS[0].routePlace = Int(arc4random()) % 40 + 10
        CARS[1].routePlace = Int(arc4random()) % 40 + 10
        CARS[2].routePlace = Int(arc4random()) % 100 + 10
        CARS[3].routePlace = Int(arc4random()) % 100 + 10
        CARS[4].routePlace = Int(arc4random()) % 100 + 20
        CARS[5].routePlace = Int(arc4random()) % 100 + 20
        
        CARS[0].driver = USERS.first
        CARS[1].driver = USERS.first
        CARS[2].driver = USERS.first
        CARS[3].driver = USERS.first
        CARS[4].driver = USERS.first
        CARS[5].driver = USERS.first
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
        for k in 0..<6 {
            veicles[k].0.routePlace = (veicles[k].0.routePlace+2) % veicles[k].0.route.count
            veicles[k].0.position = veicles[k].0.route[veicles[k].0.routePlace]
            mapView.removeAnnotation(veicles[k].1)
            veicles[k].1.coordinate = veicles[k].0.position
            mapView.addAnnotation(veicles[k].1)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            print(calculateEfficiency())
            //askRide(partenza, arrivo)
            self.refreshCar()
        }
    }
    
    func getDirectionsAndDraw(start : CLLocationCoordinate2D, arrival : CLLocationCoordinate2D) {
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
                self.drawRoute(response!)
            }
        })
    }
    
    func getDistance(start : CLLocationCoordinate2D, arrival : CLLocationCoordinate2D) {
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
                distanceNewPercorso = self.showRoute(response!)
            }
        })
    }
    
    func drawRoute(_ response: MKDirectionsResponse){
        for route in response.routes {
            Distances.append(Int(route.distance))
            mapView.add(route.polyline,
                        level: MKOverlayLevel.aboveRoads)
        }
    }
    
    func showRoute(_ response: MKDirectionsResponse) -> Int {
        var rou : Int = 0
        for route in response.routes {
            rou += (Int(route.distance))
        }
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        /*
        for a in rou {
            print("\(CLLocationCoordinate2D(latitude: a.latitude, longitude: a.longitude)),")
        }
         */
        return rou
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

func routeUrlCreate(_ departure : CLLocationCoordinate2D,_ arrival : CLLocationCoordinate2D , _ waypoints : [(CLLocationCoordinate2D,String)]) -> String{
    var basicUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=\(departure.latitude),\(departure.longitude)&destination=\(arrival.latitude),\(arrival.longitude)&key=AIzaSyAGjTDcNLXG5OVuluxG3MvSNiMbDJMUlns"
    if waypoints.count != 0 {
        basicUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=\(departure.latitude),\(departure.longitude)&destination=\(arrival.latitude),\(arrival.longitude)&waypoints=optimize:false"
        for wp in waypoints {
            basicUrl.append("|\(wp.0.latitude),\(wp.0.longitude)")
        }
        basicUrl.append("&key=AIzaSyAGjTDcNLXG5OVuluxG3MvSNiMbDJMUlns")
    }
    return basicUrl
}

func getCompletePath(_ departure : CLLocationCoordinate2D,_ arrival : CLLocationCoordinate2D ,_  waypoints : [(CLLocationCoordinate2D,String)], handler: @escaping (NSDictionary?, NSError?) -> Void){
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
        var rect = CGSize(width: 50, height: 50)
        var img = #imageLiteral(resourceName: "pinfinalebianco")
        if let place = annotation as? PlaceAnnotation {
            switch place.type {
            case 0: // Azienda
                img = #imageLiteral(resourceName: "Roma")
                rect = CGSize(width: 40, height: 40)
            case -1: // Dipendente
                print(place.subtitle)
                let dipendente = UIImage(named: (USERS.filter({$0.name == place.subtitle}).first?.id)!)
                img = dipendente!
                rect = CGSize(width: 50, height: 50)
            case 1: // drop
                img = #imageLiteral(resourceName: "pinfermata")
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
                img = #imageLiteral(resourceName: "pinverdesuperfinale")
                rect = CGSize(width: 40, height: 40)
            }
            else {
                img = #imageLiteral(resourceName: "pinrossosuperfinale")
                rect = CGSize(width: 35, height: 35)
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
func calculateEfficiency() -> (Int,Double){
    var carEff = 0.5
    var effectiveKm = 0
    for km in Distances {
        effectiveKm+=km
    }
    var clearKm = effectiveKm
    for user in acceptedUsers{
        clearKm -= user.1/2
    }
    return (effectiveKm,Double(clearKm)/Double(effectiveKm))
}

func askRide(_ part : String,_ arrival : String){
    var par = String(BOLOGNA.latitude) + "_" + String(BOLOGNA.longitude)
    var arr = String(BOLOGNA.latitude) + "_" + String(BOLOGNA.longitude)
    if(part == "Bari"){
        par = String(BARI.latitude) + "_" + String(BARI.longitude)
    }else if part == "Napoli" {
        par = String(NAPOLI.latitude) + "_" + String(NAPOLI.longitude)
    }else if part == "Torino" {
        par = String(TORINO.latitude) + "_" + String(TORINO.longitude)
    }else if part == "Livorno" {
        par = String(LIVORNO.latitude) + "_" + String(LIVORNO.longitude)
    }else if part == "Roma" {
        par = String(ROMA.latitude) + "_" + String(ROMA.longitude)
    }else if part == "Genova" {
        par = String(GENOVA.latitude) + "_" + String(GENOVA.longitude)
    }else if part == "Firenze" {
        par = String(FIRENZE.latitude) + "_" + String(FIRENZE.longitude)
    }else if part == "Cosenza" {
        par = String(COSENZA.latitude) + "_" + String(COSENZA.longitude)
    }else if part == "Milano" {
        par = String(MILANO.latitude) + "_" + String(MILANO.longitude)
    }else if part == "Trento" {
        par = String(TRENTO.latitude) + "_" + String(TRENTO.longitude)
    }
    if(arr == "Bari"){
        arr = String(BARI.latitude) + "_" + String(BARI.longitude)
    }else if arr == "Napoli" {
        arr = String(NAPOLI.latitude) + "_" + String(NAPOLI.longitude)
    }else if arr == "Torino" {
        arr = String(TORINO.latitude) + "_" + String(TORINO.longitude)
    }else if arr == "Livorno" {
        arr = String(LIVORNO.latitude) + "_" + String(LIVORNO.longitude)
    }else if arr == "Roma" {
        arr = String(ROMA.latitude) + "_" + String(ROMA.longitude)
    }else if arr == "Genova" {
        arr = String(GENOVA.latitude) + "_" + String(GENOVA.longitude)
    }else if arr == "Firenze" {
        arr = String(FIRENZE.latitude) + "_" + String(FIRENZE.longitude)
    }else if arr == "Cosenza" {
        arr = String(COSENZA.latitude) + "_" + String(COSENZA.longitude)
    }else if arr == "Milano" {
        arr = String(MILANO.latitude) + "_" + String(MILANO.longitude)
    }else if arr == "Trento" {
        arr = String(TRENTO.latitude) + "_" + String(TRENTO.longitude)
    }
    messageService.sendToAll(message: currentUser + "_" + par + "_" + arr)
}


let array1 : [CLLocationCoordinate2D] =
    [
        CLLocationCoordinate2D(latitude: 40.872246958315372, longitude: 14.282707938524595),
        CLLocationCoordinate2D(latitude: 40.874075973406427, longitude: 14.285291995453946),
        CLLocationCoordinate2D(latitude: 40.87408393621444, longitude: 14.285718969601646),
        CLLocationCoordinate2D(latitude: 40.87381596677006, longitude: 14.28583396931316),
        CLLocationCoordinate2D(latitude: 40.873600970953703, longitude: 14.286417936507235),
        CLLocationCoordinate2D(latitude: 40.873941946774735, longitude: 14.287478917810972),
        CLLocationCoordinate2D(latitude: 40.873636929318316, longitude: 14.28777798411619),
        CLLocationCoordinate2D(latitude: 40.874537983909235, longitude: 14.291184976299093),
        CLLocationCoordinate2D(latitude: 40.876028956845396, longitude: 14.291006944675729),
        CLLocationCoordinate2D(latitude: 40.875203926116221, longitude: 14.300677984557296),
        CLLocationCoordinate2D(latitude: 40.876463977619999, longitude: 14.301926971949172),
        CLLocationCoordinate2D(latitude: 40.874211927875869, longitude: 14.304059998668748),
        CLLocationCoordinate2D(latitude: 40.876088971272111, longitude: 14.308453959950356),
        CLLocationCoordinate2D(latitude: 40.876113949343569, longitude: 14.308549932741727),
        CLLocationCoordinate2D(latitude: 40.898532941937439, longitude: 14.33299198149075),
        CLLocationCoordinate2D(latitude: 40.90133392252028, longitude: 14.345367945345458),
        CLLocationCoordinate2D(latitude: 40.901818983256824, longitude: 14.350853984791513),
        CLLocationCoordinate2D(latitude: 40.901852929964662, longitude: 14.351085995871358),
        CLLocationCoordinate2D(latitude: 40.902397921308882, longitude: 14.357543916990409),
        CLLocationCoordinate2D(latitude: 40.902431951835759, longitude: 14.357702921693573),
        CLLocationCoordinate2D(latitude: 40.904907966032617, longitude: 14.366400990254817),
        CLLocationCoordinate2D(latitude: 40.905006956309066, longitude: 14.366864928595447),
        CLLocationCoordinate2D(latitude: 40.90811496600508, longitude: 14.375147925311495),
        CLLocationCoordinate2D(latitude: 40.910002989694469, longitude: 14.382577979560637),
        CLLocationCoordinate2D(latitude: 40.910214968025677, longitude: 14.382841925691537),
        CLLocationCoordinate2D(latitude: 40.910183954983935, longitude: 14.382969917352995),
        CLLocationCoordinate2D(latitude: 40.914860973134637, longitude: 14.405093950779445),
        CLLocationCoordinate2D(latitude: 40.915004974231124, longitude: 14.405819991232306),
        CLLocationCoordinate2D(latitude: 40.91969791799783, longitude: 14.420688984547922),
        CLLocationCoordinate2D(latitude: 40.919743934646235, longitude: 14.420830973987677),
        CLLocationCoordinate2D(latitude: 40.925574973225579, longitude: 14.452981942904415),
        CLLocationCoordinate2D(latitude: 40.925536919385195, longitude: 14.45315092207241),
        CLLocationCoordinate2D(latitude: 40.926323980092995, longitude: 14.475966965424846),
        CLLocationCoordinate2D(latitude: 40.933327982202158, longitude: 14.503475952545074),
        CLLocationCoordinate2D(latitude: 40.933414986357086, longitude: 14.505519963452969),
        CLLocationCoordinate2D(latitude: 40.934568922966719, longitude: 14.508828971187768),
        CLLocationCoordinate2D(latitude: 40.94020399264992, longitude: 14.536017937244821),
        CLLocationCoordinate2D(latitude: 40.951893981546164, longitude: 14.612988954087029),
        CLLocationCoordinate2D(latitude: 40.951832961291068, longitude: 14.619373952648459),
        CLLocationCoordinate2D(latitude: 40.94831398688256, longitude: 14.622285993449026),
        CLLocationCoordinate2D(latitude: 40.93504392541945, longitude: 14.647207989973793),
        CLLocationCoordinate2D(latitude: 40.934887938201413, longitude: 14.647464979125061),
        CLLocationCoordinate2D(latitude: 40.900847939774387, longitude: 14.704963996704919),
        CLLocationCoordinate2D(latitude: 40.899605993181474, longitude: 14.706007962745161),
        CLLocationCoordinate2D(latitude: 40.898907948285355, longitude: 14.706072922494741),
        CLLocationCoordinate2D(latitude: 40.898321969434612, longitude: 14.707378990647243),
        CLLocationCoordinate2D(latitude: 40.89237894862891, longitude: 14.71192692749014),
        CLLocationCoordinate2D(latitude: 40.891848960891373, longitude: 14.716182922645515),
        CLLocationCoordinate2D(latitude: 40.891801938414574, longitude: 14.716454999222549),
        CLLocationCoordinate2D(latitude: 40.906721977517002, longitude: 14.747904989576881),
        CLLocationCoordinate2D(latitude: 40.907073933631168, longitude: 14.74869892344546),
        CLLocationCoordinate2D(latitude: 40.906489966437213, longitude: 14.76326893427489),
        CLLocationCoordinate2D(latitude: 40.911667970940456, longitude: 14.7721229900541),
        CLLocationCoordinate2D(latitude: 40.911700995638952, longitude: 14.772264979493883),
        CLLocationCoordinate2D(latitude: 40.912851998582468, longitude: 14.780580917089367),
        CLLocationCoordinate2D(latitude: 40.913261957466595, longitude: 14.783238986223779),
        CLLocationCoordinate2D(latitude: 40.914471969008446, longitude: 14.791921967359229),
        CLLocationCoordinate2D(latitude: 40.914660980924964, longitude: 14.791908975409314),
        CLLocationCoordinate2D(latitude: 40.914729963988066, longitude: 14.793364995809554),
        CLLocationCoordinate2D(latitude: 40.915167918428779, longitude: 14.79548796424541),
        CLLocationCoordinate2D(latitude: 40.915181916207075, longitude: 14.812201982087515),
        CLLocationCoordinate2D(latitude: 40.913768978789449, longitude: 14.816499970577809),
        CLLocationCoordinate2D(latitude: 40.913772918283954, longitude: 14.816709937252256),
        CLLocationCoordinate2D(latitude: 40.914698950946317, longitude: 14.819201960884811),
        CLLocationCoordinate2D(latitude: 40.914879916235797, longitude: 14.819429948651134),
        CLLocationCoordinate2D(latitude: 40.918191941454992, longitude: 14.828050987522147),
        CLLocationCoordinate2D(latitude: 40.918247932568178, longitude: 14.828293978895118),
        CLLocationCoordinate2D(latitude: 40.919776959344745, longitude: 14.833131929587864),
        CLLocationCoordinate2D(latitude: 40.919612925499678, longitude: 14.83342496092277),
        CLLocationCoordinate2D(latitude: 40.919412933289998, longitude: 14.833547923442296),
        CLLocationCoordinate2D(latitude: 40.920355981215828, longitude: 14.837733929706218),
        CLLocationCoordinate2D(latitude: 40.925328964367502, longitude: 14.848440972820015),
        CLLocationCoordinate2D(latitude: 40.928117958828793, longitude: 14.857014989214292),
        CLLocationCoordinate2D(latitude: 40.928659932687864, longitude: 14.861592933270515),
        CLLocationCoordinate2D(latitude: 40.931197972968221, longitude: 14.888051919380217),
        CLLocationCoordinate2D(latitude: 40.939762936905041, longitude: 14.974362974747635),
        CLLocationCoordinate2D(latitude: 40.941030951216824, longitude: 14.981376951323227),
        CLLocationCoordinate2D(latitude: 40.944854943081737, longitude: 14.986928956347271),
        CLLocationCoordinate2D(latitude: 40.949428947642438, longitude: 15.000295996433181),
        CLLocationCoordinate2D(latitude: 40.949907973408692, longitude: 15.001870956039483),
        CLLocationCoordinate2D(latitude: 40.951225943863385, longitude: 15.005722943461905),
        CLLocationCoordinate2D(latitude: 40.951947961002581, longitude: 15.011212922402478),
        CLLocationCoordinate2D(latitude: 40.952149964869029, longitude: 15.01141894958252),
        CLLocationCoordinate2D(latitude: 40.952926967293031, longitude: 15.013616936051676),
        CLLocationCoordinate2D(latitude: 40.951997917145484, longitude: 15.013697989055345),
        CLLocationCoordinate2D(latitude: 40.953620988875628, longitude: 15.016080964127582),
        CLLocationCoordinate2D(latitude: 40.954941976815455, longitude: 15.023715955909267),
        CLLocationCoordinate2D(latitude: 40.957543971017003, longitude: 15.025189997401355),
        CLLocationCoordinate2D(latitude: 40.96116294153034, longitude: 15.039684990197372),
        CLLocationCoordinate2D(latitude: 40.960676958784454, longitude: 15.048340981604611),
        CLLocationCoordinate2D(latitude: 40.969631932675846, longitude: 15.08550994449422),
        CLLocationCoordinate2D(latitude: 40.970462998375297, longitude: 15.087720922913377),
        CLLocationCoordinate2D(latitude: 40.972825940698378, longitude: 15.0888519769276),
        CLLocationCoordinate2D(latitude: 40.973018975928419, longitude: 15.090030975427965),
        CLLocationCoordinate2D(latitude: 40.973591962829225, longitude: 15.09033196957094),
        CLLocationCoordinate2D(latitude: 40.973315946757793, longitude: 15.090984919828117),
        CLLocationCoordinate2D(latitude: 40.974140977486968, longitude: 15.093429920983851),
        CLLocationCoordinate2D(latitude: 40.976132936775684, longitude: 15.098177933855482),
        CLLocationCoordinate2D(latitude: 40.975932944566004, longitude: 15.099156940146145),
        CLLocationCoordinate2D(latitude: 40.975960940122611, longitude: 15.09923799314987),
        CLLocationCoordinate2D(latitude: 40.974478935822845, longitude: 15.101475961297183),
        CLLocationCoordinate2D(latitude: 40.974139971658587, longitude: 15.112874930517961),
        CLLocationCoordinate2D(latitude: 40.976397972553976, longitude: 15.121616920251796),
        CLLocationCoordinate2D(latitude: 40.975771928206072, longitude: 15.14827397073347),
        CLLocationCoordinate2D(latitude: 40.970024960115552, longitude: 15.152073990356229),
        CLLocationCoordinate2D(latitude: 40.973344948142774, longitude: 15.164160946189469),
        CLLocationCoordinate2D(latitude: 40.959607930853963, longitude: 15.1915229985471),
        CLLocationCoordinate2D(latitude: 40.972571969032295, longitude: 15.239582987325178),
        CLLocationCoordinate2D(latitude: 40.972232921048992, longitude: 15.239848945112868),
        CLLocationCoordinate2D(latitude: 40.972258988767862, longitude: 15.239987917067509),
        CLLocationCoordinate2D(latitude: 40.973292980343096, longitude: 15.243020992549845),
        CLLocationCoordinate2D(latitude: 40.975626921281211, longitude: 15.253124957730336),
        CLLocationCoordinate2D(latitude: 40.977111943066106, longitude: 15.258030969476835),
        CLLocationCoordinate2D(latitude: 40.976791922003031, longitude: 15.259734926572975),
        CLLocationCoordinate2D(latitude: 40.977720972150564, longitude: 15.279214972462341),
        CLLocationCoordinate2D(latitude: 40.977605972439051, longitude: 15.279170967470691),
        CLLocationCoordinate2D(latitude: 40.990085955709212, longitude: 15.322758959448635),
        CLLocationCoordinate2D(latitude: 40.990055948495865, longitude: 15.323957990697608),
        CLLocationCoordinate2D(latitude: 41.000198973342769, longitude: 15.344785930436302),
        CLLocationCoordinate2D(latitude: 40.995874917134628, longitude: 15.351444933412495),
        CLLocationCoordinate2D(latitude: 40.997463958337903, longitude: 15.353273948503954),
        CLLocationCoordinate2D(latitude: 40.990578979253762, longitude: 15.363527949751244),
        CLLocationCoordinate2D(latitude: 40.991410966962569, longitude: 15.364864947126449),
        CLLocationCoordinate2D(latitude: 41.001388952136047, longitude: 15.385038930779558),
        CLLocationCoordinate2D(latitude: 41.000297963619218, longitude: 15.385420977926231),
        CLLocationCoordinate2D(latitude: 40.995989916846149, longitude: 15.389003990075821),
        CLLocationCoordinate2D(latitude: 40.994332982227213, longitude: 15.395371973373813),
        CLLocationCoordinate2D(latitude: 40.993794947862618, longitude: 15.40163895473853),
        CLLocationCoordinate2D(latitude: 41.015734998509288, longitude: 15.45699991645688),
        CLLocationCoordinate2D(latitude: 41.021579951047904, longitude: 15.4709229281803),
        CLLocationCoordinate2D(latitude: 41.021663937717669, longitude: 15.470937931786978),
        CLLocationCoordinate2D(latitude: 41.021840963512652, longitude: 15.47080994012552),
        CLLocationCoordinate2D(latitude: 41.029255930334337, longitude: 15.481911938516873),
        CLLocationCoordinate2D(latitude: 41.038313917815678, longitude: 15.483301993339182),
        CLLocationCoordinate2D(latitude: 41.037043975666151, longitude: 15.487442988782988),
        CLLocationCoordinate2D(latitude: 41.040080990642309, longitude: 15.49147493566656),
        CLLocationCoordinate2D(latitude: 41.03956894017756, longitude: 15.493129942448178),
        CLLocationCoordinate2D(latitude: 41.046073967590928, longitude: 15.498199988039744),
        CLLocationCoordinate2D(latitude: 41.050884928554282, longitude: 15.496861984836158),
        CLLocationCoordinate2D(latitude: 41.050777975469806, longitude: 15.498145924764231),
        CLLocationCoordinate2D(latitude: 41.053439984098084, longitude: 15.503884930048116),
        CLLocationCoordinate2D(latitude: 41.056491918861852, longitude: 15.516527941337927),
        CLLocationCoordinate2D(latitude: 41.055249972268946, longitude: 15.517692942059995),
        CLLocationCoordinate2D(latitude: 41.055392967537053, longitude: 15.528472991550444),
        CLLocationCoordinate2D(latitude: 41.094002947211258, longitude: 16.75907392444995),
        CLLocationCoordinate2D(latitude: 41.094027925282703, longitude: 16.759188924161549),
        CLLocationCoordinate2D(latitude: 41.091010943055153, longitude: 16.771252997399159),
        CLLocationCoordinate2D(latitude: 41.090866941958666, longitude: 16.771729927689677),
        CLLocationCoordinate2D(latitude: 41.090798964723938, longitude: 16.771886920736137),
        CLLocationCoordinate2D(latitude: 41.093432977795594, longitude: 16.776082985283836),
        CLLocationCoordinate2D(latitude: 41.095705982297659, longitude: 16.789476931278955),
        CLLocationCoordinate2D(latitude: 41.095597939565785, longitude: 16.789569970404159),
        CLLocationCoordinate2D(latitude: 41.118953945115202, longitude: 16.844034990492247),
        CLLocationCoordinate2D(latitude: 41.11897096037864, longitude: 16.844217967438567),
        CLLocationCoordinate2D(latitude: 41.120457993820317, longitude: 16.848164921823951),
        CLLocationCoordinate2D(latitude: 41.120518930256367, longitude: 16.848303977597595),
        CLLocationCoordinate2D(latitude: 41.124006975442164, longitude: 16.857126936516067),
        CLLocationCoordinate2D(latitude: 41.123342961072922, longitude: 16.857174964821269),
        CLLocationCoordinate2D(latitude: 41.123952995985732, longitude: 16.868148971551136),
        CLLocationCoordinate2D(latitude: 41.123678991571069, longitude: 16.868176967107729)
]

let array2 : [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 43.634198969230042, longitude: 10.498567998991035),
        CLLocationCoordinate2D(latitude: 43.62923696637155, longitude: 10.493395945637786),
        CLLocationCoordinate2D(latitude: 43.623946979641914, longitude: 10.500271956087147),
        CLLocationCoordinate2D(latitude: 43.609375962987542, longitude: 10.518449957137562),
        CLLocationCoordinate2D(latitude: 43.608273994177566, longitude: 10.526140940032462),
        CLLocationCoordinate2D(latitude: 43.608085988089442, longitude: 10.5267559202683),
        CLLocationCoordinate2D(latitude: 43.604042977094643, longitude: 10.577691991482311),
        CLLocationCoordinate2D(latitude: 43.604856943711638, longitude: 10.595260963448169),
        CLLocationCoordinate2D(latitude: 43.609977951273315, longitude: 10.64308198416677),
        CLLocationCoordinate2D(latitude: 43.610517997294671, longitude: 10.643833924700488),
        CLLocationCoordinate2D(latitude: 43.592915916815407, longitude: 10.668754999215878),
        CLLocationCoordinate2D(latitude: 43.592837965115891, longitude: 10.668940993647311),
        CLLocationCoordinate2D(latitude: 43.580225966870792, longitude: 10.682724949597116),
        CLLocationCoordinate2D(latitude: 43.580012982711203, longitude: 10.683123928188166),
        CLLocationCoordinate2D(latitude: 43.580548921599977, longitude: 10.703697980079738),
        CLLocationCoordinate2D(latitude: 43.580598961561911, longitude: 10.704040967557603),
        CLLocationCoordinate2D(latitude: 43.580645984038703, longitude: 10.704604985822129),
        CLLocationCoordinate2D(latitude: 43.582655964419253, longitude: 10.722861944400478),
        CLLocationCoordinate2D(latitude: 43.580430988222361, longitude: 10.726568924897947),
        CLLocationCoordinate2D(latitude: 43.578955940902233, longitude: 10.748152996121974),
        CLLocationCoordinate2D(latitude: 43.577939970418804, longitude: 10.752240934118674),
        CLLocationCoordinate2D(latitude: 43.57699197717011, longitude: 10.75533192855201),
        CLLocationCoordinate2D(latitude: 43.574032997712472, longitude: 10.763136989149075),
        CLLocationCoordinate2D(latitude: 43.493999987840638, longitude: 10.926625926728974),
        CLLocationCoordinate2D(latitude: 43.480715928599238, longitude: 10.95379896717003),
        CLLocationCoordinate2D(latitude: 43.476593960076563, longitude: 11.028857988079295),
        CLLocationCoordinate2D(latitude: 43.476353986188762, longitude: 11.02933097887535),
        CLLocationCoordinate2D(latitude: 43.471208922564976, longitude: 11.038124936408877),
        CLLocationCoordinate2D(latitude: 43.470342988148317, longitude: 11.040892976112872),
        CLLocationCoordinate2D(latitude: 43.469831943511956, longitude: 11.040859951414376),
        CLLocationCoordinate2D(latitude: 43.463555993512266, longitude: 11.04201891716616),
        CLLocationCoordinate2D(latitude: 43.463463960215442, longitude: 11.04182395409839),
        CLLocationCoordinate2D(latitude: 43.460924997925744, longitude: 11.059748989310947),
        CLLocationCoordinate2D(latitude: 43.45982294529675, longitude: 11.064701939715263),
        CLLocationCoordinate2D(latitude: 43.45291692763567, longitude: 11.082917994606021),
        CLLocationCoordinate2D(latitude: 43.419231986626976, longitude: 11.096903954422316),
        CLLocationCoordinate2D(latitude: 43.421525945886955, longitude: 11.111640932762924),
        CLLocationCoordinate2D(latitude: 43.422089964151368, longitude: 11.122169944253301),
        CLLocationCoordinate2D(latitude: 43.422736963257179, longitude: 11.12723294904626),
        CLLocationCoordinate2D(latitude: 43.423152957111597, longitude: 11.127246946824556),
        CLLocationCoordinate2D(latitude: 43.422556919977062, longitude: 11.129214933870628),
        CLLocationCoordinate2D(latitude: 43.422861937433481, longitude: 11.129855981825358),
        CLLocationCoordinate2D(latitude: 43.419747976586216, longitude: 11.138077958286289),
        CLLocationCoordinate2D(latitude: 43.41966499574481, longitude: 11.138407953814237),
        CLLocationCoordinate2D(latitude: 43.418286927044385, longitude: 11.14382693803492),
        CLLocationCoordinate2D(latitude: 43.417323930189013, longitude: 11.147485974046276),
        CLLocationCoordinate2D(latitude: 43.416581964120269, longitude: 11.147267960744756),
        CLLocationCoordinate2D(latitude: 43.413534974679351, longitude: 11.158376999934745),
        CLLocationCoordinate2D(latitude: 43.413166925311089, longitude: 11.158815960203952),
        CLLocationCoordinate2D(latitude: 43.406948978081338, longitude: 11.166999966643544),
        CLLocationCoordinate2D(latitude: 43.406731970608234, longitude: 11.167223931096316),
        CLLocationCoordinate2D(latitude: 43.393173990771167, longitude: 11.190939939392479),
        CLLocationCoordinate2D(latitude: 43.393149934709079, longitude: 11.191495994849049),
        CLLocationCoordinate2D(latitude: 43.392715919762843, longitude: 11.217035989094768),
        CLLocationCoordinate2D(latitude: 43.39267292059958, longitude: 11.219009927292149),
        CLLocationCoordinate2D(latitude: 43.35183796472846, longitude: 11.270185972393989),
        CLLocationCoordinate2D(latitude: 43.351461952552199, longitude: 11.271316942589237),
        CLLocationCoordinate2D(latitude: 43.349020974710577, longitude: 11.275623983534928),
        CLLocationCoordinate2D(latitude: 43.348886948078864, longitude: 11.27582498157301),
        CLLocationCoordinate2D(latitude: 43.34404396824538, longitude: 11.285673969258937),
        CLLocationCoordinate2D(latitude: 43.344002980738878, longitude: 11.285989967008589),
        CLLocationCoordinate2D(latitude: 43.344706976786242, longitude: 11.298268952243546),
        CLLocationCoordinate2D(latitude: 43.344654925167561, longitude: 11.298591990791863),
        CLLocationCoordinate2D(latitude: 43.343436950817697, longitude: 11.305616947660639),
        CLLocationCoordinate2D(latitude: 43.343375930562608, longitude: 11.305933951238615),
        CLLocationCoordinate2D(latitude: 43.344419980421655, longitude: 11.306678934792671),
        CLLocationCoordinate2D(latitude: 43.344451999291756, longitude: 11.30694296474266),
        CLLocationCoordinate2D(latitude: 43.335549999028444, longitude: 11.313914947983363),
        CLLocationCoordinate2D(latitude: 43.335280939936631, longitude: 11.314141929921277),
        CLLocationCoordinate2D(latitude: 43.33317196927964, longitude: 11.317536935982645),
        CLLocationCoordinate2D(latitude: 43.332725968211882, longitude: 11.317500977618067),
        CLLocationCoordinate2D(latitude: 43.332318942993886, longitude: 11.319058921960874),
        CLLocationCoordinate2D(latitude: 43.332177959382527, longitude: 11.319399981601009),
        CLLocationCoordinate2D(latitude: 43.330143922939889, longitude: 11.325644918560442),
        CLLocationCoordinate2D(latitude: 43.330125985667095, longitude: 11.326073988183879),
        CLLocationCoordinate2D(latitude: 43.327407985925674, longitude: 11.331897985965924),
        CLLocationCoordinate2D(latitude: 43.327510999515653, longitude: 11.332382962883543),
        CLLocationCoordinate2D(latitude: 43.327764971181736, longitude: 11.337806976246128),
        CLLocationCoordinate2D(latitude: 43.327742926776409, longitude: 11.338280972870592),
        CLLocationCoordinate2D(latitude: 43.326932983472943, longitude: 11.340339987385164),
        CLLocationCoordinate2D(latitude: 43.326917979866273, longitude: 11.340830999273066),
        CLLocationCoordinate2D(latitude: 43.32129397429523, longitude: 11.349934919585962),
        CLLocationCoordinate2D(latitude: 43.321003960445523, longitude: 11.350235997547912),
        CLLocationCoordinate2D(latitude: 43.316592983901494, longitude: 11.355269917136809),
        CLLocationCoordinate2D(latitude: 43.316408917307861, longitude: 11.355442919618355),
        CLLocationCoordinate2D(latitude: 43.316262988373637, longitude: 11.355660932919875),
        CLLocationCoordinate2D(latitude: 43.30509795807302, longitude: 11.36560798887291),
        CLLocationCoordinate2D(latitude: 43.29436291940511, longitude: 11.394082990333942),
        CLLocationCoordinate2D(latitude: 43.294295947998755, longitude: 11.394692941427849),
        CLLocationCoordinate2D(latitude: 43.295864956453435, longitude: 11.401981928246585),
        CLLocationCoordinate2D(latitude: 43.295661946758614, longitude: 11.402205976518388),
        CLLocationCoordinate2D(latitude: 43.293973999097936, longitude: 11.410991971243874),
        CLLocationCoordinate2D(latitude: 43.293825974687927, longitude: 11.411258934859916),
        CLLocationCoordinate2D(latitude: 43.239016961306326, longitude: 11.55464999646756),
        CLLocationCoordinate2D(latitude: 43.238731976598508, longitude: 11.554830961757091),
        CLLocationCoordinate2D(latitude: 43.236853927373879, longitude: 11.557254924335808),
        CLLocationCoordinate2D(latitude: 43.233989998698249, longitude: 11.560634926790527),
        CLLocationCoordinate2D(latitude: 43.230695994570858, longitude: 11.632660956036489),
        CLLocationCoordinate2D(latitude: 43.208802966400967, longitude: 11.723015944408985),
        CLLocationCoordinate2D(latitude: 43.179147960618138, longitude: 11.771518916769764),
        CLLocationCoordinate2D(latitude: 43.182231998071067, longitude: 11.774610917031481),
        CLLocationCoordinate2D(latitude: 43.178700953722014, longitude: 11.786076941477631),
        CLLocationCoordinate2D(latitude: 43.17861394956708, longitude: 11.78845698288373),
        CLLocationCoordinate2D(latitude: 43.178531974554048, longitude: 11.78867994150815),
        CLLocationCoordinate2D(latitude: 43.174401959404349, longitude: 11.795241965864648),
        CLLocationCoordinate2D(latitude: 43.174107922241085, longitude: 11.795859963585599),
        CLLocationCoordinate2D(latitude: 43.173802988603718, longitude: 11.796301941339919),
        CLLocationCoordinate2D(latitude: 43.181528924033046, longitude: 11.826329941820887),
        CLLocationCoordinate2D(latitude: 43.183350982144482, longitude: 11.834696925206742),
        CLLocationCoordinate2D(latitude: 43.173016933724277, longitude: 11.8454109253002),
        CLLocationCoordinate2D(latitude: 43.142394991591573, longitude: 11.888410926770518),
        CLLocationCoordinate2D(latitude: 43.145217932760723, longitude: 11.896698952628441),
        CLLocationCoordinate2D(latitude: 43.122716965153806, longitude: 11.920971938390522),
        CLLocationCoordinate2D(latitude: 43.121468983590596, longitude: 11.925784994830792),
        CLLocationCoordinate2D(latitude: 43.127746945247054, longitude: 11.937220928244614),
        CLLocationCoordinate2D(latitude: 43.127885917201638, longitude: 11.938916922532741),
        CLLocationCoordinate2D(latitude: 43.127791956067071, longitude: 11.93915396275446),
        CLLocationCoordinate2D(latitude: 43.12810393050313, longitude: 11.941921918639451),
        CLLocationCoordinate2D(latitude: 43.12155699357389, longitude: 11.95630492920904),
        CLLocationCoordinate2D(latitude: 43.124201986938715, longitude: 12.029198988347588),
        CLLocationCoordinate2D(latitude: 43.117991918697953, longitude: 12.032605980530519),
        CLLocationCoordinate2D(latitude: 43.119551958516233, longitude: 12.03904495854843),
        CLLocationCoordinate2D(latitude: 43.119285916909575, longitude: 12.039567989306448),
        CLLocationCoordinate2D(latitude: 43.094807993620641, longitude: 12.056128953596641),
        CLLocationCoordinate2D(latitude: 43.094677990302451, longitude: 12.056688948547645),
        CLLocationCoordinate2D(latitude: 43.076229924336062, longitude: 12.106877940731806),
        CLLocationCoordinate2D(latitude: 43.087539961561568, longitude: 12.194254922725804),
        CLLocationCoordinate2D(latitude: 43.085325965657816, longitude: 12.197592931845577),
        CLLocationCoordinate2D(latitude: 43.084761947393417, longitude: 12.199467963585505),
        CLLocationCoordinate2D(latitude: 43.07444893755018, longitude: 12.227624955640096),
        CLLocationCoordinate2D(latitude: 43.074033949524164, longitude: 12.228555933625557),
        CLLocationCoordinate2D(latitude: 43.072617994621389, longitude: 12.237062978613437),
        CLLocationCoordinate2D(latitude: 43.072256986051791, longitude: 12.241669924054719),
        CLLocationCoordinate2D(latitude: 43.072762917727232, longitude: 12.243033994977139),
        CLLocationCoordinate2D(latitude: 43.072362933307879, longitude: 12.244173933808753),
        CLLocationCoordinate2D(latitude: 43.074064962565906, longitude: 12.249826940766042),
        CLLocationCoordinate2D(latitude: 43.062035925686352, longitude: 12.26917798916557),
        CLLocationCoordinate2D(latitude: 43.060261979699135, longitude: 12.27368996764389),
        CLLocationCoordinate2D(latitude: 43.060456942766898, longitude: 12.275911926356144),
        CLLocationCoordinate2D(latitude: 43.060324927791953, longitude: 12.275970934954472),
        CLLocationCoordinate2D(latitude: 43.058555927127593, longitude: 12.284966980173465),
        CLLocationCoordinate2D(latitude: 43.05884099565445, longitude: 12.289279972270464),
        CLLocationCoordinate2D(latitude: 43.058830937370644, longitude: 12.291901999221182),
        CLLocationCoordinate2D(latitude: 43.059369977563627, longitude: 12.295444945873555),
        CLLocationCoordinate2D(latitude: 43.05826499126853, longitude: 12.296512967975957),
        CLLocationCoordinate2D(latitude: 43.059420939534903, longitude: 12.304289949197397),
        CLLocationCoordinate2D(latitude: 43.059499980881817, longitude: 12.306492964808484),
        CLLocationCoordinate2D(latitude: 43.039790941402302, longitude: 12.358053990723107),
        CLLocationCoordinate2D(latitude: 43.039443930611014, longitude: 12.358233950184257),
        CLLocationCoordinate2D(latitude: 43.037207974120967, longitude: 12.361617975952441),
        CLLocationCoordinate2D(latitude: 43.034790968522429, longitude: 12.365231917324763),
        CLLocationCoordinate2D(latitude: 43.034783927723772, longitude: 12.365433921191254),
        CLLocationCoordinate2D(latitude: 43.038290999829769, longitude: 12.371527983893543),
        CLLocationCoordinate2D(latitude: 43.03703597746788, longitude: 12.393705996776362),
        CLLocationCoordinate2D(latitude: 43.037030948325985, longitude: 12.393764921555714),
        CLLocationCoordinate2D(latitude: 43.034813934937134, longitude: 12.39898894270857),
        CLLocationCoordinate2D(latitude: 43.034664988517761, longitude: 12.399296977650209),
        CLLocationCoordinate2D(latitude: 43.031109971925616, longitude: 12.427742977726211),
        CLLocationCoordinate2D(latitude: 43.030333975329995, longitude: 12.43034698358511),
        CLLocationCoordinate2D(latitude: 43.031373918056481, longitude: 12.431080986846013),
        CLLocationCoordinate2D(latitude: 43.030205983668573, longitude: 12.4380209512166),
        CLLocationCoordinate2D(latitude: 43.03022392094136, longitude: 12.438510957276122),
        CLLocationCoordinate2D(latitude: 43.021898930892348, longitude: 12.499357958440527),
        CLLocationCoordinate2D(latitude: 43.021857943385832, longitude: 12.499807982821892),
        CLLocationCoordinate2D(latitude: 43.023071978241198, longitude: 12.506414934179418),
        CLLocationCoordinate2D(latitude: 43.023116989061243, longitude: 12.50669899687793),
        CLLocationCoordinate2D(latitude: 43.027574988082051, longitude: 12.514260982282991),
        CLLocationCoordinate2D(latitude: 43.028101958334446, longitude: 12.517843994432582),
        CLLocationCoordinate2D(latitude: 43.02649296820163, longitude: 12.524928965728009),
        CLLocationCoordinate2D(latitude: 43.024193979799747, longitude: 12.529089993920422),
        CLLocationCoordinate2D(latitude: 43.019591979682446, longitude: 12.54285894626355),
        CLLocationCoordinate2D(latitude: 43.021245980635285, longitude: 12.552319935651582),
        CLLocationCoordinate2D(latitude: 43.005084916949272, longitude: 12.595531999272225),
        CLLocationCoordinate2D(latitude: 43.00370492041111, longitude: 12.596706974459039),
        CLLocationCoordinate2D(latitude: 43.008010955527418, longitude: 12.605812990247699),
        CLLocationCoordinate2D(latitude: 43.007158935070045, longitude: 12.611373963908164),
        CLLocationCoordinate2D(latitude: 42.999170981347568, longitude: 12.65118297484031),
        CLLocationCoordinate2D(latitude: 42.994525982066989, longitude: 12.656293924119382),
        CLLocationCoordinate2D(latitude: 42.991626933217049, longitude: 12.661877948013569),
        CLLocationCoordinate2D(latitude: 42.991762971505516, longitude: 12.662666936559305),
        CLLocationCoordinate2D(latitude: 42.988511966541409, longitude: 12.66586094458259),
        CLLocationCoordinate2D(latitude: 42.988476930186138, longitude: 12.666013998134531),
        CLLocationCoordinate2D(latitude: 42.989282933995128, longitude: 12.670437966629521),
        CLLocationCoordinate2D(latitude: 42.989301960915327, longitude: 12.670663942739054),
        CLLocationCoordinate2D(latitude: 42.986810943111777, longitude: 12.673606996581327),
        CLLocationCoordinate2D(latitude: 42.98652294091881, longitude: 12.673959958523966),
        CLLocationCoordinate2D(latitude: 42.971509946510189, longitude: 12.704167918466112),
        CLLocationCoordinate2D(latitude: 42.97338196076452, longitude: 12.709957969540255),
        CLLocationCoordinate2D(latitude: 42.979512987658367, longitude: 12.719161969776991),
        CLLocationCoordinate2D(latitude: 42.977933920919902, longitude: 12.721146972086586),
        CLLocationCoordinate2D(latitude: 42.98037498258055, longitude: 12.72374091966168),
        CLLocationCoordinate2D(latitude: 42.982031917199478, longitude: 12.728358929215119),
        CLLocationCoordinate2D(latitude: 42.984121944755323, longitude: 12.732720955445586),
        CLLocationCoordinate2D(latitude: 42.983804941177368, longitude: 12.733529976739902),
        CLLocationCoordinate2D(latitude: 42.984382957220078, longitude: 12.734715932219927),
        CLLocationCoordinate2D(latitude: 42.98360293731092, longitude: 12.740166935310697),
        CLLocationCoordinate2D(latitude: 42.984108952805386, longitude: 12.74046692362532),
        CLLocationCoordinate2D(latitude: 42.983034979552016, longitude: 12.752271996054901),
        CLLocationCoordinate2D(latitude: 42.982813948765397, longitude: 12.755623919133939),
        CLLocationCoordinate2D(latitude: 42.982701966539018, longitude: 12.757964984690318),
        CLLocationCoordinate2D(latitude: 42.982626948505626, longitude: 12.768165928490504),
        CLLocationCoordinate2D(latitude: 42.981243934482329, longitude: 12.772292926156069),
        CLLocationCoordinate2D(latitude: 42.9816019255668, longitude: 12.774266948172453),
        CLLocationCoordinate2D(latitude: 42.982096960768111, longitude: 12.774458977574113),
        CLLocationCoordinate2D(latitude: 42.981280982494347, longitude: 12.776513968775191),
        CLLocationCoordinate2D(latitude: 42.981008989736424, longitude: 12.784916994344684),
        CLLocationCoordinate2D(latitude: 42.983940979465835, longitude: 12.789451939237637),
        CLLocationCoordinate2D(latitude: 42.991097951307886, longitude: 12.798448990285067),
        CLLocationCoordinate2D(latitude: 42.991040954366319, longitude: 12.79862894974616),
        CLLocationCoordinate2D(latitude: 43.00107694230973, longitude: 12.845051952834496),
        CLLocationCoordinate2D(latitude: 42.99831292591989, longitude: 12.84802291841433),
        CLLocationCoordinate2D(latitude: 42.998187951743603, longitude: 12.848010932292794),
        CLLocationCoordinate2D(latitude: 43.024324988946312, longitude: 12.884194937740517),
        CLLocationCoordinate2D(latitude: 43.024379974231117, longitude: 12.884737917428083),
        CLLocationCoordinate2D(latitude: 43.027594937011607, longitude: 12.890767942390113),
        CLLocationCoordinate2D(latitude: 43.028602944687002, longitude: 12.8913179628764),
        CLLocationCoordinate2D(latitude: 43.028641920536757, longitude: 12.898727984376904),
        CLLocationCoordinate2D(latitude: 43.028726996853941, longitude: 12.899102990724884),
        CLLocationCoordinate2D(latitude: 43.040259992703788, longitude: 13.048392984328871),
        CLLocationCoordinate2D(latitude: 43.040639944374554, longitude: 13.061907965005815),
        CLLocationCoordinate2D(latitude: 43.043984994292259, longitude: 13.069382946255956),
        CLLocationCoordinate2D(latitude: 43.043519966304302, longitude: 13.069391998711382),
        CLLocationCoordinate2D(latitude: 43.030709987506278, longitude: 13.068781963798386),
        CLLocationCoordinate2D(latitude: 43.039951957762241, longitude: 13.077777925198404),
        CLLocationCoordinate2D(latitude: 43.034014971926808, longitude: 13.085371929473581),
        CLLocationCoordinate2D(latitude: 43.035903917625539, longitude: 13.086512957952579),
        CLLocationCoordinate2D(latitude: 43.03732599131763, longitude: 13.0864689529609),
        CLLocationCoordinate2D(latitude: 43.037567976862185, longitude: 13.088832984931969),
        CLLocationCoordinate2D(latitude: 43.037161957472563, longitude: 13.089057955213178),
        CLLocationCoordinate2D(latitude: 43.046033950522535, longitude: 13.100767976860709),
        CLLocationCoordinate2D(latitude: 43.043279992416494, longitude: 13.104679978709868),
        CLLocationCoordinate2D(latitude: 43.042588988319039, longitude: 13.107781953436302),
        CLLocationCoordinate2D(latitude: 43.042479939758778, longitude: 13.107893935662702),
        CLLocationCoordinate2D(latitude: 43.040521927177906, longitude: 13.109134960246536),
        CLLocationCoordinate2D(latitude: 43.040180951356888, longitude: 13.130576958211776),
        CLLocationCoordinate2D(latitude: 43.041426921263344, longitude: 13.13860397160488),
        CLLocationCoordinate2D(latitude: 43.041731938719735, longitude: 13.139257927690466),
        CLLocationCoordinate2D(latitude: 43.039921950548887, longitude: 13.144133932223582),
        CLLocationCoordinate2D(latitude: 43.038437934592366, longitude: 13.150831994868525),
        CLLocationCoordinate2D(latitude: 43.036557957530022, longitude: 13.158604952776471),
        CLLocationCoordinate2D(latitude: 43.037646934390068, longitude: 13.16385898114271),
        CLLocationCoordinate2D(latitude: 43.038720991462469, longitude: 13.165569979037514),
        CLLocationCoordinate2D(latitude: 43.033257918432341, longitude: 13.169255920958079),
        CLLocationCoordinate2D(latitude: 43.030833955854163, longitude: 13.171683990669379),
        CLLocationCoordinate2D(latitude: 43.030450986698263, longitude: 13.171655995112786),
        CLLocationCoordinate2D(latitude: 43.029984952881925, longitude: 13.174627966521001),
        CLLocationCoordinate2D(latitude: 43.028714926913381, longitude: 13.177966981469211),
        CLLocationCoordinate2D(latitude: 42.988923937082284, longitude: 13.233453923192201),
        CLLocationCoordinate2D(latitude: 42.988486988469944, longitude: 13.24096595245436),
        CLLocationCoordinate2D(latitude: 42.985953977331505, longitude: 13.247663931280329),
        CLLocationCoordinate2D(latitude: 42.986224964261048, longitude: 13.294570989276849),
        CLLocationCoordinate2D(latitude: 42.991648977622383, longitude: 13.295123943429246),
        CLLocationCoordinate2D(latitude: 42.984971953555927, longitude: 13.317197936893706),
        CLLocationCoordinate2D(latitude: 42.983968975022428, longitude: 13.322657992439957),
        CLLocationCoordinate2D(latitude: 42.970950957387693, longitude: 13.34476492678391),
        CLLocationCoordinate2D(latitude: 42.974981982260935, longitude: 13.348680951946591),
        CLLocationCoordinate2D(latitude: 42.973932987079024, longitude: 13.349957934895059),
        CLLocationCoordinate2D(latitude: 42.975070998072631, longitude: 13.351291998604154),
        CLLocationCoordinate2D(latitude: 42.96274792402982, longitude: 13.395222978059962),
        CLLocationCoordinate2D(latitude: 42.959397928789251, longitude: 13.413958962404621),
        CLLocationCoordinate2D(latitude: 42.959335986524813, longitude: 13.414132970714547),
        CLLocationCoordinate2D(latitude: 42.966026924550533, longitude: 13.445536944420439),
        CLLocationCoordinate2D(latitude: 42.966060955077403, longitude: 13.446050922723032),
        CLLocationCoordinate2D(latitude: 42.986272992566235, longitude: 13.547069955046084),
        CLLocationCoordinate2D(latitude: 42.932373918592923, longitude: 13.641341974409613),
        CLLocationCoordinate2D(latitude: 42.931291982531533, longitude: 13.639660983728163),
        CLLocationCoordinate2D(latitude: 42.930131927132607, longitude: 13.63751697671546),
        CLLocationCoordinate2D(latitude: 42.930000917986042, longitude: 13.637455956460315),
        CLLocationCoordinate2D(latitude: 42.902346923947334, longitude: 13.668444942140155),
        CLLocationCoordinate2D(latitude: 42.902225973084576, longitude: 13.669751932301949),
        CLLocationCoordinate2D(latitude: 42.902347929775708, longitude: 13.675300919840879),
        CLLocationCoordinate2D(latitude: 42.903058966621742, longitude: 13.67501593513299),
        CLLocationCoordinate2D(latitude: 42.890517963096492, longitude: 13.700773942680286),
        CLLocationCoordinate2D(latitude: 42.878417931497097, longitude: 13.710359990063694),
        CLLocationCoordinate2D(latitude: 42.878224980086088, longitude: 13.710533998373563),
        CLLocationCoordinate2D(latitude: 42.865227917209261, longitude: 13.724490956804829),
        CLLocationCoordinate2D(latitude: 42.865134961903095, longitude: 13.724697989813251),
        CLLocationCoordinate2D(latitude: 42.869190964847796, longitude: 13.749401973036441),
        CLLocationCoordinate2D(latitude: 42.86921996623277, longitude: 13.749653933045806),
        CLLocationCoordinate2D(latitude: 42.871065996587284, longitude: 13.759442990124114),
        CLLocationCoordinate2D(latitude: 42.869648952037089, longitude: 13.76038394257435),
        CLLocationCoordinate2D(latitude: 42.86817298270762, longitude: 13.769605963902933),
        CLLocationCoordinate2D(latitude: 42.868100982159383, longitude: 13.769701936694247),
        CLLocationCoordinate2D(latitude: 42.864687955006936, longitude: 13.771975947025254),
        CLLocationCoordinate2D(latitude: 42.864374974742539, longitude: 13.772185997518761),
        CLLocationCoordinate2D(latitude: 42.858809977769852, longitude: 13.775845955539495),
        CLLocationCoordinate2D(latitude: 42.858639992773533, longitude: 13.776435957703853),
        CLLocationCoordinate2D(latitude: 42.860348979011164, longitude: 13.781937922765962),
        CLLocationCoordinate2D(latitude: 42.85321396775543, longitude: 13.786447973406524),
        CLLocationCoordinate2D(latitude: 42.850331934168942, longitude: 13.805452933024043),
        CLLocationCoordinate2D(latitude: 42.851500958204262, longitude: 13.814654921604046),
        CLLocationCoordinate2D(latitude: 42.823742944747202, longitude: 13.838960932064566),
        CLLocationCoordinate2D(latitude: 42.815668992698185, longitude: 13.853103968746325),
        CLLocationCoordinate2D(latitude: 42.815697994083159, longitude: 13.853274959571024),
        CLLocationCoordinate2D(latitude: 42.813634956255548, longitude: 13.859249999248249),
        CLLocationCoordinate2D(latitude: 42.813435969874249, longitude: 13.859414955102693),
        CLLocationCoordinate2D(latitude: 42.810772955417633, longitude: 13.86586692507052),
        CLLocationCoordinate2D(latitude: 42.810565922409296, longitude: 13.86701692218594),
        CLLocationCoordinate2D(latitude: 42.806565994396813, longitude: 13.874298952024986),
        CLLocationCoordinate2D(latitude: 42.806286960840218, longitude: 13.874230974790265),
        CLLocationCoordinate2D(latitude: 42.801009966060512, longitude: 13.888883966461037),
        CLLocationCoordinate2D(latitude: 42.800298929214485, longitude: 13.889292919516862),
        CLLocationCoordinate2D(latitude: 42.786742961034179, longitude: 13.906246995065885),
        CLLocationCoordinate2D(latitude: 42.78656895272433, longitude: 13.906278930116969),
        CLLocationCoordinate2D(latitude: 42.786331996321671, longitude: 13.906432989497318),
        CLLocationCoordinate2D(latitude: 42.782960962504141, longitude: 13.905379971001622),
        CLLocationCoordinate2D(latitude: 42.781096994876854, longitude: 13.91428096543865),
        CLLocationCoordinate2D(latitude: 42.77654595673085, longitude: 13.920120972655752),
        CLLocationCoordinate2D(latitude: 42.772357938811176, longitude: 13.924595986941057),
        CLLocationCoordinate2D(latitude: 42.771580936387181, longitude: 13.927912957483898),
        CLLocationCoordinate2D(latitude: 42.749676927924156, longitude: 13.956795989991349),
        CLLocationCoordinate2D(latitude: 42.744547957554445, longitude: 13.963871992650439),
        CLLocationCoordinate2D(latitude: 42.737427949905388, longitude: 13.969904951278579),
        CLLocationCoordinate2D(latitude: 42.737452927976847, longitude: 13.970383977044946),
        CLLocationCoordinate2D(latitude: 42.69628697074949, longitude: 13.999991960357875),
        CLLocationCoordinate2D(latitude: 42.696096953004592, longitude: 14.000162951182631),
        CLLocationCoordinate2D(latitude: 42.665258925408125, longitude: 14.02358793980062),
        CLLocationCoordinate2D(latitude: 42.665036972612135, longitude: 14.023795978637395),
        CLLocationCoordinate2D(latitude: 42.616440961137414, longitude: 14.060759920175371),
        CLLocationCoordinate2D(latitude: 42.6163729839027, longitude: 14.060764949317303),
        CLLocationCoordinate2D(latitude: 42.596547938883305, longitude: 14.075743997021505),
        CLLocationCoordinate2D(latitude: 42.596419947221875, longitude: 14.076085978670989),
        CLLocationCoordinate2D(latitude: 42.541745966300368, longitude: 14.123687980259689),
        CLLocationCoordinate2D(latitude: 42.541401972994194, longitude: 14.123939940269082),
        CLLocationCoordinate2D(latitude: 42.532244995236397, longitude: 14.1310939784467),
        CLLocationCoordinate2D(latitude: 42.531955987215042, longitude: 14.131328923192655),
        CLLocationCoordinate2D(latitude: 42.523101931437857, longitude: 14.141936976029996),
        CLLocationCoordinate2D(latitude: 42.522898921743028, longitude: 14.14219295935294),
        CLLocationCoordinate2D(latitude: 42.519688988104448, longitude: 14.145932964548962),
        CLLocationCoordinate2D(latitude: 42.519603995606303, longitude: 14.146065985352294),
        CLLocationCoordinate2D(latitude: 42.516161967068903, longitude: 14.150337989942727),
        CLLocationCoordinate2D(latitude: 42.516074962913997, longitude: 14.15047696189734),
        CLLocationCoordinate2D(latitude: 42.51594093628227, longitude: 14.150681983248973),
        CLLocationCoordinate2D(latitude: 42.515811938792467, longitude: 14.150775944383525),
        CLLocationCoordinate2D(latitude: 42.503682989627123, longitude: 14.165499930774217),
        CLLocationCoordinate2D(latitude: 42.504918985068784, longitude: 14.167632957493822),
        CLLocationCoordinate2D(latitude: 42.486461950466037, longitude: 14.190506919797173),
        CLLocationCoordinate2D(latitude: 42.4856539350003, longitude: 14.193090976726523),
        CLLocationCoordinate2D(latitude: 42.485966999083772, longitude: 14.193481992509561),
        CLLocationCoordinate2D(latitude: 42.466995986178524, longitude: 14.222154974523505),
        CLLocationCoordinate2D(latitude: 42.464814931154237, longitude: 14.226867951039878),
        CLLocationCoordinate2D(latitude: 42.462500939145677, longitude: 14.229365925823657),
        CLLocationCoordinate2D(latitude: 42.462335983291247, longitude: 14.229489977990625),
        CLLocationCoordinate2D(latitude: 42.462342940270901, longitude: 14.229554937740204),
        CLLocationCoordinate2D(latitude: 42.459487980231636, longitude: 14.232871992102105),
        CLLocationCoordinate2D(latitude: 42.448321944102638, longitude: 14.248097970673825),
        CLLocationCoordinate2D(latitude: 42.444862984120832, longitude: 14.252779934148521),
        CLLocationCoordinate2D(latitude: 42.437109975144253, longitude: 14.263728962806908),
        CLLocationCoordinate2D(latitude: 42.436996987089522, longitude: 14.263884950024988),
        CLLocationCoordinate2D(latitude: 42.436837982386358, longitude: 14.264129953054749),
        CLLocationCoordinate2D(latitude: 42.425484945997603, longitude: 14.281987933042018),
        CLLocationCoordinate2D(latitude: 42.42539391852916, longitude: 14.282135957452056),
        CLLocationCoordinate2D(latitude: 42.407592935487614, longitude: 14.314592949653672),
        CLLocationCoordinate2D(latitude: 42.407548930495963, longitude: 14.314683977122115),
        CLLocationCoordinate2D(latitude: 42.40435098297894, longitude: 14.31997597550972),
        CLLocationCoordinate2D(latitude: 42.40251995623111, longitude: 14.320722970720539),
        CLLocationCoordinate2D(latitude: 42.402329938486211, longitude: 14.32053295297564),
        CLLocationCoordinate2D(latitude: 42.255621990188949, longitude: 14.504347921932236),
        CLLocationCoordinate2D(latitude: 42.255495926365256, longitude: 14.50459393079035),
        CLLocationCoordinate2D(latitude: 42.194441976025708, longitude: 14.627069964685262),
        CLLocationCoordinate2D(latitude: 42.194544989615672, longitude: 14.627363918029545),
        CLLocationCoordinate2D(latitude: 42.195944935083382, longitude: 14.62947498416284),
        CLLocationCoordinate2D(latitude: 42.192303920164704, longitude: 14.642636919078086),
        CLLocationCoordinate2D(latitude: 42.190224956721053, longitude: 14.64467699049149),
        CLLocationCoordinate2D(latitude: 42.189725982025259, longitude: 14.648290931863812),
        CLLocationCoordinate2D(latitude: 42.189462957903743, longitude: 14.649100958986452),
        CLLocationCoordinate2D(latitude: 42.189467987045632, longitude: 14.648054981289476),
        CLLocationCoordinate2D(latitude: 42.186339944601045, longitude: 14.648576922400053),
        CLLocationCoordinate2D(latitude: 42.166507942602045, longitude: 14.682434949717106),
        CLLocationCoordinate2D(latitude: 42.166130924597383, longitude: 14.682664949140218),
        CLLocationCoordinate2D(latitude: 42.165561961010091, longitude: 14.682676935261696),
        CLLocationCoordinate2D(latitude: 42.156600952148438, longitude: 14.687453949518385),
        CLLocationCoordinate2D(latitude: 42.138653956353672, longitude: 14.692480995946681),
        CLLocationCoordinate2D(latitude: 42.137366998940699, longitude: 14.697804929385399),
        CLLocationCoordinate2D(latitude: 42.128735985606902, longitude: 14.701138999010738),
        CLLocationCoordinate2D(latitude: 42.128657950088382, longitude: 14.701195995952304),
        CLLocationCoordinate2D(latitude: 42.115399958565824, longitude: 14.708757981357365),
        CLLocationCoordinate2D(latitude: 42.115247994661317, longitude: 14.708866946098624),
        CLLocationCoordinate2D(latitude: 42.115213964134455, longitude: 14.708990998265563),
        CLLocationCoordinate2D(latitude: 42.115053953602903, longitude: 14.709033997428833),
        CLLocationCoordinate2D(latitude: 42.114820936694741, longitude: 14.710602922064851),
        CLLocationCoordinate2D(latitude: 42.114720940589905, longitude: 14.710679951755026),
        CLLocationCoordinate2D(latitude: 42.112145936116576, longitude: 14.71064692705653),
        CLLocationCoordinate2D(latitude: 42.111990954726927, longitude: 14.711369950024277),
        CLLocationCoordinate2D(latitude: 41.757702995091677, longitude: 15.478760929656858),
        CLLocationCoordinate2D(latitude: 41.715620979666696, longitude: 15.515104945636182),
        CLLocationCoordinate2D(latitude: 41.715693986043327, longitude: 15.516066936663378),
        CLLocationCoordinate2D(latitude: 41.598938936367624, longitude: 15.741502916380199),
        CLLocationCoordinate2D(latitude: 41.571660954505205, longitude: 15.758050972539507),
        CLLocationCoordinate2D(latitude: 41.571368928998716, longitude: 15.758151974472725),
        CLLocationCoordinate2D(latitude: 41.491832965984933, longitude: 15.846094986388039),
        CLLocationCoordinate2D(latitude: 41.491506993770599, longitude: 15.846473932230481),
        CLLocationCoordinate2D(latitude: 41.431759949773536, longitude: 15.91396694442119),
        CLLocationCoordinate2D(latitude: 41.427495991811149, longitude: 15.913420947248483),
        CLLocationCoordinate2D(latitude: 41.418668925762169, longitude: 15.934999989330578),
        CLLocationCoordinate2D(latitude: 41.358951972797513, longitude: 16.081863924880025),
        CLLocationCoordinate2D(latitude: 41.359003940597169, longitude: 16.08198697121864),
        CLLocationCoordinate2D(latitude: 41.359261935576797, longitude: 16.082171959821636),
        CLLocationCoordinate2D(latitude: 41.356987925246344, longitude: 16.092285983285933),
        CLLocationCoordinate2D(latitude: 41.356816934421659, longitude: 16.09223996663755),
        CLLocationCoordinate2D(latitude: 41.354448962956681, longitude: 16.102463960671457),
        CLLocationCoordinate2D(latitude: 41.354034980759018, longitude: 16.102735953429402),
        CLLocationCoordinate2D(latitude: 41.319044977426536, longitude: 16.281965937531112),
        CLLocationCoordinate2D(latitude: 41.319861961528652, longitude: 16.283356998181745),
        CLLocationCoordinate2D(latitude: 41.318929977715001, longitude: 16.288761984624188),
        CLLocationCoordinate2D(latitude: 41.318844985216863, longitude: 16.289048980988809),
        CLLocationCoordinate2D(latitude: 41.31810897029937, longitude: 16.29192497960571),
        CLLocationCoordinate2D(latitude: 41.318054990842931, longitude: 16.292308954590084),
        CLLocationCoordinate2D(latitude: 41.280744960531585, longitude: 16.410833926967115),
        CLLocationCoordinate2D(latitude: 41.275807935744531, longitude: 16.421088934042757),
        CLLocationCoordinate2D(latitude: 41.23344495892524, longitude: 16.511795962348515),
        CLLocationCoordinate2D(latitude: 41.2333309650421, longitude: 16.512196952596383),
        CLLocationCoordinate2D(latitude: 41.232639960944653, longitude: 16.516278939441833),
        CLLocationCoordinate2D(latitude: 41.232610959559679, longitude: 16.516464933873294),
        CLLocationCoordinate2D(latitude: 41.21099294163286, longitude: 16.576298982039162),
        CLLocationCoordinate2D(latitude: 41.210793955251575, longitude: 16.57653895592702),
        CLLocationCoordinate2D(latitude: 41.145831942558281, longitude: 16.778593952017502),
        CLLocationCoordinate2D(latitude: 41.145419972017407, longitude: 16.778630916210489),
        CLLocationCoordinate2D(latitude: 41.145144961774342, longitude: 16.778645919817194),
        CLLocationCoordinate2D(latitude: 41.137298997491591, longitude: 16.778580960067586),
        CLLocationCoordinate2D(latitude: 41.137012923136353, longitude: 16.778519939812526),
        CLLocationCoordinate2D(latitude: 41.134707983583198, longitude: 16.7789919247802),
        CLLocationCoordinate2D(latitude: 41.134457951411605, longitude: 16.77914296667538),
        CLLocationCoordinate2D(latitude: 41.128362966701388, longitude: 16.796700958348055),
        CLLocationCoordinate2D(latitude: 41.127751925960183, longitude: 16.797016956097707),
        CLLocationCoordinate2D(latitude: 41.124125998467193, longitude: 16.82659493219731),
        CLLocationCoordinate2D(latitude: 41.117790956050158, longitude: 16.839929953413076),
        CLLocationCoordinate2D(latitude: 41.118953945115202, longitude: 16.844034990492247),
        CLLocationCoordinate2D(latitude: 41.11897096037864, longitude: 16.844217967438567),
        CLLocationCoordinate2D(latitude: 41.120457993820317, longitude: 16.848164921823951),
        CLLocationCoordinate2D(latitude: 41.120518930256367, longitude: 16.848303977597595),
        CLLocationCoordinate2D(latitude: 41.124006975442164, longitude: 16.857126936516067),
        CLLocationCoordinate2D(latitude: 41.123342961072922, longitude: 16.857174964821269),
        CLLocationCoordinate2D(latitude: 41.123952995985732, longitude: 16.868148971551136),
        CLLocationCoordinate2D(latitude: 41.123678991571069, longitude: 16.868176967107729)
]




