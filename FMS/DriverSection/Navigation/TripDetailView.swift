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
                RouteMapView(startAddress: startLocation, endAddress: endLocation)
                    .frame(height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // **Trip Status**
                Text("In Progress")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                
                // **Trip Details Section**
                VStack(alignment: .leading, spacing: 12) {
                    tripInfoRow(icon: "mappin.circle.fill", title: "Start Location", value: startLocation)
                    tripInfoRow(icon: "location.fill", title: "End Location", value: endLocation)
                    
                    // **Grid Layout for Detail Boxes**
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        infoBox(icon: "calendar", title: "Trip Date", value: tripDate)
                        infoBox(icon: "map.fill", title: "Distance", value: distance)
                        vehicleBox(icon: "truck.box.fill", vehicleName: vehicleModel, model: vehicleType)  // 🚛 Truck Icon
                        infoBox(icon: "person.fill", title: "Driver", value: driverName)
                    }
                    .padding(.top, 10)
                }
                .padding()
                
                Spacer()
                HStack {
                    Button(action: {
                        print("End Trip button tapped")
                        // Add logic for starting trip
                    }) {
                        Text("End Trip")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.leading,10)
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
    
    
    // **Map View with Route**
    struct RouteMapView: UIViewRepresentable {
        let startAddress: String
        let endAddress: String
        
        func makeUIView(context: Context) -> MKMapView {
            let mapView = MKMapView()
            mapView.delegate = context.coordinator
            mapView.showsUserLocation = false // Hide live location
            mapView.isScrollEnabled = true
            mapView.isZoomEnabled = true
            fetchCoordinates(for: startAddress, endAddress, on: mapView)
            return mapView
        }
        
        func updateUIView(_ uiView: MKMapView, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            return Coordinator()
        }
        
        // Convert addresses to coordinates & draw route
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
                                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                            }
                        }
                    }
                }
            }
        }
        
        class Coordinator: NSObject, MKMapViewDelegate {
            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                if let polyline = overlay as? MKPolyline {
                    let renderer = MKPolylineRenderer(polyline: polyline)
                    renderer.strokeColor = .blue
                    renderer.lineWidth = 5
                    return renderer
                }
                return MKOverlayRenderer()
            }
        }
    }
    
    // **Preview**
    //struct TripDetailView_Previews: PreviewProvider {
    //    static var previews: some View {
    //        TripDetailView()
    //    }
    //}

}
