//
//  addNewVehicleBack.swift
//  FMS
//
//  Created by Deepankar Garg on 15/02/25.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseFirestore
import Cloudinary

struct CloudinaryConfig {
    static let cloudName = "dztmc60fg"
    static let uploadPreset = "FMS-iNFOSYS"
    static let apiKey = "489983833873463"
}

struct CloudinaryResponse: Codable {
    let secureUrl: String
    
    enum CodingKeys: String, CodingKey {
        case secureUrl = "secure_url"
    }
}

struct DocumentUploadButton: View {
    let title: String
    @Binding var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingOptions = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).foregroundColor(.black)
            Button(action: { showingOptions = true }) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    VStack {
                        Image(systemName: "camera").font(.system(size: 24)).foregroundColor(.gray)
                        Text("Tap to upload").font(.caption).foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(RoundedRectangle(cornerRadius: 8).strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5])).foregroundColor(.gray.opacity(0.5)))
                }
            }
        }
        .confirmationDialog("Choose Photo", isPresented: $showingOptions) {
            Button("Take Photo") { sourceType = .camera; showingImagePicker = true }
            Button("Choose from Library") { sourceType = .photoLibrary; showingImagePicker = true }
            if selectedImage != nil { Button("Remove Photo", role: .destructive) { selectedImage = nil } }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerForVehicle(image: $selectedImage, sourceType: sourceType)
        }
    }
}


struct ImagePickerForVehicle: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerForVehicle
        
        init(_ parent: ImagePickerForVehicle) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}



struct VehicleTypeSelector: View {
    @Binding var vehicleType: String
    
    var body: some View {
        VStack {
            Text("Vehicle Type").foregroundColor(.black).frame(maxWidth: .infinity, alignment: .leading)
            Menu {
                ForEach(VehicleType.allCases, id: \.rawValue) { type in
                    Button(type.rawValue) { vehicleType = type.rawValue }
                }
            } label: {
                HStack {
                    Text(vehicleType.isEmpty ? "Select vehicle type" : vehicleType)
                        .foregroundColor(vehicleType.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: "chevron.down").foregroundColor(.gray)
                }
                .padding(15)
                .frame(maxWidth: .infinity)
                .background(Color(.white))
                .cornerRadius(10)
            }
        }
    }
}


struct AddNewVehicle: View {
    @Environment(\.presentationMode) var presentationMode // Used to go back to the home screen
    
    @State private var model = ""
    @State private var registrationNumber = ""
    @State private var vehicleType = ""
    @State private var fuelType = ""
    @State private var mileage = ""
    @State private var rcDocument: UIImage?
    @State private var insurance: UIImage?
    @State private var pollutionCertificate: UIImage?
    @State private var vehiclePhoto: UIImage?
    @State private var status = true
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var successAlert = false
    
    @State private var isInvalidRegistration: Bool = false
    @State private var isInvalidMileage: Bool = false
    
    var isSaveEnabled: Bool {
        return !model.isEmpty &&
        !registrationNumber.isEmpty &&
        !vehicleType.isEmpty &&
        !fuelType.isEmpty &&
        !mileage.isEmpty &&
        rcDocument != nil &&
        insurance != nil &&
        pollutionCertificate != nil &&
        vehiclePhoto != nil
    }
    
    func validateRegistrationNumber(_ input: String) {
        // Ensure input is capitalized
        let uppercaseInput = input.uppercased()

        // Limit input to 10 characters
        if uppercaseInput.count > 10 {
            registrationNumber = String(uppercaseInput.prefix(10)) // Trim to 10 characters
            isInvalidRegistration = true
        } else {
            registrationNumber = uppercaseInput
            isInvalidRegistration = false
        }
    }



