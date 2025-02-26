

//import SwiftUI
//import FirebaseFirestore
//
//struct ProfileView: View {
//    @State private var userData: [String: Any] = [:]
//    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
//    
//    @State private var isEditing = false
//    @State private var name = "John Anderson"
//    @State private var email = "john.anderson@company.com" // Read-only
//    @State private var phone = "+1 (555) 123-4567"
//    @State private var experience = "5 Years"
//    @State private var vehicleType = "Heavy Truck"
//    @State private var specializedTerrain = "Mountain, Highway"
//    @State private var licenseImage: UIImage? = nil // Placeholder for license image
//
//    var body: some View {
//        
//        
//        VStack(spacing: 20) {
//            // Centered Name at the Top
//            Text(userData["name"] as? String ?? "John Anderson")
//                .font(.largeTitle)
//                .bold()
//                .foregroundColor(.black)
//                .padding(.top, 20)
//
//            // Edit Button
//            Button(action: { isEditing.toggle() }) {
//                HStack {
//                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
//                    Text(isEditing ? "Save Changes" : "Edit Profile")
//                }
//                .font(.system(size: 16, weight: .bold))
//                .padding(.horizontal, 15)
//                .padding(.vertical, 8)
//                .background(Color.blue.opacity(0.2))
//                .cornerRadius(10)
//                .foregroundColor(.blue)
//            }
//
//            // Editable Fields (Name, Phone) + Read-Only Email
//            SectionCard {
//                ProfileRow(icon: "person.fill", title: "Name", value: $name, isEditable: isEditing)
//                ProfileRow(icon: "envelope.fill", title: "Email", value: .constant(email), isEditable: false) // Read-only
//                ProfileRow(icon: "phone.fill", title: "Phone", value: $phone, isEditable: isEditing)
//            }
//
//            // License Image Section
//            SectionCard {
//                VStack {
//                    Text("License Image")
//                        .bold()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    if let image = licenseImage {
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 150)
//                            .cornerRadius(8)
//                    } else {
//                        Rectangle()
//                            .fill(Color.gray.opacity(0.3))
//                            .frame(height: 150)
//                            .cornerRadius(8)
//                            .overlay(
//                                Text("No Image Available")
//                                    .foregroundColor(.gray)
//                            )
//                    }
//                }
//                .padding(.horizontal)
//            }
//
//            // Experience & Expertise
//            SectionCard {
//                ProfileRow(icon: "clock.fill", title: "Experience", value: .constant(experience), isEditable: false)
//                ProfileRow(icon: "car.fill", title: "Vehicle Type", value: .constant(vehicleType), isEditable: false)
//                ProfileRow(icon: "map.fill", title: "Specialized Terrain", value: .constant(specializedTerrain), isEditable: false)
//            }
//
//            Spacer()
//        }
//        .padding()
//        .background(Color.gray.opacity(0.1)) // Light gray background for better contrast
//        .navigationBarHidden(true) // Hide default navigation bar
//        .onAppear(
//            perform: fetchUserProfile
//        )
//    }
//    
//    func fetchUserProfile() {
//        guard let userUUID = userUUID else {
//            print("No user UUID found")
//            return
//        }
//        
//        print("User UUID: \(userUUID)")
//        let db = Firestore.firestore()
//        db.collection("users").document(userUUID).getDocument { (document, error) in
//            if let document = document, document.exists {
//                DispatchQueue.main.async {
//                    self.userData = document.data() ?? [:]
//                    phone = userData["phone"] as? String ?? "John Anderson"
//                    email = userData["email"] as? String ?? "John Anderson"
//                    experience = userData["experience"] as? String ?? "John Anderson"
//                    vehicleType = userData["selectedVehicle"] as? String ?? "John Anderson"
//                    specializedTerrain = userData["selectedTerrain"] as? String ?? "Plain"
//                }
//            } else {
//                print("User not found")
//            }
//        }
//    }
//}
//
//// Reusable Profile Row Component with SF Symbols
//struct ProfileRow: View {
//    var icon: String
//    var title: String
//    @Binding var value: String
//    var isEditable: Bool
//
//    var body: some View {
//        HStack {
//            Image(systemName: icon)
//                .foregroundColor(.blue)
//                .frame(width: 30)
//
//            Text(title)
//                .bold()
//                .frame(width: 120, alignment: .leading)
//                .foregroundColor(.black)
//
//            if isEditable {
//                TextField("Enter \(title)", text: $value)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//            } else {
//                Text(value)
//                    .foregroundColor(.gray)
//            }
//            Spacer()
//        }
//        .padding(.horizontal)
//    }
//}
//
//// Reusable Card Layout for Sections
//struct SectionCard<Content: View>: View {
//    let content: Content
//
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//
//    var body: some View {
//        VStack(spacing: 16) {
//            content
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 3)
//    }
//}
//
//// Preview
//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ProfileView()
//        }
//    }
//}

import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @State private var userData: [String: Any] = [:]
    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    
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
                                            .frame(height: 180)
                                            .cornerRadius(12)
                                    )
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
                    experience = userData["experience"] as? String ?? experience
                    vehicleType = userData["vehiclePreference"] as? String ?? vehicleType
                    specializedTerrain = userData["geoPreference"] as? String ?? specializedTerrain
                }
            } else {
                print("User not found")
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
