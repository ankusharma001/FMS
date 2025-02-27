import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MaintenanceHomeView: View {
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var assignedVehicles: [String] = []
    @State private var vehicleData: [Vehicle] = []
    @State private var statusFilter: Bool? = nil  // nil = all, true = Active, false = Inactive
    
    @State private var maintenanceStatusFilter: MaintenanceStatus? = nil  // nil = all, otherwise filter by status

    private var filteredVehicles: [Vehicle] {
        vehicleData.filter { vehicle in
            let matchesSearch = searchText.isEmpty ||
                vehicle.registrationNumber.localizedCaseInsensitiveContains(searchText) ||
                vehicle.model.localizedCaseInsensitiveContains(searchText)
            
            let matchesStatus = maintenanceStatusFilter == nil || vehicle.maintenanceStatus == maintenanceStatusFilter
            
            return matchesSearch && matchesStatus
        }
    }
    
    private let db = Firestore.firestore()
    private let userUUID = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    
    // Computed property to filter vehicle data
//    private var filteredVehicles: [Vehicle] {
//        vehicleData.filter { vehicle in
//            let matchesSearch = searchText.isEmpty ||
//                vehicle.registrationNumber.localizedCaseInsensitiveContains(searchText) ||
//                vehicle.model.localizedCaseInsensitiveContains(searchText)
//            
//            let matchesStatus = statusFilter == nil || vehicle.status == statusFilter
//            
//            return matchesSearch && matchesStatus
//        }
//    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                Button(action: {
                    print("Button tapped!\(assignedVehicles)")
                }) {
                    Text("Click Me")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                HStack(spacing: 12) {
                    StatisticCardView(
                        iconName: "square.grid.2x2.fill",
                        iconColor: .blue,
                        title: "Under Maintenance",
                        value: "\(vehicleData.filter { !$0.status }.count)"
                    )
                    
                    StatisticCardView(
                        iconName: "checkmark.circle.fill",
                        iconColor: .green,
                        title: "Completed Tasks",
                        value: "\(vehicleData.filter { $0.status }.count)"
                    )
                }
                .padding()
                
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search vehicles...", text: $searchText)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            searchText = ""  // Clear search
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.white))
                    .cornerRadius(10)
                    
                   
                    Picker("Maintenance Status", selection: $maintenanceStatusFilter) {
                        ForEach(MaintenanceStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status as MaintenanceStatus?)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                }
                .padding()
                .background(Color(.systemGray6))
                
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
                            ForEach(filteredVehicles, id: \.id) { vehicle in
                                MaintenanceTaskRow(vehicle: vehicle, assignedVehicles: assignedVehicles) {
                                    print("Perform action on \(vehicle.registrationNumber)")
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGray6))
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle("Home")
            .onAppear {
                fetchUserData()
            }
        }
    }
    
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
                        fetchVehicleData(vehicleIDs: assignedVehicleIDs)
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



struct MaintenanceTaskRow: View {
    var vehicle: Vehicle
    var assignedVehicles: [String] // ✅ Pass assignedVehicles here
    var action: () -> Void

    @State private var isUpdating = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(vehicle.model)
                    .font(.headline)
                
                Text(vehicle.registrationNumber)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(vehicle.maintenanceStatus.rawValue)
                    .font(.caption)
                    .foregroundColor(vehicle.maintenanceStatus == .active ? .orange : (vehicle.maintenanceStatus == .completed ? .green : .gray))
            }

            Spacer()

            Button(action: {
                print("in maintenance personnel: \(String(describing: vehicle.id))")
                updateAssignedVehiclesStatus()
            }) {
                if isUpdating {
                    ProgressView()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                } else {
                    Text(vehicle.maintenanceStatus == .scheduled ? "Start" : (vehicle.maintenanceStatus == .active ? "Complete" : "Completed"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(vehicle.maintenanceStatus == .scheduled ? Color.blue : (vehicle.maintenanceStatus == .active ? Color.orange : Color.green))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .disabled(vehicle.maintenanceStatus == .completed || isUpdating)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
    }

    private func updateAssignedVehiclesStatus() {
        let db = Firestore.firestore()
        
        for vehicleID in assignedVehicles {
            let vehicleRef = db.collection("vehicles").document(vehicleID)
            
            vehicleRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let currentStatus = document.data()?["maintenanceStatus"] as? String ?? "scheduled"
                    
                    var newStatus: MaintenanceStatus
                    var newVehicleStatus: Bool

                    switch MaintenanceStatus(rawValue: currentStatus) {
                    case .scheduled:
                        newStatus = .active
                        newVehicleStatus = false
                    case .active:
                        newStatus = .completed
                        newVehicleStatus = true
                    default:
                        return
                    }
                    
                    vehicleRef.updateData([
                        "maintenanceStatus": newStatus.rawValue,
                        "status": newVehicleStatus
                    ]) { error in
                        if let error = error {
                            print("Error updating vehicle \(vehicleID): \(error.localizedDescription)")
                        } else {
                            print("Vehicle \(vehicleID) updated successfully!")
                        }
                    }
                }
            }
        }
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