       func validateMileage(_ input: String) {
           let numberCharacterSet = CharacterSet.decimalDigits
           if input.rangeOfCharacter(from: numberCharacterSet.inverted) != nil {
               isInvalidMileage = true
           } else {
               isInvalidMileage = false
           }
       }

        
        

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                VehicleFormField(title: "Model", placeholder: "Enter vehicle model", text: $model)
                VehicleFormField(title: "Registration Number", placeholder: "Enter registration number", text: $registrationNumber, keyboardType: .numberPad)
                               .onChange(of: registrationNumber) { newValue in
                                   validateRegistrationNumber(newValue)
                               }
                           if isInvalidRegistration {
                               Text("Invalid Registration Number")
                                   .foregroundColor(.red)
                                   .font(.caption)
                           }
                VehicleTypeSelector(vehicleType: $vehicleType)
                FuelTypeSelector(fuelType: $fuelType)
                VehicleFormField(title: "Mileage", placeholder: "Enter current mileage", text: $mileage, keyboardType: .numberPad)
                                .onChange(of: mileage) { newValue in
                                    validateMileage(newValue)
                                }
                            if isInvalidMileage {
                                Text("Invalid Mileage")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                
                Section {
                    DocumentUploadButton(title: "RC Document", selectedImage: $rcDocument)
                    DocumentUploadButton(title: "Insurance", selectedImage: $insurance)
                    DocumentUploadButton(title: "Pollution Certificate", selectedImage: $pollutionCertificate)
                    DocumentUploadButton(title: "Vehicle Photo", selectedImage: $vehiclePhoto)
                }
            }
            .padding()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Add Vehicle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create") { saveVehicle() }.foregroundColor(.blue).disabled(!isSaveEnabled)
                    .opacity((!isSaveEnabled) ? 0.5 : 1)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $successAlert) {
            Alert(
                title: Text("Success"),
                message: Text("Vehicle added successfully!"),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss() // Go back to the home screen
                }
            )
        }
    }
    
    private func saveVehicle() {
        if model.isEmpty || registrationNumber.isEmpty || vehicleType.isEmpty || fuelType.isEmpty || mileage.isEmpty ||
            rcDocument == nil || insurance == nil || pollutionCertificate == nil || vehiclePhoto == nil {
            
            alertMessage = "All fields and images are required."
            showAlert = true
            return
        }

        let db = Firestore.firestore()
        let vehicleRef = db.collection("vehicles").document()

        let newVehicle = Vehicle(
            type: VehicleType(rawValue: vehicleType) ?? .truck,
            model: model,
            registrationNumber: registrationNumber,
            fuelType: FuelType(rawValue: fuelType) ?? .petrol,
            mileage: Int(mileage) ?? 0,
            rc: "",
            vehicleImage: "",
            insurance: "",
            pollution: "",
            status: status
        )

        let group = DispatchGroup()
        var uploadedURLs: [String: String] = [:]

        let imagesToUpload: [(UIImage?, String)] = [
            (vehiclePhoto, "vehiclePhoto"),
            (rcDocument, "rcDocument"),
            (insurance, "insurance"),
            (pollutionCertificate, "pollutionCertificate")
        ]

        for (image, fieldName) in imagesToUpload {
            if let image = image {
                group.enter()
                uploadImageToCloud(image) { url in
                    if let url = url {
                        uploadedURLs[fieldName] = url
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            newVehicle.vehicleImage = uploadedURLs["vehiclePhoto"] ?? ""
            newVehicle.rc = uploadedURLs["rcDocument"] ?? ""
            newVehicle.insurance = uploadedURLs["insurance"] ?? ""
            newVehicle.pollution = uploadedURLs["pollutionCertificate"] ?? ""

            vehicleRef.setData([
                "type": newVehicle.type.rawValue,
                "model": newVehicle.model,
                "registrationNumber": newVehicle.registrationNumber,
                "fuelType": newVehicle.fuelType.rawValue,
                "mileage": newVehicle.mileage,
                "rc": newVehicle.rc,
                "vehicleImage": newVehicle.vehicleImage,
                "insurance": newVehicle.insurance,
                "pollution": newVehicle.pollution,
                "status": true
            ]) { error in
                if let error = error {
                    print("Error adding vehicle: \(error)")
                    alertMessage = "Failed to save vehicle."
                    showAlert = true
                } else {
                    print("Vehicle saved successfully!")
                    successAlert = true // Show success alert
                }
            }
        }
    }
    
    func uploadImageToCloud(_ image: UIImage?, completion: @escaping (String?) -> Void) {
        guard let image = image, let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("⚠️ Failed to prepare image data")
            completion(nil)
            return
        }

        let url = URL(string: "https://api.cloudinary.com/v1_1/\(CloudinaryConfig.cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let filename = "\(UUID().uuidString).jpg"
        
        // Append image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Append upload preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(CloudinaryConfig.uploadPreset)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        print("Starting image upload, size: \(imageData.count) bytes")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("⚠️ Upload network error: \(error)")
                DispatchQueue.main.async {
                                completion(nil)
                            }
                            return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                        print("Upload HTTP status: \(httpResponse.statusCode)")
                        
                        if httpResponse.statusCode != 200 {
                            if let data = data, let errorStr = String(data: data, encoding: .utf8) {
                                print("⚠️ Cloudinary error response: \(errorStr)")
                            }
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                            return
                        }
                    }

            if let data = data {
                        do {
                            let json = try JSONDecoder().decode(CloudinaryResponse.self, from: data)
                            print("Successfully parsed Cloudinary response with URL: \(json.secureUrl)")
                            DispatchQueue.main.async {
                                completion(json.secureUrl)
                            }
                        } catch {
                            print("⚠️ Failed to decode Cloudinary response: \(error)")
                            if let responseString = String(data: data, encoding: .utf8) {
                                print("Raw response: \(responseString)")
                            }
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                        }
                    } else {
                        print("⚠️ No data received from Cloudinary")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }.resume()
    }
}

struct VehicleFormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack {
            Text(title).frame(maxWidth: .infinity, alignment: .leading)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding(15)
                .background(Color(.white))
                .cornerRadius(10)
        }
    }
}

struct FuelTypeSelector: View {
    @Binding var fuelType: String
    
    var body: some View {
        VStack {
            Text("Fuel Type").frame(maxWidth: .infinity, alignment: .leading)
            Menu {
                ForEach(FuelType.allCases, id: \.rawValue) { type in
                    Button(type.rawValue) { fuelType = type.rawValue }
                }
            } label: {
                HStack {
                    Text(fuelType.isEmpty ? "Select fuel type" : fuelType)
                        .foregroundColor(fuelType.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: "chevron.down").foregroundColor(.gray)
                }
                .padding(15)
                .background(Color(.white))
                .cornerRadius(10)
            }
        }
    }
}


#Preview {
    AddNewVehicle()
}

