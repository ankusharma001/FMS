import SwiftUI
import FirebaseFirestore

struct AvailableDriverView: View {
    @Environment(\.dismiss) var dismiss  // Updated for better dismissal handling
    var trip: Trip
    var onDriverSelected: (Driver) -> Void

    @State private var drivers: [Driver] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText: String = ""
    @State private var selectedExperience: Experience? = nil
    @State private var selectedGeoPreference: GeoPreference? = nil

    var filteredDrivers: [Driver] {
        drivers.filter { driver in
            let matchesSearch = searchText.isEmpty || driver.name.localizedCaseInsensitiveContains(searchText)
            let matchesExperience = selectedExperience == nil || driver.experience == selectedExperience
            let matchesGeoPreference = selectedGeoPreference == nil || driver.geoPreference == selectedGeoPreference
            return matchesSearch && matchesExperience && matchesGeoPreference
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                SearchBarAvailable(text: $searchText, placeholder: "Search driver")

                // Filters
                HStack {
                    Picker("Experience", selection: $selectedExperience) {
                        Text("Experience").tag(Experience?.none)
                        Text("<1 Year").tag(Experience.lessThanOne)
                        Text("1-5 Years").tag(Experience.lessThanFive)
                        Text(">5 Years").tag(Experience.moreThanFive)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)

                    Picker("Geo Preference", selection: $selectedGeoPreference) {
                        Text("Preferences").tag(GeoPreference?.none)
                        Text("Hilly").tag(GeoPreference.hilly)
                        Text("Plain").tag(GeoPreference.plain)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                }
                .padding()
                Spacer()

                // Loading State
                if isLoading {
                    ProgressView("Loading available drivers...")
                        .padding()
                }
                // Error State
                else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                // No Data Found State
                else if filteredDrivers.isEmpty {
                    Spacer()
                    Text("No matching drivers found")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                // List of Drivers
                else {
                   
                    List(filteredDrivers) { driver in
                        Button(action: {
                            onDriverSelected(driver)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text(driver.name).bold()
                                    Text("Experience: \(driver.experience.rawValue)")
                                    Text(driver.geoPreference.rawValue)
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                    .opacity(driver.status ? 1.0 : 0.0)
                            }
                        }
                    }
                    .listStyle(.plain)  // Removes unnecessary styling
                }
            }
            .navigationTitle("Available Drivers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)  // Ensures black text
                }
            }
            .onAppear(perform: fetchDrivers)
        }
    }

    private func fetchDrivers() {
        isLoading = true
        errorMessage = nil

        let db = Firestore.firestore()
        db.collection("users")
            .whereField("role", isEqualTo: Role.driver.rawValue)
            .whereField("status", isEqualTo: true)
            .getDocuments { (snapshot, error) in
                isLoading = false

                if let error = error {
                    errorMessage = "Failed to load drivers: \(error.localizedDescription)"
                    return
                }

                self.drivers = snapshot?.documents.compactMap { document in
                    var driver = try? document.data(as: Driver.self)
                    driver?.id = document.documentID
                    return driver
                } ?? []
            }
    }
}

