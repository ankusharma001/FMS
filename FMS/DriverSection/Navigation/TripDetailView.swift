//
//  TripDetailView.swift
//  Navigation Screen
//
//  Created by Kushgra Grover on 20/02/25.
//

import SwiftUI
import MapKit
import SwiftSMTP
import FirebaseAuth
import FirebaseFirestore
import CoreLocation
class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    



    // Fetch the currently logged-in driver using userUUID
    func getCurrentDriver(completion: @escaping (Driver?) -> Void) {
        // Retrieve the userUUID from UserDefaults
        guard let userUUID = UserDefaults.standard.string(forKey: "loggedInUserUUID") else {
            print("Error: No logged-in user UUID found.")
            completion(nil)
            return
        }
        
        print("Looking up driver with UUID: \(userUUID)")
        
        // First, check if this user is a driver
        db.collection("users").document(userUUID).getDocument { snapshot, error in
            if let error = error {
                print("Error checking user type: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let userData = snapshot?.data(),
                  let roleString = userData["role"] as? String,
                  roleString == Role.driver.rawValue else {
                print("Error: User is not a driver or role information is missing.")
                completion(nil)
                return
            }
            
            // Now fetch from drivers collection
            self.db.collection("drivers").document(userUUID).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching driver data: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("Error: No driver data found for UUID: \(userUUID)")
                    
                    // FALLBACK: If no dedicated driver document, use basic user info
                    let name = userData["name"] as? String ?? "Unknown"
                    let email = userData["email"] as? String ?? "Unknown"
                    let phone = userData["phone"] as? String ?? "Unknown"
                    
                    let driver = Driver(
                        name: name,
                        email: email,
                        phone: phone,
                        experience: .lessThanOne,
                        license: "Not provided",
                        geoPreference: .hilly,
                        vehiclePreference: .car,
                        status: true
                    )
                    
                    completion(driver)
                    return
                }
                
                // Parse driver data as before
                let name = data["name"] as? String ?? "Unknown"
                let email = data["email"] as? String ?? "Unknown"
                let phone = data["phone"] as? String ?? "Unknown"
                let license = data["license"] as? String ?? "Unknown"
                
                // Extract enum values dynamically
                let experience = Experience(rawValue: data["experience"] as? String ?? "") ?? .lessThanOne
                let geoPreference = GeoPreference(rawValue: data["geoPreference"] as? String ?? "") ?? .hilly
                let vehiclePreference = VehicleType(rawValue: data["vehiclePreference"] as? String ?? "") ?? .car
                
                let driver = Driver(
                    name: name,
                    email: email,
                    phone: phone,
                    experience: experience,
                    license: license,
                    geoPreference: geoPreference,
                    vehiclePreference: vehiclePreference,
                    status: data["status"] as? Bool ?? true
                )
                
                completion(driver)
            }
        }
    }

    // Fetch all fleet managers' emails
    func getFleetManagersEmails(completion: @escaping ([String]) -> Void) {
        db.collection("users").whereField("role", isEqualTo: Role.fleet.rawValue).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching fleet managers: \(error.localizedDescription)")
                completion([])
                return
            }

            let emails = snapshot?.documents.compactMap { $0.data()["email"] as? String } ?? []
            completion(emails)
        }
    }

}

// MARK: - Trip Details Data Model
struct TripDetails {
    let startLocation: String
    let endLocation: String
    let tripDate: String
    let distance: String
    let vehicleName: String
    let vehicleModel: String
    let driverName: String
}

