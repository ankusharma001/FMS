import SwiftUI
import FirebaseFirestore

struct CurrentTripView: View {
    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    @State private var fromTrip = "Loading..."
    @State private var endLocation = "Loading..."
    @State private var Vehicle = "Loading..."
    @State private var Vehiclerc = "Loading..."
    @State private var tripDate: Date? = nil
    @State private var isCurrentTrip = false
    @State private var navigateToTripDetail = false

    
    var body: some View {
        NavigationStack{
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
                        HStack(spacing: 12) {
                            if isCurrentTrip {
                                HStack(spacing: 12) {
                                    Button(action: {
                                        navigateToTripDetail = true
                                    }) {
                                        TripActionButton(title: "Start Trip", systemImage: "play.fill", bgColor: Color.green.opacity(0.2), fgColor: .green)
                                    }
                                }
                                .navigationDestination(isPresented: $navigateToTripDetail) {
                                    TripDetailView()
                                }
                            }

                            //                        TripActionButton(title: "End Trip", systemImage: "stop.fill", bgColor: Color.red.opacity(0.2), fgColor: .red)
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
                        
                        // Handle the Timestamp or String date from Firestore
                        if let timestamp = tripData["tripDate"] as? Timestamp {
                            self.tripDate = timestamp.dateValue()
                            self.checkIfCurrentTrip()
                        } else if let dateString = tripData["tripDate"] as? String {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a 'UTC'Z"
                            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                            if let date = dateFormatter.date(from: dateString) {
                                self.tripDate = date
                                self.checkIfCurrentTrip()
                            }
                        }
                        
                        if let vehicleData = tripData["assignedVehicle"] as? [String: Any] {
                            self.Vehicle = vehicleData["model"] as? String ?? "Unknown Vehicle"
                            self.Vehiclerc = vehicleData["registrationNumber"] as? String ?? "Unknown Vehicle"
                        }
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
            print("Trip Date: \(tripDay), Today: \(today), isCurrentTrip: \(isCurrentTrip)")
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
        Button(action: {}) {
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
}

#Preview {
    CurrentTripView()
}
