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
