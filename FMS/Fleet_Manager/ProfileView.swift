import SwiftUI
import FirebaseFirestore
import AVFoundation

class SpeechManager: ObservableObject {
    static let shared = SpeechManager() // Singleton instance
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    @Published var isTextToSpeechEnabled = false
    
    private init() {}

    func speak(_ text: String) {
        guard isTextToSpeechEnabled else { return } // Only speak if enabled
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        speechSynthesizer.speak(utterance)
    }
    func stopSpeaking() {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
}

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
    @AppStorage("ttsEnabled") private var isSpeaking: Bool = false
    
    @StateObject private var speechManager = SpeechManager.shared
    
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
                    
                    Toggle("Enable Text-to-Speech", isOn: $speechManager.isTextToSpeechEnabled)
                                            .padding()
                                            .onChange(of: speechManager.isTextToSpeechEnabled) { isEnabled in
                                                if isEnabled {
                                                    speakProfileDetails()
                                                }
                                                else {
                                                    SpeechManager.shared.stopSpeaking()
                                                }
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
            .onAppear {
                            fetchUserProfile()
                        }

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
    
    func speakProfileDetails() {
            let name = userData["name"] as? String ?? "Unknown"
            let email = userData["email"] as? String ?? "Unknown"
            let phone = userData["phone"] as? String ?? "Unknown"
            let textToSpeak = "Fleet profile details. Name: \(name). Email: \(email). Phone: \(phone)"
            speechManager.speak(textToSpeak)
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
