//
//  HomeView.swift
//  FMS
//
//  Created by Prince on 14/02/25.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    @State private var userName: String = "Loading..."
    @State private var tripID: String? // Store trip ID
    

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        DriverHeaderView(userName: userName,tripID:tripID)
                        CurrentTripView()
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal)
                }
                
                // Button to print the trip ID
//                Button(action: {
//                    print("🟢 Trip ID on button click: \(tripID ?? "No Trip Assigned")")
//                }) {
//                    Text("Print Trip ID")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        .padding()
//                }
                
                .background(Color(.systemGray6))
                .navigationTitle("Driver Dashboard")
            }
            .onAppear {
                fetchUser()
            }
            
        }
    }

    func fetchUser() {
        guard let userUUID = userUUID else {
            print("❌ No user UUID found")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userUUID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                let fetchedUserName = data["name"] as? String ?? "Driver Name"

                DispatchQueue.main.async {
                    self.userName = fetchedUserName
                }

                // Fetch trip ID separately
                fetchTripID(for: userUUID)
                
            } else {
                print("❌ User not found or error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.userName = "Driver Name"
                    self.tripID = nil
                }
            }
        }
    }

    func fetchTripID(for userUUID: String) {
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
                        self.tripID = nil
                    }
                    return
                }

                // Fetch only the trip ID
                let firstTripID = documents.first?.documentID

                DispatchQueue.main.async {
                    self.tripID = firstTripID
                }
            }
    }
}

#Preview {
    HomeView()
}
