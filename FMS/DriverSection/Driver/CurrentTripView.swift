//
//  CurrentTripView.swift
//  FMS
//
//  Created by Prince on 14/02/25.
//

//
//  CurrentTripView.swift
//  FMS
//
//  Created by Prince on 14/02/25.
//


import SwiftUI
import FirebaseFirestore

struct CurrentTripView: View {
    @State private var userData: [String: Any] = [:]
    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    
    @State private var isEditing = false
    @State private var isShowingEditProfile = false
    @State private var fromTrip = "Loading..."
    @State private var endLocation = "Loading..."
    @State private var Vehicle = "Loading..."
    @State private var Vehiclerc = "Loading..."
    @State private var estimatedTime = "Loading..."
    @State private var distance = "Loading..."
    

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Trip")
                .font(.headline)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "truck.box.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(Vehicle) // Placeholder
                            .font(.headline)
//                            .foregroundColor(.gray)
                        Spacer()
                  
                        Text(Vehiclerc) // Placeholder
                            .font(.subheadline)
//                            .foregroundColor(.gray)
                    }
                   
                }

                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center, spacing: 8) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        VStack(alignment: .leading) {
                            Text("Start Location")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text(fromTrip) // Placeholder
                                .font(.body)
                        }
                    }

                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 2, height: 20)
                            .padding(.leading, 3.5)
                        Spacer()
                    }

                    HStack(alignment: .center, spacing: 8) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 8, height: 8)
                        VStack(alignment: .leading) {
                            Text("To")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(endLocation) // Placeholder
                                .font(.body)
                        }
                    }
//                    VStack(alignment: .leading, spacing: 6) {
//                        Text("Estimated Time")
//                            .font(.subheadline)
//                            .foregroundColor(.blue)
//                        Text(estimatedTime)
//                            .font(.body)
//
//                        Text("Distance")
//                            .font(.subheadline)
//                            .foregroundColor(.blue)
//                        Text(distance)
//                            .font(.body)
//                    }


                }

                Divider()

                HStack(spacing: 12) {
                    TripActionButton(title: "Start Trip", systemImage: "play.fill", bgColor: Color.green.opacity(0.2), fgColor: .green)
                    TripActionButton(title: "End Trip", systemImage: "stop.fill", bgColor: Color.red.opacity(0.2), fgColor: .red)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .padding(.top, 10)
        .background(Color(.systemGray6))
        .onAppear {
            fetchTrip()
        }
    }
    
    private func fetchTrip() {
        guard let userUUID = userUUID else {
            print("No user UUID found")
            return
        }

        let db = Firestore.firestore()
        db.collection("trips")
            .whereField("assignedDriver.id", isEqualTo: userUUID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching trips: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents, let tripData = documents.first?.data() else {
                    print("No trips assigned to this user")
                    return
                }

                DispatchQueue.main.async {
                    self.fromTrip = tripData["startLocation"] as? String ?? "Unknown"
                    self.endLocation = tripData["endLocation"] as? String ?? "Unknown"
//                    if let estimatedTime = tripData["estimatedTime"] as? Float {
//                        self.estimatedTime = String(format: "%.2f hours", estimatedTime)
//                    } else {
//                        self.estimatedTime = "Unknown"
//                    }
//
//                    if let distance = tripData["distance"] as? Float {
//                        self.distance = String(format: "%.2f km", distance)
//                    } else {
//                        self.distance = "Unknown"
//                    }

                    
                    if let vehicleData = tripData["assignedVehicle"] as? [String: Any] {
                                       self.Vehicle = vehicleData["model"] as? String ?? "Unknown Vehicle"
                                   } else {
                                       self.Vehicle = "No Vehicle Assigned"
                                   }
                    if let vehicleData = tripData["assignedVehicle"] as? [String: Any] {
                                       self.Vehiclerc = vehicleData["registrationNumber"] as? String ?? "Unknown Vehicle"
                                   } else {
                                       self.Vehiclerc = "No Vehicle Assigned"
                                   }
                }
            }
    }
}

struct TripActionButton: View {
    var title: String
    var systemImage: String
    var bgColor: Color
    var fgColor: Color

    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding()
            .background(bgColor)
            .foregroundColor(fgColor)
            .cornerRadius(8)
        }
    }
}

#Preview {
    CurrentTripView()
}
