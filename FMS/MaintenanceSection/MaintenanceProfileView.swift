//
//  MaintenanceProfileView.swift
//  FMS
//
//  Created by Vansh Sharma on 20/02/25.
//

import SwiftUI
import FirebaseFirestore

struct MaintenanceProfileView: View {
    @State private var userData: [String: Any] = [:]
    @State private var userUUID: String? = UserDefaults.standard.string(forKey: "loggedInUserUUID")
    
    @State private var isShowingEditProfile = false
    @State private var name = "John Smith"
    @State private var email = "john@maintenance.com"
    @State private var phone = "+91 9876543210"
    
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
                        
                        Image(systemName: "wrench.and.screwdriver.fill")
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
                        
                        Text("Maintenance Personnel")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Contact Information
                    MaintenanceCardView(title: "Contact Information") {
                        MaintenanceInfoRow(icon: "envelope.fill", title: "Email", value: email)
                        MaintenanceInfoRow(icon: "phone.fill", title: "Phone", value: phone)
                    }
                    
                    // Maintenance Statistics
                    MaintenanceCardView(title: "Work Statistics") {
                        MaintenanceInfoRow(icon: "checkmark.circle.fill", title: "Completed Services", value: "\(userData["completedServices"] as? Int ?? 24)")
                        MaintenanceInfoRow(icon: "clock.fill", title: "In Progress", value: "\(userData["inProgressServices"] as? Int ?? 3)")
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
                MaintenanceEditProfileView(name: $name, phone: $phone)
            }
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
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView()
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
        UserDefaults.standard.removeObject(forKey: "loggedInUserUUID")
        print("User UUID removed from UserDefaults")
        isLoggedOut = true
        print("Redirecting to login screen...")
    }
}

// MARK: - Edit Profile Modal
struct MaintenanceEditProfileView: View {
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
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                initialName = name
                initialPhone = phone
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
struct MaintenanceCardView<Content: View>: View {
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

struct MaintenanceInfoRow: View {
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

struct MaintenanceProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MaintenanceProfileView()
    }
}
