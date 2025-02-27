////
////  AvailableVehicleView.swift
////  FMS
////
////  Created by Aastik Mehta on 20/02/25.
////
//
//import SwiftUI
//import FirebaseFirestore
//
//
//
//struct AvailableVehicleView: View {
//    @Environment(\.presentationMode) var presentationMode
//    var trip: Trip
//    var onVehicleSelected: (Vehicle) -> Void
//    @State private var vehicles: [Vehicle] = []
//    @State private var isLoading = true
//    @State private var errorMessage: String?
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                if isLoading {
//                    VStack {
//                        ProgressView()
//                            .padding()
//                        Text("Loading available vehicles...")
//                    }
//                } else if let error = errorMessage {
//                    VStack {
//                        Image(systemName: "exclamationmark.triangle")
//                            .font(.largeTitle)
//                            .foregroundColor(.orange)
//                            .padding()
//                        Text(error)
//                            .multilineTextAlignment(.center)
//                            .padding()
//                        Button("Try Again") {
//                            fetchVehicles()
//                        }
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                    }
//                    .padding()
//                } else if vehicles.isEmpty {
//                    VStack {
//                        Image(systemName: "car.slash")
//                            .font(.largeTitle)
//                            .foregroundColor(.gray)
//                            .padding()
//                        Text("No available vehicles found")
//                            .font(.headline)
//                        Text("All vehicles are currently assigned to other trips")
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(.gray)
//                            .padding()
//                    }
//                    .padding()
//                } else {
//                    List(vehicles) { vehicle in
//                        Button(action: {
//                            onVehicleSelected(vehicle)
//                            presentationMode.wrappedValue.dismiss()
//                        }) {
//                            HStack {
//                                ZStack {
//                                    Circle()
//                                        .fill(vehicleTypeColor(vehicle.type).opacity(0.2))
//                                        .frame(width: 50, height: 50)
//                                    Image(systemName: vehicleTypeIcon(vehicle.type))
//                                        .foregroundColor(vehicleTypeColor(vehicle.type))
//                                        .font(.system(size: 24))
//                                }
//                                
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text("\(vehicle.model)").bold()
//                                    Text(vehicle.registrationNumber)
//                                        .font(.subheadline)
//                                        .foregroundColor(.gray)
//                                    HStack {
//                                        Text(vehicle.type.rawValue)
//                                            .font(.caption)
//                                            .padding(.horizontal, 8)
//                                            .padding(.vertical, 2)
//                                            .background(vehicleTypeColor(vehicle.type).opacity(0.2))
//                                            .cornerRadius(4)
//                                        
//                                        Text(vehicle.fuelType.rawValue)
//                                            .font(.caption)
//                                            .padding(.horizontal, 8)
//                                            .padding(.vertical, 2)
//                                            .background(fuelTypeColor(vehicle.fuelType).opacity(0.2))
//                                            .cornerRadius(4)
//                                        
//                                        Text("Mileage: \(vehicle.mileage) km")
//                                            .font(.caption)
//                                            .padding(.horizontal, 8)
//                                            .padding(.vertical, 2)
//                                            .background(Color.gray.opacity(0.2))
//                                            .cornerRadius(4)
//                                    }
//                                }
//                                Spacer()
//                                Image(systemName: "checkmark.circle")
//                                    .foregroundColor(.green)
//                                    .opacity(vehicle.status ? 1.0 : 0.0)
//                            }
//                            .padding(.vertical, 4)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Available Vehicles")
//            .onAppear(perform: fetchVehicles)
//        }
//    }
//    
//    private func vehicleTypeIcon(_ type: VehicleType) -> String {
//        switch type {
//        case .truck: return "truck"
//        case .van: return "van"
//        case .car: return "car"
//        }
//    }
//    
//    private func vehicleTypeColor(_ type: VehicleType) -> Color {
//        switch type {
//        case .truck: return .blue
//        case .van: return .orange
//        case .car: return .green
//        }
//    }
//    
//    private func fuelTypeColor(_ type: FuelType) -> Color {
//        switch type {
//        case .petrol: return .red
//        case .diesel: return .blue
//        case .hybrid: return .purple
//        case .electric: return .green
//        }
//    }
//    
////    private func fetchVehicles() {
////        isLoading = true
////        errorMessage = nil
////        vehicles = []
////        
////        let db = Firestore.firestore()
////        
////        // Get ALL vehicles first without filtering
////        db.collection("vehicles")
////            .getDocuments { (snapshot, error) in
////                self.isLoading = false
////                
////                if let error = error {
////                    print("Error fetching vehicles: \(error)")
////                    self.errorMessage = "Failed to load vehicles: \(error.localizedDescription)"
////                    return
////                }
////                
////                guard let documents = snapshot?.documents else {
////                    print("No vehicles found at all")
////                    return
////                }
////                
////                print("Found \(documents.count) total vehicle documents")
////                
////                // Debug: print all vehicle documents to see their status
////                for doc in documents {
////                    print("Vehicle ID: \(doc.documentID), Data: \(doc.data())")
////                }
////                
////                // Try to decode all vehicles and filter available ones manually
////                let allVehicles = documents.compactMap { document -> Vehicle? in
////                    do {
////                        var vehicle = try document.data(as: Vehicle.self)
////                        vehicle.id = document.documentID
////                        return vehicle
////                    } catch let error {
////                        print("Error decoding vehicle \(document.documentID): \(error)")
////                        return nil
////                    }
////                }
////                
////                print("Successfully decoded \(allVehicles.count) vehicles")
////                
////                // Debug: print all vehicle status values
////                for vehicle in allVehicles {
////                    print("Vehicle \(vehicle.id ?? "unknown"): status=\(vehicle.status), model=\(vehicle.model)")
////                }
////                
////                // Manually filter for available vehicles
////                self.vehicles = allVehicles.filter { $0.status == true }
////                
////                print("After filtering: \(self.vehicles.count) vehicles are available")
////            }
////    }
//    
//    private func fetchVehicles() {
//        isLoading = true
//        errorMessage = nil
//        vehicles = []
//        
//        let db = Firestore.firestore()
//        
//        // Filter for available vehicles directly in the query
//        db.collection("vehicles")
//            .whereField("status", isEqualTo: true)
//            .getDocuments { (snapshot, error) in
//                self.isLoading = false
//                
//                if let error = error {
//                    print("Error fetching vehicles: \(error)")
//                    self.errorMessage = "Failed to load vehicles: \(error.localizedDescription)"
//                    return
//                }
//                
//                print("Fetching available vehicles...")
//                print("Vehicle count: \(self.vehicles.count)")
//
//                
//                guard let documents = snapshot?.documents else {
//                    print("No available vehicles found")
//                    return
//                }
//                
//                print("Found \(documents.count) available vehicle documents")
//                
//                // Decode the filtered vehicles
//                self.vehicles = documents.compactMap { document -> Vehicle? in
//                    do {
//                        let vehicle = try document.data(as: Vehicle.self)
//                        vehicle.id = document.documentID
//                        return vehicle
//                    } catch let error {
//                        print("Error decoding vehicle \(document.documentID): \(error)")
//                        return nil
//                    }
//                }
//                
//                print("Successfully decoded \(self.vehicles.count) available vehicles")
//            }
//    }
//   
//}
//
//
//#Preview {
//    AvailableVehicleView(trip: Trip(
//        tripDate: Date(),
//        startLocation: "New York",
//        endLocation: "Los Angeles",
//        distance: 3000,
//        estimatedTime: 1800,
//        assignedDriver: nil,
//        TripStatus: .scheduled,
//        assignedVehicle: nil
//    )) { _ in
//        print("Vehicle selected")
//    }
//}
//


