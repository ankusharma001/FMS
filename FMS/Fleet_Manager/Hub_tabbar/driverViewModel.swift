//
//  d.swift
//  FMS
//
//  Created by Aastik Mehta on 21/02/25.
//

import FirebaseFirestore
import SwiftUI
//
//class DriverViewModel: ObservableObject {
//    @Published var drivers: [Driver] = []
//
//    init() {
//        fetchDrivers()
//    }
//
//    func fetchDrivers() {
//        let db = Firestore.firestore()
//        db.collection("users")
//            .whereField("role", isEqualTo: "Driver")  // Fetch only drivers
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching drivers: \(error.localizedDescription)")
//                    return
//                }
//
//                DispatchQueue.main.async {
//                    self.drivers = snapshot?.documents.compactMap { document -> Driver? in
//                        let data = document.data()
//                        guard let name = data["name"] as? String,
//                              let email = data["email"] as? String,
//                              let phone = data["phone"] as? String,
//                              let experienceRaw = data["experience"] as? String,
//                              let experience = Experience(rawValue: experienceRaw),
//                              let license = data["license"] as? String,
//                              let geoPreferenceRaw = data["geoPreference"] as? String,
//                              let geoPreference = GeoPreference(rawValue: geoPreferenceRaw),
//                              let vehiclePreferenceRaw = data["vehiclePreference"] as? String,
//                              let vehiclePreference = VehicleType(rawValue: vehiclePreferenceRaw),
//                              let status = data["status"] as? Bool else { return nil },
//                             let upcomingTrip = data["upcomingTrip"] as? Trip else {return nil}
//                        
//                        return Driver(
//                            name: name,
//                            email: email,
//                            phone: phone,
//                            experience: experience,
//                            license: license,
//                            geoPreference: geoPreference,
//                            vehiclePreference: vehiclePreference,
//                            status: status,
//                            upcomingTrip: upcomingTrip
//                        )
//                    } ?? []
//                }
//            }
//    }
//}

//
//  d.swift
//  FMS
//
//  Created by Aastik Mehta on 21/02/25.
//

import FirebaseFirestore
import SwiftUI

class DriverViewModel: ObservableObject {
    @Published var drivers: [Driver] = []

    init() {
        fetchDrivers()
    }

    func fetchDrivers() {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("role", isEqualTo: "Driver")  // Fetch only drivers
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching drivers: \(error.localizedDescription)")
                    return
                }

                DispatchQueue.main.async {
                    self.drivers = snapshot?.documents.compactMap { document -> Driver? in
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
                                assignedDriver: nil, // Avoid circular reference
                                TripStatus: tripStatus,
                                assignedVehicle: nil // Can be fetched separately if needed
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
                        driver.upcomingTrip = upcomingTrip
                        return driver
                    } ?? []
                }
            }
    }
}

