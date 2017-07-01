
import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
  let coordinate: CLLocationCoordinate2D
  let title: String?
    var subtitle: String?
  
    init(location: CLLocationCoordinate2D, title: String, type : String) {
    self.coordinate = location
    self.title = title
    self.subtitle = type
    super.init()
  }
}
