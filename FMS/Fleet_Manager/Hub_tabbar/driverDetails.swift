import SwiftUI
import _PhotosUI_SwiftUI
import FirebaseFirestore

struct DriverImageLoader: View {
    let imageUrl: String?
    
    var body: some View {
        if let imageUrl = imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .onAppear {
                            print("📷 Loading image...")
                        }
                case .success(let image):
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 220)
                        .cornerRadius(15)
                        .onAppear {
                            print("✅ Successfully loaded image")
                        }
                case .failure(let error):
                    placeholderImage
                        .onAppear {
                            print("❌ Failed to load image: \(error.localizedDescription)")
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .onAppear {
                print("📷 Attempting to load image from URL: \(imageUrl)")
            }
            .padding(.horizontal)
        } else {
            placeholderImage
                .onAppear {
                    print("⚠️ No valid image URL provided: \(imageUrl ?? "nil")")
                }
        }
    }
    
    private func formatImageUrl(_ rawUrl: String) -> String? {
            if rawUrl.isEmpty {
                print("⚠️ Empty image URL")
                return nil
            }
            
            // If the URL doesn't start with http or https, it might be a Firebase Storage reference
            if !rawUrl.hasPrefix("http") {
                // Replace YOUR-FIREBASE-PROJECT with your actual Firebase project ID
                let storageUrl = "https://firebasestorage.googleapis.com/v0/b/YOUR-FIREBASE-PROJECT.appspot.com/o/"
                let encodedPath = rawUrl.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? rawUrl
                return "\(storageUrl)\(encodedPath)?alt=media"
            }
            
            return rawUrl
        }
    
    private var placeholderImage: some View {
        Image(systemName: "photo.fill")
            .resizable()
            .scaledToFit()
            .frame(height: 220)
            .foregroundColor(.gray)
            .opacity(0.5)
            .padding(.horizontal)
    }
}

struct DriverDetails: View {
    let driver: Driver // Change from User to Driver

       var body: some View {
           AddDriverView(user: driver) // Pass driver instead of user
       }
}

struct AddDriverView: View {
    let user: Driver
    

    @State private var name: String
    @State private var email: String
    @State private var contactNumber: String
    @State private var licenseNumber: String = ""
    @State private var experience: String = ""
    @State private var licenseImageURL: String
    @State private var selectedVehicle: String = "Truck"
    @State private var selectedTerrain: String = "Hilly"

    @State private var isEditing: Bool = false
    @State private var showAlert: Bool = false
    @State private var showImagePicker: Bool = false
    @State private var selectedImageItem: PhotosPickerItem? = nil
    @State private var licenseImageurl:  UIImage?
    
    @State private var licenseimage: String  = ""
    
    
    @State private var isInvalidContactNumber: Bool = false
    
    @State private var isInvalidName: Bool = false
    @State private var isInvalidEmail: Bool = false
    
    @State private var initialName: String = ""
        @State private var initialEmail: String = ""
        @State private var initialContactNumber: String = ""
        @State private var initialLicenseNumber: String = ""
        @State private var initialVehicle: String = ""
        @State private var initialTerrain: String = ""
        @State private var initialLicenseImageurl : UIImage?

    var hasChanges: Bool {
           return name != initialName ||
                  email != initialEmail ||
                  contactNumber != initialContactNumber ||
                  licenseNumber != initialLicenseNumber ||
                  selectedVehicle != initialVehicle ||
                  selectedTerrain != initialTerrain ||
                  licenseImageurl !== initialLicenseImageurl
       }

        
    

    private let db = Firestore.firestore()

    init(user: Driver) {
        self.user = user
        _name = State(initialValue: user.name)
        _email = State(initialValue: user.email)
        _contactNumber = State(initialValue: user.phone)
        _licenseImageURL = State(initialValue: user.license)
        _selectedVehicle = State(initialValue: user.vehiclePreference.rawValue)
        _selectedTerrain = State(initialValue: user.geoPreference.rawValue)

        if let driverId = user.id {
            fetchDriverLicenseImage(driverId: driverId)  // Fetch the license image URL
        }
    }


    
    func validateContactNumber(_ input: String) {
           // Ensure the input only contains numbers and limit the length to 10 digits
           let numberCharacterSet = CharacterSet.decimalDigits
           if input.rangeOfCharacter(from: numberCharacterSet.inverted) != nil || input.count > 10 {
               isInvalidContactNumber = true
           } else {
               isInvalidContactNumber = false
           }
       }
    
