//
//  RecentActivitiesView.swift
//  FMS
//
//  Created by Prince on 14/02/25.
//

import SwiftUI
import FirebaseFirestore

struct RecentActivity: Identifiable {
    let id = UUID()
    let vehicleNumber: String
    let fromLocation: String
    let toLocation: String
    let tripDate: Date
}

struct RecentActivitiesView: View {
    @State private var recentTrips: [RecentActivity] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Activities")
                .font(.headline)
                .padding(.horizontal)

            if recentTrips.isEmpty {
                Text("No recent trips available.")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(recentTrips) { trip in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 24))

                            VStack(alignment: .leading) {
                                Text("Vehicle #\(trip.vehicleNumber)")
                                    .font(.headline)
                                Text("\(formattedDate(trip.tripDate))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Circle().fill(Color.blue).frame(width: 8, height: 8)
                                Text("From: \(trip.fromLocation)")
                                    .font(.body)
                            }
                            HStack {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(width: 2, height: 20)
                                    .padding(.leading, 3.5)
                                Spacer()
                            }
                            HStack {
                                Circle().fill(Color.gray).frame(width: 8, height: 8)
                                Text("To: \(trip.toLocation)")
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }
        }
        .padding(.top, 10)
        .background(Color(.systemGray6))
        .onAppear {
            fetchRecentTrips()
        }
    }

    // MARK: - Fetch Real Data from Firestore
    func fetchRecentTrips() {
        let db = Firestore.firestore()

        guard let driverID = UserDefaults.standard.string(forKey: "loggedInUserUUID") else {
            print("No logged-in user found in UserDefaults.")
            return
        }

        print("Fetching recent trips for driverID: \(driverID)")

        db.collection("trips")
            .whereField("driverID", isEqualTo: driverID)
            .order(by: "tripDate", descending: true)
            .limit(to: 5)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Firestore fetch error: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No recent trips found for driverID: \(driverID)")
                    return
                }

                DispatchQueue.main.async {
                    self.recentTrips = documents.compactMap { document in
                        let data = document.data()
                        guard let vehicleNumber = data["vehicleNumber"] as? String,
                              let fromLocation = data["fromLocation"] as? String,
                              let toLocation = data["toLocation"] as? String,
                              let timestamp = data["tripDate"] as? Timestamp else {
                            return nil
                        }
                        return RecentActivity(
                            vehicleNumber: vehicleNumber,
                            fromLocation: fromLocation,
                            toLocation: toLocation,
                            tripDate: timestamp.dateValue()
                        )
                    }
                }
            }
    }

    // MARK: - Date Formatting
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct RecentActivitiesScreen: View {
    var body: some View {
        VStack {
            RecentActivitiesView()
            Spacer()
        }
        .background(Color(.systemGray6))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    RecentActivitiesScreen()
}
