//
//  AssignMaintenance.swift
//  FMS
//
//  Created by Soham Chakraborty on 25/02/25.
//

import Foundation
import FirebaseFirestore

class AssignMaintenance {
    static let shared = AssignMaintenance()
    private let db = Firestore.firestore()
    private var currentMaintenanceIndex = 0

    private init() {}  // Prevent multiple instances

    func handleEndTrip(for vehicleID: String, completion: @escaping (Result<String, Error>) -> Void) {
        let vehicleRef = db.collection("vehicles").document(vehicleID)

        // Fetch vehicle details
        vehicleRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(NSError(domain: "FirestoreService", code: 500, userInfo: [
                    NSLocalizedDescriptionKey: "❌ Firestore error while fetching vehicle: \(error.localizedDescription)"
                ])))
                return
            }

            guard let document = document, document.exists,
                  let vehicleData = document.data(),
                  let totalDistance = vehicleData["totalDistance"] as? Int else {
                completion(.failure(NSError(domain: "FirestoreService", code: 400, userInfo: [
                    NSLocalizedDescriptionKey: "❌ Vehicle data is missing or corrupted."
                ])))
                return
            }

            let needsMaintenance = vehicleData["needsMaintenance"] as? Bool ?? false

            // Check if maintenance is needed
            if totalDistance < 100 {
                completion(.success("✅ Vehicle does not require maintenance yet. Current Distance: \(totalDistance)"))
                return
            }

            if needsMaintenance {
                completion(.success("⚠️ Maintenance is already assigned to this vehicle."))
                return
            }

            // Fetch all maintenance personnel sorted by index
            let maintenanceRef = self.db.collection("users")
                .whereField("role", isEqualTo: "Maintenance Personnel") // Ensure role matches Firestore data
//                .order(by: "maintenanceIndex")

            maintenanceRef.getDocuments { (querySnapshot, err) in
                if let err = err {
                    completion(.failure(NSError(domain: "FirestoreService", code: 500, userInfo: [
                        NSLocalizedDescriptionKey: "❌ Firestore error while fetching maintenance personnel: \(err.localizedDescription)"
                    ])))
                    return
                }

                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    completion(.failure(NSError(domain: "FirestoreService", code: 404, userInfo: [
                        NSLocalizedDescriptionKey: "❌ No maintenance personnel found."
                    ])))
                    return
                }

                // Get sorted maintenance personnel list
                let maintenancePersonnel = documents.map { $0.documentID }

                // Ensure we have at least one maintenance personnel
                guard !maintenancePersonnel.isEmpty else {
                    completion(.failure(NSError(domain: "FirestoreService", code: 404, userInfo: [
                        NSLocalizedDescriptionKey: "❌ No maintenance personnel available."
                    ])))
                    return
                }

                // Assign the next available maintenance personnel in a round-robin manner
                let assignedPersonnelID = maintenancePersonnel[self.currentMaintenanceIndex % maintenancePersonnel.count]

                // Update the vehicle's maintenance status
                vehicleRef.updateData([
                    "needsMaintenance": true,
                    "assignedMaintenancePersonnelID": assignedPersonnelID
                ]) { error in
                    if let error = error {
                        completion(.failure(NSError(domain: "FirestoreService", code: 500, userInfo: [
                            NSLocalizedDescriptionKey: "❌ Firestore error while updating vehicle maintenance status: \(error.localizedDescription)"
                        ])))
                        return
                    }

                    // Update the assigned maintenance personnel's record
                    self.db.collection("users").document(assignedPersonnelID).updateData([
                        "assignedVehicles": FieldValue.arrayUnion([vehicleID])
                    ]) { error in
                        if let error = error {
                            completion(.failure(NSError(domain: "FirestoreService", code: 500, userInfo: [
                                NSLocalizedDescriptionKey: "❌ Firestore error while updating maintenance personnel record: \(error.localizedDescription)"
                            ])))
                            return
                        }

                        // Move to the next maintenance personnel index
                        self.currentMaintenanceIndex = (self.currentMaintenanceIndex + 1) % maintenancePersonnel.count

                        completion(.success("✅ Vehicle \(vehicleID) successfully assigned to maintenance personnel \(assignedPersonnelID)."))
                    }
                }
            }
        }
    }

