import SwiftUI
import FirebaseFirestore

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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isCurrentTrip ? "Current Trip" : "Upcoming Trip")
                .font(.headline)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "truck.box.fill")
                        .foregroundColor(.blue)
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
                
                if isCurrentTrip {
                    NavigationLink(destination: TripDetailView(startLocation: fromTrip, endLocation: endLocation, distance: distance, vehicleModel: Vehicle, driverName: driverName, tripDate: tripDateToday, vehicleType: vehicleType,vehicleID: VehicleId)) {
                        TripActionButton(
                            title: "Start Trip",
                            systemImage: "play.fill",
                            bgColor: Color.green.opacity(0.2),
                            fgColor: .green
                            
                        )
                    }
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
                    if let timestamp = tripData["tripDate"] as? Timestamp {
                        self.tripDate = timestamp.dateValue()
                        self.checkIfCurrentTrip()
                    }
                    // Extract vehicle details
                    if let vehicleData = tripData["assignedVehicle"] as? [String: Any] {
                        self.Vehicle = vehicleData["model"] as? String ?? "Unknown Vehicle"
                        self.Vehiclerc = vehicleData["registrationNumber"] as? String ?? "Unknown Registration"
                        self.vehicleType = vehicleData["type"] as? String ?? "Unknown Type"
                        self.VehicleId = vehicleData["id"] as? String ?? "Unknown Type"
                    } else {
                        self.Vehicle = "No Vehicle Assigned"
                        self.Vehiclerc = "No Vehicle Assigned"
                        self.vehicleType = "No Vehicle Assigned"
                        self.VehicleId = "No Vehicle Assigned"
                    }
                    
                    // Extract driver details
                    if let driverData = tripData["assignedDriver"] as? [String: Any] {
                        self.driverName = driverData["name"] as? String ?? "Unknown Driver"
                    } else {
                        self.driverName = "No Driver Assigned"
                    }

                    // Extract estimated time
                    if let estimatedTimeValue = tripData["estimatedTime"] as? Double {
                        self.estimatedTime = "\(Int(estimatedTimeValue)) hours"
                    } else {
                        self.estimatedTime = "Unknown"
                    }

                    // Extract distance
                    if let distanceValue = tripData["distance"] as? Double {
                        self.distance = String(format: "%.2f km", distanceValue)
                    } else {
                        self.distance = "Unknown"
                    }

                    // Extract and format trip date
                    if let tripDateTimestamp = tripData["tripDate"] as? Timestamp {
                        let date = tripDateTimestamp.dateValue()
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.timeStyle = .none
                        self.tripDateToday = formatter.string(from: date)
                    } else {
                        self.tripDateToday = "Unknown"
                    }
//                    print("Vehicle: " + VehicleId)
                }
            }
    }

    
    private func checkIfCurrentTrip() {
        guard let tripDate = tripDate else {
            isCurrentTrip = false
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tripDay = calendar.startOfDay(for: tripDate)
        
        isCurrentTrip = calendar.isDate(today, inSameDayAs: tripDay)
    }
    
    private func tripDetailRow(title: String, value: String, color: Color) -> some View {
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
