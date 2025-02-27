import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MaintenanceHomeView: View {
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var assignedVehicles: [String] = []
    @State private var vehicleData: [Vehicle] = []
    
    private let db = Firestore.firestore()
    private let userUUID = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                //                VStack(alignment: .leading, spacing: 16) {
                //                    HStack {
                //                        Text("Home")
                //                            .font(.largeTitle)
                //                            .fontWeight(.bold)
                //                        Spacer()
                //                        Button(action: { }) {
                //                            ZStack {
                //                                Circle()
                //                                    .fill(Color.red.opacity(0.2))
                //                                    .frame(width: 44, height: 44)
                //                                Image(systemName: "bell.fill")
                //                                    .foregroundColor(.red)
                //                                    .font(.system(size: 20))
                //                            }
                //                        }
                //                    }
                //                }
                //                .padding()
                //                .background(Color.white)
                HStack(spacing: 12) {
                    // Under Maintenance card
                    StatisticCardView(
                        iconName: "square.grid.2x2.fill",
                        iconColor: .blue,
                        title: "Under Maintenance",
                        value: "0"
                    )
                    
                    // Completed Tasks card
                    StatisticCardView(
                        iconName: "checkmark.circle.fill",
                        iconColor: .green,
                        title: "Completed Tasks",
                        value: "0"
                    )
                }.padding()
                VStack(spacing: 15) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search vehicles...", text: $searchText)
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        // Additional filter options
                    }) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding()
            .background(Color.white)
        
            
              
                
                if isLoading {
                    Spacer()
                    ProgressView("Loading data...")
                    Spacer()
                } else if let errorMessage = errorMessage {
                    Spacer()
                    Text(errorMessage).padding()
                    Button("Retry") { fetchUserData() }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(vehicleData, id: \.id) { vehicle in
                                MaintenanceTaskRow(vehicle: vehicle) {
                                    print("Perform action on \(vehicle.registrationNumber)")
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGray6))
                }
            }.background(Color(.systemGray6))
                
            
                .navigationTitle("Home")
            
            .onAppear { fetchUserData() }
        }
    }
    
    /// Fetch user data and assigned vehicles
    private func fetchUserData() {
        guard let userUUID = userUUID else {
            errorMessage = "User not logged in."
            isLoading = false
            return
        }
        
        db.collection("users").document(userUUID).getDocument { (document, error) in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    let userData = document.data() ?? [:]
                    if let assignedVehicleIDs = userData["assignedVehicles"] as? [String] {
                        self.assignedVehicles = assignedVehicleIDs
                        fetchVehicleData(vehicleIDs: assignedVehicleIDs) // Fetch vehicle details
                    } else {
                        self.isLoading = false
                        self.errorMessage = "No assigned vehicles."
                    }
                } else {
                    self.errorMessage = "User data not found."
                }
                self.isLoading = false
            }
        }
    }
    
    /// Fetch vehicle details based on assigned vehicle IDs
    private func fetchVehicleData(vehicleIDs: [String]) {
        var fetchedVehicles: [Vehicle] = []
        let group = DispatchGroup()

        for vehicleID in vehicleIDs {
            group.enter()
            db.collection("vehicles").document(vehicleID).getDocument { (document, error) in
                defer { group.leave() }
                if let document = document, document.exists {
                    do {
                        let vehicle = try document.data(as: Vehicle.self)
                        DispatchQueue.main.async {
                            fetchedVehicles.append(vehicle)
                        }
                    } catch {
                        print("Error decoding vehicle \(vehicleID): \(error.localizedDescription)")
                    }
                } else {
                    print("Vehicle not found for ID \(vehicleID) or error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }

        group.notify(queue: .main) {
            self.vehicleData = fetchedVehicles
        }
    }
}

/// A row displaying a vehicle's maintenance details
struct MaintenanceTaskRow: View {
    var vehicle: Vehicle
    var action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(vehicle.registrationNumber)
                    .font(.headline)

                Text(vehicle.model)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(vehicle.status ? "Active" : "Inactive")
                    .font(.caption)
                    .foregroundColor(vehicle.status ? .orange : .gray)
            }

            Spacer()

            Button(action: action) {
                Text("Start/Complete") // Adjust dynamically if needed
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(vehicle.status ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .shadow(radius: 2)
    }
}

struct StatisticCardView: View {
    var iconName: String
    var iconColor: Color
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: iconName)
                            .foregroundColor(iconColor)
                    )
                Spacer()
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

/// Main Tab View
struct MaintenanceTabView: View {
    var body: some View {
        TabView {
//<<<<<<< HEAD
//            MaintenanceHomeView().tabItem { Label("Home", systemImage: "house.fill") }
//            MaintenanceProfileView().tabItem { Label("Profile", systemImage: "person.fill") }
//        }.background(Color.white)
//=======
            MaintenanceHomeView()
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            // ✅ Replacing Text with ProfileView
                
            InventoryView()
                .tabItem{
                    Image(systemName: "wrench.and.screwdriver")
                    Text("Inventory")
                }
                MaintenanceProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                
        }
//>>>>>>> 43a560a8f9c4b1d7accc741dad7a3c7ffb5b4d0b
    }
}

#Preview {
    NavigationStack{
        MaintenanceTabView()
    }
}