//    func handleEndTrip(for vehicleID: String, completion: @escaping (Result<String, Error>) -> Void) {
//        let vehicleRef = db.collection("vehicles").document(vehicleID)
//
//        // Fetch vehicle details
//        vehicleRef.getDocument { (document, error) in
//            if let error = error {
//                completion(.failure(NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "❌ Firestore error while fetching vehicle: \(error.localizedDescription)"])))
//                return
//            }
//
//            guard let document = document, document.exists else {
//                completion(.failure(NSError(domain: "FirestoreService", code: 404, userInfo: [NSLocalizedDescriptionKey: "❌ Vehicle not found in Firestore."])))
//                return
//            }
//
//            guard let vehicleData = document.data(),
//                  let totalDistance = vehicleData["totalDistance"] as? Int else {
//                completion(.failure(NSError(domain: "FirestoreService", code: 400, userInfo: [NSLocalizedDescriptionKey: "❌ Vehicle data is corrupted or missing required fields."])))
//                return
//            }
//
//            let needsMaintenance = vehicleData["needsMaintenance"] as? Bool ?? false
//
//            if totalDistance < 100 {
//                completion(.success("✅ Vehicle does not require maintenance yet. Current Distance: \(totalDistance)"))
//                return
//            }
//
//            if needsMaintenance {
//                completion(.success("⚠️ Maintenance is already assigned to this vehicle."))
//                return
//            }
//
//            // Fetch all maintenance personnel sorted by index
//            let maintenanceRef = self.db.collection("users").whereField("role", isEqualTo: "Maintenance Personnel").order(by: "maintenanceIndex")
//
//            maintenanceRef.getDocuments { (querySnapshot, err) in
//                if let err = err {
//                    completion(.failure(NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "❌ Firestore error while fetching maintenance personnel: \(err.localizedDescription)"])))
//                    return
//                }
//
//                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
//                    completion(.failure(NSError(domain: "FirestoreService", code: 404, userInfo: [NSLocalizedDescriptionKey: "❌ No maintenance personnel found."])))
//                    return
//                }
//
//                // Get sorted maintenance personnel list
//                let maintenancePersonnel = documents.map { $0.documentID }
//
//                // Ensure index does not go out of bounds
//                let assignedPersonnelID = maintenancePersonnel[self.currentMaintenanceIndex % maintenancePersonnel.count]
//
//                // Update the vehicle's maintenance status
//                vehicleRef.updateData([
//                    "needsMaintenance": true,
//                    "assignedMaintenancePersonnelID": assignedPersonnelID
//                ]) { error in
//                    if let error = error {
//                        completion(.failure(NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "❌ Firestore error while updating vehicle maintenance status: \(error.localizedDescription)"])))
//                        return
//                    }
//
//                    // Update the assigned maintenance personnel's record
//                    self.db.collection("maintenance").document(assignedPersonnelID).updateData([
//                        "assignedVehicles": FieldValue.arrayUnion([vehicleID])
//                    ]) { error in
//                        if let error = error {
//                            completion(.failure(NSError(domain: "FirestoreService", code: 500, userInfo: [NSLocalizedDescriptionKey: "❌ Firestore error while updating maintenance personnel record: \(error.localizedDescription)"])))
//                            return
//                        }
//
//                        // Move to the next maintenance personnel index
//                        self.currentMaintenanceIndex = (self.currentMaintenanceIndex + 1) % maintenancePersonnel.count
//
//                        completion(.success("✅ Vehicle \(vehicleID) successfully assigned to maintenance personnel \(assignedPersonnelID)."))
//                    }
//                }
//            }
//        }
//    }
}
