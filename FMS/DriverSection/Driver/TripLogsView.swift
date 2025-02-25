//
//  TripLogsView.swift
//  FMS
//
//  Created by Vansh Sharma on 25/02/25.
//

import SwiftUI
import FirebaseFirestore

struct TripLog: Identifiable {
    let id = UUID()
    let tripId: String
    let vehicleModel: String
    let vehicleRegistration: String
    let fromLocation: String
    let toLocation: String
    let tripDate: Date
    let distance: String
    let status: String
}

struct TripLogsView: View {
    @State private var completedTrips: [TripLog] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView("Loading trip logs...")
                } else if let error = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            fetchCompletedTrips()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else if completedTrips.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No completed trips found")
                            .font(.headline)
                        Text("Your completed trips will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(completedTrips) { trip in
                                TripLogCard(trip: trip)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Trip Logs")
            .onAppear {
                fetchCompletedTrips()
            }
        }
    }
    
    func fetchCompletedTrips() {
        guard let userUUID = userUUID else {
            errorMessage = "User not logged in"
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let db = Firestore.firestore()
        // Using only one where clause and then filtering the results in code
        db.collection("trips")
            .whereField("assignedDriver.id", isEqualTo: userUUID)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    if let error = error {
                        errorMessage = "Error loading trips: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        completedTrips = []
                        return
                    }
                    
                    // Filter for completed trips in the code instead of in the query
                    let completedDocs = documents.filter { document in
                        let data = document.data()
                        return (data["TripStatus"] as? String == "Completed")
                    }
                    
                    // Sort by date in code instead of in the query
                    let sortedDocs = completedDocs.sorted { doc1, doc2 in
                        let timestamp1 = doc1.data()["tripDate"] as? Timestamp ?? Timestamp(date: Date())
                        let timestamp2 = doc2.data()["tripDate"] as? Timestamp ?? Timestamp(date: Date())
                        return timestamp1.dateValue() > timestamp2.dateValue() // descending order
                    }
                    
                    guard !sortedDocs.isEmpty else {
                        completedTrips = []
                        return
                    }
                    
                    completedTrips = sortedDocs.compactMap { document -> TripLog? in
                        let data = document.data()
                        
                        // Extract vehicle details
                        guard let vehicleData = data["assignedVehicle"] as? [String: Any] else {
                            return nil
                        }
                        
                        let vehicleModel = vehicleData["model"] as? String ?? "Unknown Vehicle"
                        let vehicleRegistration = vehicleData["registrationNumber"] as? String ?? "Unknown"
                        
                        // Extract trip details
                        let fromLocation = data["startLocation"] as? String ?? "Unknown"
                        let toLocation = data["endLocation"] as? String ?? "Unknown"
                        
                        // Distance formatting
                        let distanceValue = data["distance"] as? Double ?? 0.0
                        let distance = String(format: "%.2f km", distanceValue)
                        
                        // Trip date
                        let timestamp = data["tripDate"] as? Timestamp ?? Timestamp(date: Date())
                        
                        return TripLog(
                            tripId: document.documentID,
                            vehicleModel: vehicleModel,
                            vehicleRegistration: vehicleRegistration,
                            fromLocation: fromLocation,
                            toLocation: toLocation,
                            tripDate: timestamp.dateValue(),
                            distance: distance,
                            status: "Completed"
                        )
                    }
                }
            }
    }
}

struct TripLogCard: View {
    let trip: TripLog
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 18))
                
                Text(trip.vehicleModel)
                    .font(.headline)
                
                Spacer()
                
                Text(formatDate(trip.tripDate))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.5))
            
            Divider()
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Vehicle info
                HStack {
                    Image(systemName: "car.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Vehicle: \(trip.vehicleModel) (\(trip.vehicleRegistration))")
                        .font(.subheadline)
                }
                
                // Distance
                HStack {
                    Image(systemName: "ruler")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Distance: \(trip.distance)")
                        .font(.subheadline)
                }
                
                // Route
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center, spacing: 8) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .padding(.leading, 8)
                        
                        Text("From: \(trip.fromLocation)")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 2, height: 20)
                            .padding(.leading, 11)
                        
                        Spacer()
                    }
                    
                    HStack(alignment: .center, spacing: 8) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 8, height: 8)
                            .padding(.leading, 8)
                        
                        Text("To: \(trip.toLocation)")
                            .font(.subheadline)
                    }
                }
                
                if isExpanded {
                    // Status badge
                    HStack {
                        Spacer()
                        
                        Text(trip.status)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(12)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .background(Color.white)
        }
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TripLogsView_Previews: PreviewProvider {
    static var previews: some View {
        TripLogsView()
    }
}
