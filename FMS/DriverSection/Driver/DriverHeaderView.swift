import SwiftUI
import FirebaseFirestore

struct DriverHeaderView: View {
    @State private var isAvailable: Bool = false
    @State private var driver: Driver?
    @State private var toggleDisabled: Bool = false
    let userName: String
    let tripID: String? // Accept tripID as a parameter (not @State)

    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 2) {
                    Text(userName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Professional Driver")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                HStack(spacing: 5) {
                    Text("Available")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Toggle("", isOn: toggleDisabled ? .constant(false) : $isAvailable)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                        .disabled(toggleDisabled)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .onAppear {
            fetchDriverData()
            checkDriverTripStatus()
            print("🟢 User UUID: \(userUUID ?? "No User UUID")")
            print("🟢 Trip ID: \(tripID ?? "No Trip")")
        }
        .onChange(of: isAvailable) { newValue in
            if !toggleDisabled {
                updateDriverStatus(newValue)
            } else {
                print("🚫 Toggle disabled, update blocked!")
                revertToggleState()
            }
        }
    }

    /// Fetch the driver's availability status from Firestore
    private func fetchDriverData() {
        let db = Firestore.firestore()
        guard let userUUID = userUUID else {
            print("❌ No user UUID found")
            return
        }

        db.collection("users").document(userUUID).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                DispatchQueue.main.async {
                    do {
                        let experience = Experience(rawValue: data["experience"] as? String ?? "") ?? .lessThanOne
                        let geoPreference = GeoPreference(rawValue: data["geoPreference"] as? String ?? "") ?? .plain
                        let vehiclePreference = VehicleType(rawValue: data["vehiclePreference"] as? String ?? "") ?? .car
                        let status = data["status"] as? Bool ?? false
                        let license = data["license"] as? String ?? "N/A"

                        self.driver = Driver(
                            name: data["name"] as? String ?? "Unknown",
                            email: data["email"] as? String ?? "",
                            phone: data["phone"] as? String ?? "",
                            experience: experience,
                            license: license,
                            geoPreference: geoPreference,
                            vehiclePreference: vehiclePreference,
                            status: status
                        )

                        self.isAvailable = status
                        print("✅ Driver status: \(self.isAvailable)")

                    } catch {
                        print("❌ Error decoding driver: \(error.localizedDescription)")
                    }
                }
            } else {
                print("❌ Error fetching driver data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    /// Check if the driver has an **active (`inProgress`) trip**
    private func checkDriverTripStatus() {
        guard let userUUID = userUUID else {
            print("❌ No user UUID found")
            return
        }

        let db = Firestore.firestore()
        db.collection("trips")
            .whereField("assignedDriver.id", isEqualTo: userUUID) // 🔍 Ensure Firestore matches the correct field
            .whereField("TripStatus", isEqualTo: TripStatus.inprogress.rawValue)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error checking trip status: \(error.localizedDescription)")
                    return
                }

                if let documents = snapshot?.documents, !documents.isEmpty {
                    // Driver has an active trip, disable the toggle
                    DispatchQueue.main.async {
                        self.toggleDisabled = true
                        print("🚫 Toggle Disabled (Driver has an active trip)")
                    }
                } else {
                    // No active trip, allow toggle
                    DispatchQueue.main.async {
                        self.toggleDisabled = false
                        print("✅ Toggle Enabled (No active trip)")
                    }
                }
            }
    }

    /// Update the driver's availability status in Firestore
    private func updateDriverStatus(_ status: Bool) {
        guard let userUUID = userUUID else {
            print("❌ No user UUID found")
            return
        }

        guard let driverData = self.driver, driverData.status != status else {
            print("⚠️ No change in status. Skipping update.")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userUUID).updateData(["status": status]) { error in
            if let error = error {
                print("❌ Error updating driver status: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.driver?.status = status
                    print("✅ Driver status updated successfully to: \(status)")
                }
            }
        }
    }

    /// Revert the toggle state if the update is blocked
    private func revertToggleState() {
        DispatchQueue.main.async {
            if let driverData = self.driver {
                self.isAvailable = driverData.status
                print("🔄 Reverted isAvailable to: \(self.isAvailable)")
            }
        }
    }
}

#Preview {
    DriverHeaderView(userName: "Jayash", tripID: "123456") // ✅ Correct preview initialization
}
