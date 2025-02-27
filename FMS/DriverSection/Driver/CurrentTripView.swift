import SwiftUI
import Firebase

struct CurrentTripView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    @State private var fromTrip = "Loading..."
    @State private var endLocation = "Loading..."
    @State private var Vehicle = "Loading..."
    @State private var Vehiclerc = "Loading..."
    @State private var vehicleType = "Loading..."
    @State private var estimatedTime = "Loading..."
    @State private var tripDateToday = "Loading..."
    @State private var distance = "Loading..."
    @State private var driverName = "Loading..."
    @State private var VehicleId = "Loading..."
    @State private var tripDate: Date? = nil
    @State private var isCurrentTrip = false
    @State private var tripID: String? = nil
    @State private var isTripStarted: Bool = false
    @State private var tripStatusFromDB: String = "Unknown"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if tripID != nil && tripStatusFromDB == "In Progress" {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Trip")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "truck.box.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 24))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Vehicle).font(.headline)
                                Spacer()
                                Text(Vehiclerc).font(.subheadline)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 6) {
                            tripDetailRow(title: "Start Location", value: fromTrip, color: .blue)
                            tripDetailRow(title: "To", value: endLocation, color: .gray)
                        }
                        
                        Divider()
                        
                        NavigationLink(
                            destination: TripDetailView(
                                startLocation: fromTrip,
                                endLocation: endLocation,
                                distance: distance,
                                vehicleModel: Vehicle,
                                driverName: driverName,
                                tripDate: tripDateToday,
                                vehicleType: vehicleType,
                                vehicleID: VehicleId.isEmpty ? "Unknown Vehicle ID" : VehicleId,
                                tripID: tripID ?? "Unknown Trip ID",
                                userID: userUUID ?? "Unknown User ID"
                            )
                        ) {
                            TripActionButton(
                                title: isTripStarted ? "Continue" : "Start Trip",
                                systemImage: isTripStarted ? "arrow.forward.circle.fill" : "play.fill",
                                bgColor: isTripStarted ? Color.orange.opacity(0.2) : Color.green.opacity(0.2),
                                fgColor: isTripStarted ? .orange : .green
                            )
                        }
                        .disabled(tripID == nil || VehicleId == "Loading..." || VehicleId.isEmpty)
                        .simultaneousGesture(TapGesture().onEnded {
                            guard let tripID = tripID, !tripID.isEmpty else {
                                print("❌ Error: tripID is missing")
                                return
                            }
                            print("🚀 Navigating to TripDetailView with VehicleID: \(VehicleId) and UserID: \(userUUID ?? "No User")")
                            
                            if VehicleId.isEmpty {
                                VehicleId = "Unknown Vehicle ID"
                            }
                            if userUUID == nil {
                                userUUID = "Unknown User ID"
                            }
                            
                            isTripStarted = true
                            UserDefaults.standard.set(true, forKey: "isTripStarted_\(tripID)")
                        })
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }
            else if tripID == nil || tripStatusFromDB == "Completed"
            {
                VStack {
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 16) {
                        Image(systemName: "truck.box.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 50))
                        
                        Text("No Available Trips")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)

                
            }
            
        }
        .onAppear {
            print("🚀 Loading CurrentTripView")
            fetchTrip()
        }
    
    }
    
    func fetchTrip() {
        guard let userUUID = userUUID else {
            print("❌ No user UUID found")
            return
        }

        let db = Firestore.firestore()
        db.collection("trips")
            .whereField("assignedDriver.id", isEqualTo: userUUID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching trips: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ No trips available")
                    DispatchQueue.main.async {
                        self.tripStatusFromDB = "No Trips"
                        self.isCurrentTrip = false
                        self.tripID = nil
                    }
                    return
                }

                for document in documents {
                    let tripData = document.data()
                    let tripStatus = tripData["TripStatus"] as? String ?? "Unknown"

                    print("📊 Trip Status from DB: \(tripStatus)")

                    if tripStatus == "In Progress" {
                        DispatchQueue.main.async {
                            self.tripID = document.documentID
                            self.fromTrip = tripData["startLocation"] as? String ?? "Unknown"
                            self.endLocation = tripData["endLocation"] as? String ?? "Unknown"
                            self.tripStatusFromDB = tripStatus // ✅ Update trip status
                            self.isCurrentTrip = true
                            
                            if let timestamp = tripData["tripDate"] as? Timestamp {
                                self.tripDate = timestamp.dateValue()
                            }

                            if let vehicleData = tripData["assignedVehicle"] as? [String: Any] {
                                self.Vehicle = vehicleData["model"] as? String ?? "Unknown Vehicle"
                                self.Vehiclerc = vehicleData["registrationNumber"] as? String ?? "Unknown Registration"
                                self.vehicleType = vehicleData["type"] as? String ?? "Unknown Type"
                                self.VehicleId = vehicleData["id"] as? String ?? "Unknown Vehicle ID"
                            }

                            if let driverData = tripData["assignedDriver"] as? [String: Any] {
                                self.driverName = driverData["name"] as? String ?? "Unknown Driver"
                            }

                            self.estimatedTime = tripData["estimatedTime"] as? String ?? "Unknown"
                            self.distance = tripData["distance"] as? String ?? "Unknown"

                            if let tripID = self.tripID {
                                self.isTripStarted = UserDefaults.standard.bool(forKey: "isTripStarted_\(tripID)")
                            }
                        }
                        return  // ✅ Stop after finding the first "In Progress" trip
                    }
                }

                // ❌ No "In Progress" trips found
                DispatchQueue.main.async {
                    self.tripStatusFromDB = "Completed"
                    self.isCurrentTrip = false
                    self.tripID = nil
                }
            }
    }
    
    func tripDetailRow(title: String, value: String, color: Color) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading) {
                Text(title).font(.subheadline).foregroundColor(color)
                Text(value).font(.body)
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
        HStack {
            Image(systemName: systemImage)
            Text(title).font(.subheadline)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .padding()
        .background(bgColor)
        .foregroundColor(fgColor)
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        CurrentTripView()
    }
}