    func validateName(_ input: String) {
          let allowedCharacterSet = CharacterSet.letters.union(CharacterSet.whitespaces)
          if input.rangeOfCharacter(from: allowedCharacterSet.inverted) != nil {
              isInvalidName = true
          } else {
              isInvalidName = false
          }
      }
    func validateEmail(_ input: String) {
           let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
           let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
           isInvalidEmail = !predicate.evaluate(with: input)
       }
    var body: some View {
        Form {
            Button(action: {
                print("user id in driver details : \(String(describing: user.id)) \(String(describing: licenseimage))")
            }) {
                Text("Fetch License Image")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Section(header: Text("Name")) {
                TextField("Enter Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!isEditing)
                    .onChange(of: name) { newValue in
                        validateName(newValue)
                    }
                
                if isInvalidName {
                    Text("Invalid Name. Only letters and spaces allowed.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Section(header: Text("Email")) {
                TextField("Enter Email", text: $email)
                    .disabled(!isEditing)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onChange(of: email) { newValue in
                        validateEmail(newValue)
                    }
                
                if isInvalidEmail {
                    Text("Invalid Email Address")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Section(header: Text("Contact Number")) {
                TextField("Enter Contact Number", text: $contactNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!isEditing)
                    .keyboardType(.numberPad)
                    .onChange(of: contactNumber) { newValue in
                        validateContactNumber(newValue)
                    }
                
                if isInvalidContactNumber {
                    Text("Invalid Contact Number")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            //            Section(header: Text("License Number")) {
            //                TextField("Enter License Number", text: $licenseNumber)
            //                    .textFieldStyle(RoundedBorderTextFieldStyle())
            //                    .disabled(!isEditing)
            //            }
            
//            Section(header: Text("License Photo")) {
//                ZStack {
//                    DriverImageLoader(imageUrl: licenseimage)
//                        .onTapGesture {
//                            showImagePicker.toggle()
//                        }
//                }
//                .disabled(!isEditing)
//            }
                
                Section(header: Text("Vehicle Preference")) {
                    TextField("Enter Vehicle Type", text: $selectedVehicle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)
                }
                
                Section(header: Text("Terrain Preference")) {
                    TextField("Enter Terrain Type", text: $selectedTerrain)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isEditing)
                }
            }.onAppear {
                if let driverId = user.id {
                    fetchDriverLicenseImage(driverId: driverId)
                }
                print("driver image url : > \(licenseimage)")
            }
            .photosPicker(
                isPresented: $showImagePicker,
                selection: $selectedImageItem,
                matching: .images
            )
            .onChange(of: selectedImageItem) { newItem in
                Task {
                    if let newItem = newItem, let data = try? await newItem.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            licenseImageurl = uiImage
                        }
                    }
                }
            }
            //        .navigationBarTitle("Driver Details", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        if hasChanges {
                            showAlert = true
                        } else {
                            isEditing = false
                        }
                    } else {
                        isEditing = true
                        saveInitialValues()
                    }
                }.disabled(isEditing && !hasChanges)
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Confirm Changes"),
                    message: Text("Are you sure you want to save the changes?"),
                    primaryButton: .default(Text("Yes"), action: {
                        updateDriverDetails()
                        isEditing = false
                    }),
                    secondaryButton: .cancel(Text("No"))
                )
            }
            
            
        }
        func saveInitialValues() {
            initialName = name
            initialEmail = email
            initialContactNumber = contactNumber
            initialLicenseNumber = licenseNumber
            initialVehicle = selectedVehicle
            initialTerrain = selectedTerrain
//            initialLicenseImageurl = licenseImage
        }
        
        /// Updates driver details in Firestore
       func updateDriverDetails() {
            guard let userId = user.id else { return }
            
            let driverData: [String: Any] = [
                "name": name,
                "email": email,
                "phone": contactNumber,
                "licenseNumber": licenseNumber,
                "selectedVehicle": selectedVehicle,
                "selectedTerrain": selectedTerrain
            ]
            
            db.collection("users").document(userId).updateData(driverData) { error in
                if let error = error {
                    print("Error updating driver details: \(error.localizedDescription)")
                } else {
                    print("Driver details updated successfully")
                }
            }
        }
    
    func fetchDriverLicenseImage(driverId: String) {
        db.collection("drivers").document(driverId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching license data: \(error)")
            } else if let snapshot = snapshot, snapshot.exists {
                print("📄 Driver document data: \(snapshot.data() ?? [:])")
                DispatchQueue.main.async {
                    if let licenseUrl = snapshot.get("licenseImageUrl") as? String {
                        self.licenseimage = licenseUrl
                        print("✅ License image URL retrieved: \(licenseUrl)")
                    } else {
                        print("⚠️ No license image URL found in driver document")
                    }
                }
            } else {
                print("❌ Driver document not found")
            }
        }

    }

    }


#Preview {
    NavigationView {
        DriverDetails(driver: Driver(
        
            name: "John Doe",
            email: "john.doe@example.com",
            phone: "1234567890",
            experience: .lessThanFive,

            license: "photo",
            geoPreference: .hilly,
            vehiclePreference: .car,
            status: true
        ))
    }
}
