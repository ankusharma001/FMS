import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @State private var userData: [String: Any] = [:]
    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    @State private var licenseImageUrl = ""
    @State private var isEditing = false
    @State private var isShowingEditProfile = false
    @State private var name = "Raj Chaudhary"
    @State private var email = "raj@gmail.com"
    @State private var phone = "+91 8235205048"
    @State private var experience = "5 Years"
    @State private var vehicleType = "Heavy Truck"
    @State private var specializedTerrain = "Mountain, Highway"
   
    
    // Logout related state variables
    @State private var showLogoutAlert = false
    @State private var isLoggedOut = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 90, height: 90)
                            .shadow(radius: 5)
                        
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.blue)
                    }
                    
                    // Name and Title
                    VStack(spacing: 5) {
                        Text(userData["name"] as? String ?? name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Professional Driver")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Contact Information
                    CardView(title: "Contact Information") {
                        InfoRow(icon: "envelope.fill", title: "Email", value: email)
                        InfoRow(icon: "phone.fill", title: "Phone", value: phone)
                    }
                    
                    // License Section
                    CardView(title: "License Information") {
<<<<<<< HEAD
                        
                       
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Driver's License")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 180)
                                    .cornerRadius(12)
                                    .overlay(
                                        Image("license_image")
                                            .resizable()
                                            .scaledToFit()
=======
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Driver's License")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)

                                    ZStack {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
>>>>>>> a5f7252cc83c9e4e6c87d85591dc3842ad7f8e0a
                                            .frame(height: 180)
                                            .cornerRadius(12)
                                        
                                        AsyncImage(url: URL(string: licenseImageUrl)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView() // Show a loading indicator
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 180)
                                                    .cornerRadius(12)
                                            case .failure:
                                                Image(systemName: "photo") // Fallback image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 180)
                                                    .foregroundColor(.gray)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                }
                            }
                    
                    // Driver Details
                    CardView(title: "Experience & Expertise") {
                        InfoRow(icon: "clock.fill", title: "Experience", value: experience)
                        InfoRow(icon: "car.fill", title: "Vehicle Type", value: vehicleType)
                        InfoRow(icon: "map.fill", title: "Specialized Terrain", value: specializedTerrain)
                    }
                    
                    // Logout Button
                    Button(action: {
                        print("Logout button tapped")
                        showLogoutAlert = true
                    }) {
                        Text("Logout")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .background(Color.gray.opacity(0.05))
            .onAppear(perform: fetchUserProfile)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingEditProfile.toggle() }) {
                        Text("Edit")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .sheet(isPresented: $isShowingEditProfile) {
                EditProfileView(name: $name, phone: $phone)
            }
            // Logout confirmation alert
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .destructive(Text("Logout"), action: {
                        logoutUser()
                    }),
                    secondaryButton: .cancel()
                )
            }
        }
        // Full screen cover to show the LoginView when logged out
        .fullScreenCover(isPresented: $isLoggedOut, content: {
            LoginView()
        })
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
                    phone = userData["phone"] as? String ?? phone
                    email = userData["email"] as? String ?? email
                    name = userData["name"] as? String ?? name
//                    licenseImageURL = userData["license"] as? String ?? licenseImageURL
                    experience = userData["experience"] as? String ?? experience
                    vehicleType = userData["vehiclePreference"] as? String ?? vehicleType
                    specializedTerrain = userData["geoPreference"] as? String ?? specializedTerrain
                    
                    if let licenseUrl = userData["licenseImageUrl"] as? String {
                                        self.licenseImageUrl = licenseUrl
                                    } else {
                                        // If not in the user document, check if there's a driverId that we can use to fetch from drivers collection
                                        if let driverId = userData["driverId"] as? String {
                                            self.fetchDriverLicenseImage(driverId: driverId)
                                        } else {
                                            // If no driverId, try using the userUUID to fetch from drivers collection
                                            self.fetchDriverLicenseImage(driverId: userUUID)
                                        }
                                    }
                }
            } else {
                print("User not found")
            }
        }
    }
    
    func fetchDriverLicenseImage(driverId: String) {
        let db = Firestore.firestore()
        db.collection("drivers").document(driverId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching license data: \(error)")
            } else if let snapshot = snapshot, snapshot.exists {
                DispatchQueue.main.async {
                    if let licenseUrl = snapshot.get("licenseImageUrl") as? String {
                        self.licenseImageUrl = licenseUrl
                        print("License image URL retrieved: \(licenseUrl)")
                    } else {
                        print("No license image URL found in driver document")
                    }
                }
            } else {
                print("Driver document not found")
            }
        }
    }
    
    func logoutUser() {
        // Remove user data from UserDefaults
        UserDefaults.standard.removeObject(forKey: "loggedInUserUUID")
        print("User UUID removed from UserDefaults")
        
        // Trigger redirection to the LoginView
        isLoggedOut = true
        print("Redirecting to login screen...")
    }
}

// MARK: - Edit Profile Modal
struct EditProfileView: View {
    @Binding var name: String
    @Binding var phone: String
    @Environment(\.presentationMode) var presentationMode
    
    @State private var phoneNumber = ""
    @State private var initialName: String = ""
    @State private var initialPhone: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $name)
                        .onChange(of: name) { newValue in
                            let filtered = newValue.filter { $0.isLetter || $0.isWhitespace }
                            if filtered != newValue {
                                name = filtered
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: phoneNumber) { newValue in
                            phoneNumber = newValue.filter { $0.isNumber }
                            if phoneNumber.count > 10 {
                                phoneNumber = String(phoneNumber.prefix(10))
                            }
                        }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if phoneNumber.count == 10 {
                            phone = "+91 \(phoneNumber)"
                            saveProfile()
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            print("Phone number must be 10 digits")
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                initialName = name
                initialPhone = phone
                // Remove the "+91 " prefix if it exists
                if phone.hasPrefix("+91 ") {
                    phoneNumber = String(phone.dropFirst(4))
                } else {
                    phoneNumber = phone
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        return !name.isEmpty && !phoneNumber.isEmpty && phoneNumber.count == 10 && isFormModified
    }
    
    private var isFormModified: Bool {
        let currentPhone = phone.hasPrefix("+91 ") ? String(phone.dropFirst(4)) : phone
        return name != initialName || phoneNumber != currentPhone
    }
    
    func saveProfile() {
        guard let userUUID = UserDefaults.standard.string(forKey: "loggedInUserUUID") else {
            print("No user UUID found")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userUUID).updateData([
            "name": name,
            "phone": phone
        ]) { error in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
            } else {
                print("Profile updated successfully")
            }
        }
    }
    
}

// MARK: - Supporting Views
struct CardView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 15, weight: .medium))
            }
            Spacer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
