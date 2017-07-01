
import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
  let coordinate: CLLocationCoordinate2D
  let title: String?
    var subtitle: String?
    var type : Int = 0
  
    init(location: CLLocationCoordinate2D, title: String, type : String) {
    self.coordinate = location
    self.title = title
    self.subtitle = type
    super.init()
  }
}

class CarAnnotation: NSObject, MKAnnotation {
    var car : Car
    var coordinate: CLLocationCoordinate2D
    let title: String?
    var subtitle: String?
    
    init(_ car : Car) {
        self.car=car
        coordinate=car.position
        title=car.name
        var passeggeri = ""
        for elem in car.passeggeri {
            passeggeri.append(elem.name)
        }
        subtitle=passeggeri
        super.init()
    }
}