struct TripDetailView: View {
    @State private var emailSent = false
    @State private var emailStatus = ""
    @State var startLocation: String
    @State var endLocation: String
    @State var distance: String
    @State var vehicleModel: String
    @State var driverName: String
    @State var tripDate: String
    @State var vehicleType: String
    @State var vehicleID: String
    @State var tripID: String   // ✅ Added trip ID
      @State var userID: String
    @State private var navigateToHome = false
    
    
    let trip = TripDetails(
        startLocation: "infosys",
        endLocation: "Rajpura",
        tripDate: "Feb 15, 2024",
        distance: "8.5 miles",
        vehicleName: "Ford Transit",
        vehicleModel: "Model XZ2025",
        driverName: "John Smith"
    )
    func sendSOSMail(fleetManagerEmail: String, driverName: String, phoneNumber: String, completion: @escaping (Bool, String) -> Void) {
        print("Configuring SMTP for email to: \(fleetManagerEmail)")
        
        let smtp = SMTP(
            hostname: "smtp.gmail.com",
            email: "sohamchakraborty18.edu@gmail.com",
            password: "nvyanzllnqpudxha",  // Consider using a more secure approach than hardcoding
            port: 465,
            tlsMode: .requireTLS
        )
        
        let from = Mail.User(name: "Team 5", email: "sohamchakraborty18.edu@gmail.com")
        let to = Mail.User(name: "Fleet Manager", email: fleetManagerEmail)
        
        let mail = Mail(
            from: from,
            to: [to],
            subject: "🚨 SOS Alert - Immediate Assistance Required",
            text: """
            🚨 **Emergency Alert from Driver** 🚨
            
            Driver Name: \(driverName)  
            Contact Number: \(phoneNumber)  
            
            Please respond immediately.
            
            This is an automated emergency alert from the Fleet Management System.
            """
        )
        
        print("Attempting to send email via SMTP...")
        smtp.send(mail) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("SMTP Error: \(error.localizedDescription)")
                    completion(false, "Error: \(error.localizedDescription)")
                } else {
                    print("Email sent successfully to \(fleetManagerEmail)")
                    completion(true, "Successfully sent to \(fleetManagerEmail).")
                }
            }
        }
    }
    
    var body: some View {
        
        ScrollView {  // 🛠️ Makes screen scrollable
            VStack(spacing: 0) {
                // **Real Map with Route**
                SimulatedRouteMapView(startAddress: startLocation, endAddress: endLocation)
                    .frame(height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // **Trip Status**
                Text("In Progress")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.08))
                
                // **Trip Details Section**
                VStack(alignment: .leading, spacing: 12) {
                    tripInfoRow(icon: "location", title: "Start Location", value: startLocation)
                    tripInfoRow(icon: "flag", title: "End Location", value: endLocation)
                    
                    // **Grid Layout for Detail Boxes**
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        infoBox(icon: "calendar", title: "Trip Date", value: tripDate)
                        infoBox(icon: "map", title: "Distance", value: distance)
                        vehicleBox(icon: "truck.box", vehicleName: vehicleModel, model: vehicleType)  // 🚛 Truck Icon
                        infoBox(icon: "person", title: "Driver", value: driverName)
                    }
                    .padding(.top, 10)
                }
                .padding()
                
                Spacer()
                NavigationStack{
                HStack {
                    Button(action: {
                        print("End Trip button tapped")
                        navigateToHome = true
                        endTrip(tripID: tripID, driverID: userID, vehicleID: vehicleID)
                        AssignMaintenance.shared.handleEndTrip(for: vehicleID){
                            result in switch result{
                            case .success(let message):
                                print(message)
                            case .failure(let error):
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                        // Add logic for starting trip
                        
                    }) {
                        Text("End Trip")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.leading,7)
                    }
                    .navigationDestination(isPresented: $navigateToHome){
                        MainTabView()
                            .navigationBarBackButtonHidden(true) // Hides the back button
                                   .interactiveDismissDisabled(true)
                    }
                    }
                    Button(action: {
                        print("SOS button tapped - Starting process")
                        
                        // Check if UUID exists in UserDefaults
                        let storedUUID = UserDefaults.standard.string(forKey: "loggedInUserUUID")
                        print("Retrieved UUID from UserDefaults: \(storedUUID ?? "None")")
                        
                        FirestoreManager.shared.getCurrentDriver { driver in
                            print("Driver fetch completed")
                            
                            guard let driver = driver else {
                                print("Error: Driver details not found")
                                emailStatus = "Error: Driver details not found."
                                emailSent = true
                                return
                            }
                            
                            print("Driver details retrieved - Name: \(driver.name), License: \(driver.license)")
                            
                            FirestoreManager.shared.getFleetManagersEmails { fleetManagerEmails in
                                print("Fleet manager emails retrieved: \(fleetManagerEmails.count)")
                                
                                if fleetManagerEmails.isEmpty {
                                    print("Error: No fleet managers found")
                                    emailStatus = "Error: No fleet managers found."
                                    emailSent = true
                                    return
                                }
                                
                                var successCount = 0
                                var failureCount = 0
                                let group = DispatchGroup()
                                
                                for email in fleetManagerEmails {
                                    print("Attempting to send email to: \(email)")
                                    group.enter()
                                    sendSOSMail(
                                        fleetManagerEmail: email,
                                        driverName: driver.name,
                                        phoneNumber: driver.phone
                                    ) { success, message in
                                        DispatchQueue.main.async {
                                            print("Email to \(email): \(success ? "Success" : "Failed") - \(message)")
                                            if success {
                                                successCount += 1
                                            } else {
                                                failureCount += 1
                                            }
                                            group.leave()
                                        }
                                    }
                                }
                                
                                group.notify(queue: .main) {
                                    if failureCount == 0 {
                                        emailStatus = "SOS sent successfully to Fleet Manager."
                                    } else {
                                        emailStatus = "SOS sent to Fleet manager. Failed to send to \(failureCount)."
                                    }
                                    emailSent = true
                                }
                            }
                        }
                    }) {
                        Text("SOS")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $emailSent) {
                        Alert(
                            title: Text("Email Status"),
                            message: Text(emailStatus),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .padding()
                }
                .navigationBarTitle("Current Trip", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .background(Color(.systemGroupedBackground))
            }}
    }


    func endTrip(tripID: String, driverID: String, vehicleID: String) {
        let db = Firestore.firestore()
        
        guard !tripID.isEmpty, !driverID.isEmpty, !vehicleID.isEmpty else {
            print("❌ Error: Missing tripID, driverID, or vehicleID")
            return
        }

        print("🔍 Ending trip: \(tripID) | Driver: \(driverID) | Vehicle: \(vehicleID)")

        let dispatchGroup = DispatchGroup()
        
        // Step 1: Update Trip Status
        dispatchGroup.enter()
        db.collection("trips").document(tripID).updateData(["TripStatus": "Completed"]) { error in
            if let error = error {
                print("❌ Error updating trip status: \(error.localizedDescription)")
            } else {
                print("✅ Trip status updated to 'Completed'")
            }
            dispatchGroup.leave()
        }

        // Step 2: Update Driver Status to Available (Boolean)
        dispatchGroup.enter()
        db.collection("users").document(driverID).updateData(["status": true]) { error in
            if let error = error {
                print("❌ Error updating driver status: \(error.localizedDescription)")
            } else {
                print("✅ Driver status updated to 'Available'")
            }
            dispatchGroup.leave()
        }

        // Step 3: Update Vehicle Status to Available (Boolean)
        dispatchGroup.enter()
        db.collection("vehicles").document(vehicleID).updateData(["status": true]) { error in
            if let error = error {
                print("❌ Error updating vehicle status: \(error.localizedDescription)")
            } else {
                print("✅ Vehicle status updated to 'Available'")
            }
            dispatchGroup.leave()
        }

        // Notify when all updates are done
        dispatchGroup.notify(queue: .main) {
            print("🚀 All trip-related updates completed successfully!")
        }
    }





    
    // **Row for Start & End Location**
    private func tripInfoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.body)
                    .bold()
            }
            Spacer()
        }
    }
    
    // **Standard Box for Trip Info (Date, Distance, Driver)**
    private func infoBox(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(value)
                        .font(.body)
                        .bold()
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 3)
    }
    
    // **Vehicle Box with Name and Model**
    private func vehicleBox(icon: String, vehicleName: String, model: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vehicle")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(vehicleName)
                        .font(.body)
                        .bold()
                    Text(model) // 🚘 Model Number
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}
    

    
        
    
class DriverSimulator: ObservableObject {
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var heading: CLLocationDirection = 0
    
