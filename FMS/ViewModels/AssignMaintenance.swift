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

            // Fetch all maintenance personnel
            let maintenanceRef = self.db.collection("users")
                .whereField("role", isEqualTo: "Maintenance Personnel")

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

                // Get maintenance personnel sorted by least assigned vehicles
                let maintenancePersonnel = documents
                    .compactMap { doc -> (String, Int)? in
                        let id = doc.documentID
                        let assignedVehicles = doc.data()["assignedVehicles"] as? [String] ?? []
                        return (id, assignedVehicles.count)
                    }
                    .sorted { $0.1 < $1.1 } // Sort by least assigned vehicles

                // Ensure at least one available personnel
                guard let (assignedPersonnelID, _) = maintenancePersonnel.first else {
                    completion(.failure(NSError(domain: "FirestoreService", code: 404, userInfo: [
                        NSLocalizedDescriptionKey: "❌ No available maintenance personnel."
                    ])))
                    return
                }

                // Update the vehicle's maintenance status
                vehicleRef.updateData([
                    "needsMaintenance": true,
                    "assignedMaintenancePersonnelID": assignedPersonnelID,
                    "status": false
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

                        completion(.success("✅ Vehicle \(vehicleID) successfully assigned to maintenance personnel \(assignedPersonnelID)."))
                    }
                }
            }
        }
    }
}