// Custom Search Bar Component
struct SearchBarAvailable: View {
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
    AvailableDriverView(trip: Trip(
        tripDate: Date(),
        startLocation: "New York",
        endLocation: "Los Angeles",
        distance: 3000,
        estimatedTime: 1800,
        assignedDriver: nil,
        TripStatus: .scheduled,
        assignedVehicle: nil
    )) { _ in
        print("Driver selected")
    }
}
//
//
////
////  AvailableDriverView.swift
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
//struct AvailableDriverView: View {
//    @Environment(\.presentationMode) var presentationMode
//    var trip: Trip
//    var onDriverSelected: (Driver) -> Void
//    @State private var drivers: [Driver] = []
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
//                        Text("Loading available drivers...")
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
//                            fetchDrivers()
//                        }
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                    }
//                    .padding()
//                } else if drivers.isEmpty {
//                    VStack {
//                        Image(systemName: "person.slash")
//                            .font(.largeTitle)
//                            .foregroundColor(.gray)
//                            .padding()
//                        Text("No available drivers found")
//                            .font(.headline)
//                        Text("All drivers are currently assigned to other trips")
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(.gray)
//                            .padding()
//                    }
//                    .padding()
//                } else {
//                    List(drivers) { driver in
//                        Button(action: {
//                            onDriverSelected(driver)
//                            presentationMode.wrappedValue.dismiss()
//                        }) {
//                            HStack {
//                                Image(systemName: "person.fill")
//                                    .foregroundColor(.blue)
//                                    .font(.system(size: 24))
//                                    .frame(width: 40, height: 40)
//                                    .background(Color.blue.opacity(0.1))
//                                    .clipShape(Circle())
//                                
//                                VStack(alignment: .leading, spacing: 4) {
//                                    Text(driver.name).bold()
//                                    Text(driver.email)
//                                        .font(.subheadline)
//                                        .foregroundColor(.gray)
//                                    HStack {
//                                        Text(driver.experience.rawValue)
//                                            .font(.caption)
//                                            .padding(.horizontal, 8)
//                                            .padding(.vertical, 2)
//                                            .background(experienceColor(driver.experience).opacity(0.2))
//                                            .cornerRadius(4)
//                                        
//                                        Text(driver.geoPreference.rawValue)
//                                            .font(.caption)
//                                            .padding(.horizontal, 8)
//                                            .padding(.vertical, 2)
//                                            .background(Color.green.opacity(0.2))
//                                            .cornerRadius(4)
//                                        
//                                        Text(driver.vehiclePreference.rawValue)
//                                            .font(.caption)
//                                            .padding(.horizontal, 8)
//                                            .padding(.vertical, 2)
//                                            .background(Color.orange.opacity(0.2))
//                                            .cornerRadius(4)
//                                    }
//                                }
//                                Spacer()
//                                Image(systemName: "checkmark.circle")
//                                    .foregroundColor(.green)
//                                    .opacity(driver.status ? 1.0 : 0.0)
//                            }
//                            .padding(.vertical, 4)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Available Drivers")
//            .onAppear(perform: fetchDrivers)
//        }
//    }
//    
//    private func experienceColor(_ experience: Experience) -> Color {
//        switch experience {
//        case .lessThanOne:
//            return .orange
//        case .lessThanFive:
//            return .blue
//        case .moreThanFive:
//            return .green
//        }
//    }
//
//    private func fetchDrivers() {
//        isLoading = true
//        errorMessage = nil
//        
//        let db = Firestore.firestore()
//        db.collection("users")
//            .whereField("role", isEqualTo: Role.driver.rawValue)
//            .whereField("status", isEqualTo: true)
//            .getDocuments { (snapshot, error) in
//                isLoading = false
//                
//                if let error = error {
//                    print("Error fetching drivers: \(error)")
//                    errorMessage = "Failed to load drivers: \(error.localizedDescription)"
//                    return
//                }
//                
//                guard let documents = snapshot?.documents, !documents.isEmpty else {
//                    print("No available drivers found")
//                    self.drivers = []
//                    return
//                }
//                
//                print("Found \(documents.count) driver documents")
//                
//                self.drivers = documents.compactMap { document -> Driver? in
//                    do {
//                        print("Parsing document: \(document.documentID)")
//                        var driver = try document.data(as: Driver.self)
//                        driver.id = document.documentID
//                        return driver
//                    } catch {
//                        print("Error decoding driver: \(error)")
//                        return nil
//                    }
//                }
//                
//                print("Successfully parsed \(self.drivers.count) drivers")
//            }
//    }
//}
//#Preview {
//    AvailableDriverView(trip: Trip(
//        tripDate: Date(),
//        startLocation: "New York",
//        endLocation: "Los Angeles",
//        distance: 3000,
//        estimatedTime: 1800,
//        assignedDriver: nil,
//        TripStatus: .scheduled,
//        assignedVehicle: nil
//    )) { _ in
//        print("Driver selected")
//    }
//}