    private var timer: Timer?
    private var routeCoordinates: [CLLocationCoordinate2D] = []
    private var currentIndex = 0
    
    func startSimulation(with route: MKRoute) {
        // Extract coordinates from the route polyline
        let points = route.polyline.points()
        let pointCount = route.polyline.pointCount
        
        routeCoordinates = (0..<pointCount).map {
            points[$0].coordinate
        }
        
        currentIndex = 0
        
        // Start timer to move along the route
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.currentIndex < self.routeCoordinates.count - 1 {
                // Move to next point
                self.currentLocation = self.routeCoordinates[self.currentIndex]
                
                // Calculate heading (direction) between current and next point
                if self.currentIndex < self.routeCoordinates.count - 1 {
                    let nextPoint = self.routeCoordinates[self.currentIndex + 1]
                    self.heading = self.calculateHeading(from: self.routeCoordinates[self.currentIndex], to: nextPoint)
                }
                
                self.currentIndex += 1
            } else {
                // Reached end of route, restart simulation
                self.currentIndex = 0
            }
        }
        
        // Trigger first movement
        if !routeCoordinates.isEmpty {
            currentLocation = routeCoordinates[0]
        }
    }
    
    func stopSimulation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func calculateHeading(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDirection {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var heading = atan2(y, x) * 180 / .pi
        if heading < 0 {
            heading += 360
        }
        
        return heading
    }
    
    deinit {
        stopSimulation()
    }
}