import SwiftUI
import FirebaseFirestore

struct AvailableVehicleView: View {
    @Environment(\.dismiss) var dismiss  // Updated for better dismissal handling
    var trip: Trip
    var onVehicleSelected: (Vehicle) -> Void

    @State private var vehicles: [Vehicle] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText: String = ""
    @State private var selectedVehicleType: VehicleType? = nil
    @State private var selectedFuelType: FuelType? = nil

    var filteredVehicles: [Vehicle] {
        vehicles.filter { vehicle in
            let matchesSearch = searchText.isEmpty ||
                vehicle.model.localizedCaseInsensitiveContains(searchText) ||
                vehicle.registrationNumber.localizedCaseInsensitiveContains(searchText)
            let matchesVehicleType = selectedVehicleType == nil || vehicle.type == selectedVehicleType
            let matchesFuelType = selectedFuelType == nil || vehicle.fuelType == selectedFuelType
            return matchesSearch && matchesVehicleType && matchesFuelType
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                VehicleSearchBar(text: $searchText, placeholder: "Search vehicle")

                // Filters
                HStack {
                    Picker("Vehicle Type", selection: $selectedVehicleType) {
                        Text("Vehicle Type").tag(VehicleType?.none)
                        ForEach(VehicleType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(Optional(type))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)

                    Picker("Fuel Type", selection: $selectedFuelType) {
                        Text("Fuel Type").tag(FuelType?.none)
                        ForEach(FuelType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(Optional(type))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                .padding()
                Spacer()

                // Loading State
                if isLoading {
                    ProgressView("Loading available vehicles...")
                        .padding()
                }
                // Error State
                else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                // No Data Found State
                else if filteredVehicles.isEmpty {
                    Spacer()
                    Text("No matching vehicles found")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Text("All vehicles are currently assigned to other trips")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                // List of Vehicles
                else {
                    List(filteredVehicles) { vehicle in
                        Button(action: {
                            onVehicleSelected(vehicle)
                            dismiss()
                        }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(vehicleTypeColor(vehicle.type).opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: vehicleTypeIcon(vehicle.type))
                                        .foregroundColor(vehicleTypeColor(vehicle.type))
                                }
                                VStack(alignment: .leading) {
                                    Text(vehicle.model).bold()
                                    Text("Type: \(vehicle.type.rawValue)")
                                    Text(vehicle.fuelType.rawValue)
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                    .opacity(vehicle.status ? 1.0 : 0.0)
                            }
                        }
                    }
                    .listStyle(.plain)  // Removes unnecessary styling
                }
            }
            .navigationTitle("Available Vehicles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .onAppear(perform: fetchVehicles)
        }
    }

    private func vehicleTypeIcon(_ type: VehicleType) -> String {
        switch type {
        case .truck: return "truck"
        case .van: return "van"
        case .car: return "car"
        }
    }
    
    private func vehicleTypeColor(_ type: VehicleType) -> Color {
        switch type {
        case .truck: return .blue
        case .van: return .orange
        case .car: return .green
        }
    }
    
    private func fuelTypeColor(_ type: FuelType) -> Color {
        switch type {
        case .petrol: return .red
        case .diesel: return .blue
        case .hybrid: return .purple
        case .electric: return .green
        }
    }

    private func fetchVehicles() {
        isLoading = true
        errorMessage = nil

        let db = Firestore.firestore()
        db.collection("vehicles")
            .whereField("status", isEqualTo: true)
            .getDocuments { (snapshot, error) in
                isLoading = false

                if let error = error {
                    errorMessage = "Failed to load vehicles: \(error.localizedDescription)"
                    return
                }

                self.vehicles = snapshot?.documents.compactMap { document in
                    var vehicle = try? document.data(as: Vehicle.self)
                    vehicle?.id = document.documentID
                    return vehicle
                } ?? []
            }
    }
}

// Custom Search Bar Component - Renamed to avoid conflict
struct VehicleSearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
        }
    }
}

// Preview with Sample Data
#Preview {
    AvailableVehicleView(trip: Trip(
        tripDate: Date(),
        startLocation: "New York",
        endLocation: "Los Angeles",
        distance: 3000,
        estimatedTime: 1800,
        assignedDriver: nil,
        TripStatus: .scheduled,
        assignedVehicle: nil
    )) { _ in
        print("Vehicle selected")
    }
}
