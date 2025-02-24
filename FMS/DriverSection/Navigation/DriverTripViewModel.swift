//import UIKit
//import MapKit
//import CoreLocation
//import SwiftUI
//
//class DriverMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
//    
//    // UI Components
//    var mapView = MKMapView()
//    let locationManager = CLLocationManager()
//    
//    // Dummy trip data
//    var trip: Trip = Trip(
//        tripDate: Date(),
//        startLocation: "Siliguri",  // Dummy Start Address
//        endLocation: "Rajpura",      // Dummy Destination Address
//        distance: 560.0,
//        estimatedTime: 6.0,
//        assignedDriver: nil,
//        TripStatus: .scheduled,
//        assignedVehicle: nil
//    )
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupMap()
//        checkLocationServices()
//        
//        // Convert addresses to coordinates and draw route
//        getCoordinates(for: trip.startLocation) { startCoordinate in
//            self.getCoordinates(for: self.trip.endLocation) { endCoordinate in
//                if let start = startCoordinate, let end = endCoordinate {
//                    self.addAnnotations(start: start, end: end)
//                    self.drawRoute(from: start, to: end)
//                }
//            }
//        }
//    }
//    
//    // Setup map view
//    func setupMap() {
//        mapView.frame = view.bounds
//        mapView.delegate = self
//        view.addSubview(mapView)
//    }
//    
//    // Request location permissions
//    func checkLocationServices() {
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.requestWhenInUseAuthorization()
//            locationManager.startUpdatingLocation()
//        } else {
//            print("Location services are disabled")
//        }
//    }
//    
//    // Live tracking of driver's current location
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
//        mapView.setRegion(region, animated: true)
//    }
//
//    // Convert address to coordinates
//    func getCoordinates(for address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(address) { placemarks, error in
//            if let location = placemarks?.first?.location {
//                completion(location.coordinate)
//            } else {
//                print("Geocoding failed for \(address): \(error?.localizedDescription ?? "Unknown error")")
//                completion(nil)
//            }
//        }
//    }
//
//    // Add markers (annotations) on the map
//    // Add markers (annotations) on the map and adjust the visible region
//    func addAnnotations(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
//        let startAnnotation = MKPointAnnotation()
//        startAnnotation.coordinate = start
//        startAnnotation.title = "Start: \(trip.startLocation)"
//        
//        let endAnnotation = MKPointAnnotation()
//        endAnnotation.coordinate = end
//        endAnnotation.title = "Destination: \(trip.endLocation)"
//        
//        mapView.addAnnotations([startAnnotation, endAnnotation])
//
//        // Set visible region to include both start and end points
//        let coordinates = [start, end]
//        var zoomRect = MKMapRect.null
//        for coordinate in coordinates {
//            let point = MKMapPoint(coordinate)
//            let rect = MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1)
//            zoomRect = zoomRect.union(rect)
//        }
//        mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
//    }
//
//
//    // Draw route between start and end points
//    func drawRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
//        let startPlacemark = MKPlacemark(coordinate: start)
//        let endPlacemark = MKPlacemark(coordinate: end)
//        
//        let directionRequest = MKDirections.Request()
//        directionRequest.source = MKMapItem(placemark: startPlacemark)
//        directionRequest.destination = MKMapItem(placemark: endPlacemark)
//        directionRequest.transportType = .automobile
//        
//        let directions = MKDirections(request: directionRequest)
//        directions.calculate { response, error in
//            guard let route = response?.routes.first else { return }
//            self.mapView.addOverlay(route.polyline)
//        }
//    }
//
//    // Render route polyline
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if let polyline = overlay as? MKPolyline {
//            let renderer = MKPolylineRenderer(polyline: polyline)
//            renderer.strokeColor = .blue
//            renderer.lineWidth = 5
//            return renderer
//        }
//        return MKOverlayRenderer()
//    }
//}
//
//// MARK: - SwiftUI Preview for Xcode
//#Preview {
//    UIViewControllerPreview {
//        return DriverMapViewController()
//    }
//}
//
//// SwiftUI Helper for UIViewController
//struct UIViewControllerPreview<T: UIViewController>: UIViewControllerRepresentable {
//    let viewController: T
//
//    init(_ builder: @escaping () -> T) {
//        viewController = builder()
//    }
//
//    func makeUIViewController(context: Context) -> T {
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: T, context: Context) { }
//}
