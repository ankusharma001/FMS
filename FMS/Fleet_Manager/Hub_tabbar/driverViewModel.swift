

import FirebaseFirestore
import SwiftUI

class DriverViewModel: ObservableObject {
    @Published var drivers: [Driver] = []
    private var listener: ListenerRegistration?
    
    init() {
        startListeningToDrivers()
    }
    
    deinit {
        stopListeningToDrivers()
    }
    
    func startListeningToDrivers() {
        let db = Firestore.firestore()
        
        // Remove any existing listener
        stopListeningToDrivers()
        
        // Start real-time listener
        listener = db.collection("users")
            .whereField("role", isEqualTo: "Driver")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching drivers: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                DispatchQueue.main.async {
                    self.drivers = snapshot.documents.compactMap { document -> Driver? in
                        let data = document.data()
                        
                        guard let name = data["name"] as? String,
                              let email = data["email"] as? String,
                              let phone = data["phone"] as? String,
                              let experienceRaw = data["experience"] as? String,
                              let experience = Experience(rawValue: experienceRaw),
                              let license = data["license"] as? String,
                              let geoPreferenceRaw = data["geoPreference"] as? String,
                              let geoPreference = GeoPreference(rawValue: geoPreferenceRaw),
                              let vehiclePreferenceRaw = data["vehiclePreference"] as? String,
                              let vehiclePreference = VehicleType(rawValue: vehiclePreferenceRaw),
                              let status = data["status"] as? Bool else { return nil }
                        
                        var upcomingTrip: Trip? = nil
                        
                        if let tripData = data["upcomingTrip"] as? [String: Any],
                           let tripDateTimestamp = tripData["tripDate"] as? Timestamp,
                           let startLocation = tripData["startLocation"] as? String,
                           let endLocation = tripData["endLocation"] as? String,
                           let distance = tripData["distance"] as? Float,
                           let estimatedTime = tripData["estimatedTime"] as? Float,
                           let tripStatusRaw = tripData["TripStatus"] as? String,
                           let tripStatus = TripStatus(rawValue: tripStatusRaw) {
                            
                            let tripDate = tripDateTimestamp.dateValue()
                            
                            upcomingTrip = Trip(
                                tripDate: tripDate,
                                startLocation: startLocation,
                                endLocation: endLocation,
                                distance: distance,
                                estimatedTime: estimatedTime,
                                assignedDriver: nil,
                                TripStatus: tripStatus,
                                assignedVehicle: nil
                            )
                        }
                        
                        let driver = Driver(
                            name: name,
                            email: email,
                            phone: phone,
                            experience: experience,
                            license: license,
                            geoPreference: geoPreference,
                            vehiclePreference: vehiclePreference,
                            status: status
                        )
                        driver.id = document.documentID
                        driver.upcomingTrip = upcomingTrip
                        return driver
                    }
                }
            }
    }
    
    func stopListeningToDrivers() {
        listener?.remove()
        listener = nil
    }
}
