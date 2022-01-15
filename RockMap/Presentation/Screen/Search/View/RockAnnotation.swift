import MapKit

class RockAnnotation: NSObject, MKAnnotation {
    let rock: Entity.Rock
    let coordinate: CLLocationCoordinate2D
    var title: String?

    init(rock: Entity.Rock) {
        self.rock = rock
        self.coordinate = .init(
            latitude: rock.location.latitude,
            longitude: rock.location.longitude
        )
        self.title = rock.name
    }
}
