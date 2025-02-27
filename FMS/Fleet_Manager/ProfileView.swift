//import SwiftUI
//import FirebaseFirestore
//
//struct FleetProfileView: View {
//    @State private var userData: [String: Any] = [:]
//    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
//    @State private var isEditing = false
//    @State private var animateEditIcon = false
//    
//    @State private var showAlert: Bool = false
//    @State private var showEditView = false
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                VStack {
//                    Image(systemName: "person.circle.fill")
//                        .resizable()
//                        .frame(width: 100, height: 100)
//                        .foregroundColor(.blue)
//                        .shadow(radius: 5)
//                        .padding(.top, 40)
//                    
//                    Text(userData["name"] as? String ?? "John Anderson")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .padding(.top, 8)
//                        .padding(.horizontal, 20)
//                        .multilineTextAlignment(.center)
//                        .background(isEditing ? Color.white : Color.clear)
//                        .cornerRadius(8)
//                        .shadow(radius: isEditing ? 2 : 0)
//                        .overlay(
//                            TextField("Enter Name", text: Binding(
//                                get: { userData["name"] as? String ?? "" },
//                                set: { userData["name"] = $0 }
//                            ))
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .frame(width: 300)
//                            .opacity(isEditing ? 1 : 0)
//                        )
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.bottom, 20)
//                
//                ContactInfoCard(isEditing: $isEditing, userData: $userData)
//                    .padding()
//                
//                Button(action: logoutUser) {
//                    Text("Log Out")
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.red)
//                        .cornerRadius(10)
//                        .padding(.horizontal, 20)
//                        .shadow(radius: 3)
//                }
//                .padding(.top, 20)
//                
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.gray.opacity(0.2))
//            .navigationBarTitle("Profile")
//           
//            .navigationBarItems(
//                    trailing: Button("Edit") {
//                        showEditView.toggle()
//                    }
//                )
//                .sheet(isPresented: $showEditView) {
//                    editfromfleetmanager(userData: $userData)
//                }
//            
//            .onAppear {
//                fetchUserProfile()
//            }
//        }
//    }
//    
//    func fetchUserProfile() {
//        guard let userUUID = userUUID else {
//            print("No user UUID found")
//            return
//        }
//        
//        let db = Firestore.firestore()
//        db.collection("users").document(userUUID).getDocument { (document, error) in
//            if let document = document, document.exists {
//                DispatchQueue.main.async {
//                    self.userData = document.data() ?? [:]
//                }
//            } else {
//                print("User not found")
//            }
//        }
//    }
//    
//    func logoutUser() {
//        UserDefaults.standard.removeObject(forKey: "loggedInUserUUID")
//        print("User logged out")
//    }
//}
//
//struct ContactInfoCard: View {
//    @Binding var isEditing: Bool
//    @Binding var userData: [String: Any]
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Contact Information")
//                .font(.headline)
//                .fontWeight(.bold)
//            
//            HStack {
//                Image(systemName: "phone.fill")
//                    .foregroundColor(.gray)
//                TextField("Enter Phone", text: Binding(
//                    get: { userData["phone"] as? String ?? "8235205048" },
//                    set: { userData["phone"] = $0 }
//                ))
////                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .background(Color.white)
//                .cornerRadius(8)
//                .disabled(!isEditing)
////                .shadow(radius: 2)
//            }
//            .padding(.vertical, 5)
//            
//            HStack {
//                Image(systemName: "envelope.fill")
//                    .foregroundColor(.gray)
//                Text(userData["email"] as? String ?? "raj@gmail.com") // Email remains uneditable
//            }
//            .padding(.vertical, 5)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 2)
//    }
//}
//
//#Preview {
//    FleetProfileView()
//}

import SwiftUI
import FirebaseFirestore

struct FleetProfileView: View {
    @State private var userData: [String: Any] = [:]
    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    
    @State private var isShowingEditProfile = false
    @State private var name = "Raj Chaudhary"
    @State private var email = "raj@gmail.com"
    @State private var phone = "+91 8235205048"
    
    // State for logout confirmation alert
    @State private var showLogoutAlert = false
    
    // State to trigger redirect to LoginView
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
                        
                        Text("Fleet Manager")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Contact Information
                    FleetCardView(title: "Contact Information") {
                        FleetInfoRow(icon: "envelope.fill", title: "Email", value: email)
                        FleetInfoRow(icon: "phone.fill", title: "Phone", value: phone)
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
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isShowingEditProfile.toggle() }) {
                        Text("Edit")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .sheet(isPresented: $isShowingEditProfile) {
                FleetEditProfileView(name: $name, phone: $phone)
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
                    print("User profile fetched: \(self.userData)")
                }
            } else {
                print("User not found or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func logoutUser() {
        // Remove user data from UserDefaults
        UserDefaults.standard.removeObject(forKey: "loggedInUserUUID")
        print("User UUID removed from UserDefaults")
        
        // Immediately trigger redirection to the LoginView
        isLoggedOut = true
        print("Redirecting to login screen...")
    }
}

// MARK: - Edit Profile Modal
struct FleetEditProfileView: View {
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
                            // Allow only letters and whitespace
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
        // Compare current values with the initial ones
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
struct FleetCardView<Content: View>: View {
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

struct FleetInfoRow: View {
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

struct FleetProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FleetProfileView()
    }
}
