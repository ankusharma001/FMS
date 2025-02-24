//
//  HomeView.swift
//  FMS
//
//  Created by Prince on 14/02/25.
//

//
//  HomeView.swift
//  FMS
//
//  Created by Prince on 14/02/25.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @State private var userData: [String: Any] = [:]
    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    @State private var userName: String = "Loading..."

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        DriverHeaderView(userName: userName)
                        CurrentTripView()
                        RecentActivitiesView()
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal) // Add horizontal padding to the ScrollView content
                }
                .background(Color(.systemGray6))
                .navigationTitle("Driver DashBoard")
            }
            .onAppear { // Fetch user data when the view appears
                fetchUserProfile()
            }
        }
    }

    func fetchUserProfile() {
        guard let userUUID = userUUID else {
            print("No user UUID found")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userUUID).getDocument { (document, error) in
            if let document = document, document.exists {
                DispatchQueue.main.async {
                    self.userData = document.data() ?? [:]
                    self.userName = self.userData["name"] as? String ?? "Driver Name" // Provide a default name
                    print("User profile fetched: \(self.userData)")
                }
            } else {
                print("User not found or error: \(error?.localizedDescription ?? "Unknown error")")
                self.userName = "Driver Name" // Set default in case of error
            }
        }
    }
}
#Preview {
    HomeView()
}