// **Simulated Map View with Route**
struct SimulatedRouteMapView: UIViewRepresentable {
    let startAddress: String
    let endAddress: String
    @StateObject private var simulator = DriverSimulator()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false // Hide system user location
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        
        fetchCoordinates(for: startAddress, endAddress, on: mapView)
        return mapView
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update map when simulated location changes
        if let location = simulator.currentLocation {
            // Update or create driver annotation
            if let driverAnnotation = uiView.annotations.first(where: { $0.title == "Driver" }) as? DriverAnnotation {
                driverAnnotation.coordinate = location
                driverAnnotation.heading = simulator.heading
                // Force update by removing and re-adding
                uiView.removeAnnotation(driverAnnotation)
                uiView.addAnnotation(driverAnnotation)
            } else {
                // Add driver annotation if it doesn't exist
                let annotation = DriverAnnotation()
                annotation.coordinate = location
                annotation.title = "Driver"
                annotation.heading = simulator.heading
                uiView.addAnnotation(annotation)
            }
            
            // Center map on driver location
            let region = MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            uiView.setRegion(region, animated: true)
        }
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(simulator: simulator)
    }
    private func fetchCoordinates(for start: String, _ end: String, on mapView: MKMapView) {
            let geocoder = CLGeocoder()

            geocoder.geocodeAddressString(start) { startPlacemarks, _ in
                geocoder.geocodeAddressString(end) { endPlacemarks, _ in
                    if let startLocation = startPlacemarks?.first?.location,
                       let endLocation = endPlacemarks?.first?.location {

                        let startCoordinate = startLocation.coordinate
                        let endCoordinate = endLocation.coordinate

                        let startAnnotation = MKPointAnnotation()
                        startAnnotation.coordinate = startCoordinate
                        startAnnotation.title = "Start"

                        let endAnnotation = MKPointAnnotation()
                        endAnnotation.coordinate = endCoordinate
                        endAnnotation.title = "Destination"

                        mapView.addAnnotations([startAnnotation, endAnnotation])

                        let request = MKDirections.Request()
                        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
                        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinate))
                        request.transportType = .automobile

                        let directions = MKDirections(request: request)
                        directions.calculate { response, _ in
                            if let route = response?.routes.first {
                                mapView.addOverlay(route.polyline)
                                mapView.setVisibleMapRect(
                                                                route.polyline.boundingMapRect,
                                                                edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
                                                                animated: true
                                                            )
                                                            
                                                            // Start simulation with the calculated route
                                                            self.simulator.startSimulation(with: route)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Custom annotation for driver that shows heading
                                    class DriverAnnotation: MKPointAnnotation {
                                        var heading: CLLocationDirection = 0
                                    }

                                    class Coordinator: NSObject, MKMapViewDelegate {
                                        var simulator: DriverSimulator
                                        
                                        init(simulator: DriverSimulator) {
                                            self.simulator = simulator
                                            super.init()
                                        }
                                        
                                        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                                            if let polyline = overlay as? MKPolyline {
                                                let renderer = MKPolylineRenderer(polyline: polyline)
                                                renderer.strokeColor = .blue
                                                renderer.lineWidth = 5
                                                return renderer
                                            }
                                            return MKOverlayRenderer()
                                        }
                                        
                                        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
                                            if annotation is MKUserLocation {
                                                return nil
                                            }
                                            
                                            if let driverAnnotation = annotation as? DriverAnnotation {
                                                let identifier = "DriverPin"
                                                var view: MKAnnotationView
                                                
                                                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                                                    view = dequeuedView
                                                    view.annotation = annotation
                                                } else {
                                                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                                                }
                                                
                                                view.image = UIImage(systemName: "car.fill")?.withTintColor(.blue, renderingMode: .alwaysOriginal)
                                                view.canShowCallout = true
                                                
                                                // Apply rotation based on heading
                                                let rotation = CGFloat(driverAnnotation.heading) * .pi / 180.0
                                                view.transform = CGAffineTransform(rotationAngle: rotation)
                                                
                                                return view
                                            } else if annotation.title == "Start" {
                                                let identifier = "StartPin"
                                                var view: MKAnnotationView
                                                
                                                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                                                    view = dequeuedView
                                                    view.annotation = annotation
                                                } else {
                                                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                                                }
                                                
                                                view.image = UIImage(systemName: "mappin.circle.fill")?.withTintColor(.green, renderingMode: .alwaysOriginal)
                                                view.canShowCallout = true
                                                
                                                return view
                                            } else if annotation.title == "Destination" {
                                                let identifier = "EndPin"
                                                var view: MKAnnotationView
                                                
                                                if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                                                    view = dequeuedView
                                                    view.annotation = annotation
                                                } else {
                                                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                                                }
                                                
                                                view.image = UIImage(systemName: "mappin.circle.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
                                                view.canShowCallout = true
                                                
                                                return view
                                            }
                                            
                                            return nil
                                        }
                                    }
                                }
struct TripDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailView(
            startLocation: "bathinda",
            endLocation: "Rajpura, Punjab",
            distance: "8.5 miles",
            vehicleModel: "Ford Transit",
            driverName: "John Smith",
            tripDate: "Feb 25, 2025",
            vehicleType: "Model XZ2025",
            vehicleID: "12322564245",
            tripID: "SAMPLE_TRIP_ID",  // Replace with actual trip ID
            userID: "SAMPLE_USER_ID"   // Replace with actual user ID
        )

    }
}
