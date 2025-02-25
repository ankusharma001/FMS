////
////  SwiftUIView.swift
////  FMS
////
////  Created by Aastik Mehta on 14/02/25.
////
//
//
//
//import SwiftUI
//
//import FirebaseFirestore
//
//struct AlertMessage: Identifiable {
//    let id = UUID()
//    let message: String
//}
//
//
//
//class FirestoreService {
//    private let db = Firestore.firestore()
//
//    // Function to add a new trip
//    func addTrip(trip: Trip, completion: @escaping (Result<Void, Error>) -> Void) {
//        do {
//            let tripRef = db.collection("trips").document(trip.id ?? UUID().uuidString)
//            try tripRef.setData(from: trip) { error in
//                if let error = error {
//                    completion(.failure(error))
//                } else {
//                    completion(.success(()))
//                }
//            }
//        } catch {
//            completion(.failure(error))
//        }
//    }
//}
//
//
//struct AddNewTripView: View {
//
//    @State private var alertMessage: AlertMessage?
//    @State private var fromLocation: String = ""
//    @State private var toLocation: String = ""
//    @State private var selectedGeoArea: String = "Select Area"
//    @State private var deliveryDate: Date = Date()
//    @State private var geoAreas = ["Area 1", "Area 2", "Area 3"]
//
//    @State private var isLoading = false
//
//
//    let firestoreService = FirestoreService()
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                Form {
//                    Section {
//                        TextField("Enter pickup location", text: $fromLocation)
//                        TextField("Enter destination", text: $toLocation)
//                    }
//
//                    Section {
//                        Picker(selection: $selectedGeoArea, label: Text(selectedGeoArea)) {
//                            ForEach(geoAreas, id: \.self) { area in
//                                Text(area).tag(area)
//                            }
//                        }
//                        .pickerStyle(MenuPickerStyle())
//                    }
//
//                    Section {
//                        DatePicker("Delivery Date", selection: $deliveryDate, displayedComponents: .date)
//                    }
//                }
//
//                if isLoading {
//                    ProgressView()
//                } else {
//                    Button(action: createTrip) {
//                        Text("Create Trip")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .foregroundColor(.white)
//                            .background(Color.blue)
//                            .cornerRadius(8)
//                    }
//                    .padding()
//                }
//
//                Spacer()
//            }
//            .alert(item: $alertMessage) { alert in
//                Alert(title: Text("Error"), message: Text(alert.message), dismissButton: .default(Text("OK")))
//            }
//            .navigationBarTitle("Add New Trip", displayMode: .inline)
//        }
//    }
//
//
//
//    private func createTrip() {
//        guard !fromLocation.isEmpty, !toLocation.isEmpty, selectedGeoArea != "Select Area" else {
//            alertMessage = AlertMessage(message: "Please fill all fields correctly.")
//
//            return
//        }
//
//        isLoading = true
//
//        let newTrip = Trip(
//            tripDate: deliveryDate,
//            startLocation: fromLocation,
//            endLocation: toLocation,
//            distance: 0.0,  // Distance calculation can be added later
//            estimatedTime: 0.0,
//            assignedDriver: nil, // You may allow selecting a driver
//            TripStatus: .scheduled
//        )
//
//        firestoreService.addTrip(trip: newTrip) { result in
//            isLoading = false
//            switch result {
//            case .success:
//                print("Trip added successfully!")
//            case .failure(let error):
//                alertMessage = AlertMessage(message: error.localizedDescription)
//
//            }
//        }
//    }
//}
//
//
//
//
//
//struct TripListView: View {
//    @State private var trips: [Trip] = []
//    private let db = Firestore.firestore()
//
//    var body: some View {
//        List(trips, id: \.id) { trip in
//            VStack(alignment: .leading) {
//                Text("From: \(trip.startLocation) → To: \(trip.endLocation)")
//                    .font(.headline)
//                Text("Status: \(trip.TripStatus.rawValue)")
//                    .font(.subheadline)
//            }
//        }
//        .onAppear(perform: fetchTrips)
//        .navigationTitle("Trips")
//    }
//
//    private func fetchTrips() {
//        db.collection("trips").getDocuments { snapshot, error in
//            guard let documents = snapshot?.documents, error == nil else {
//                print("Error fetching trips: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            self.trips = documents.compactMap { doc in
//                try? doc.data(as: Trip.self)
//            }
//        }
//    }
//}
//
//struct TripListView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        AddNewTripView()
//    }
//}
////
/////
//  SwiftUIView.swift
//  FMS
//
//  Created by Aastik Mehta on 14/02/25.
//


import SwiftUI
import FirebaseFirestore
import MapKit

struct AlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

class FirestoreService {
    private let db = Firestore.firestore()
    
    // Function to add a new trip
    func addTrip(trip: Trip, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let tripRef = db.collection("trips").document(trip.id ?? UUID().uuidString)
            try tripRef.setData(from: trip) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateVehicleTotalDistance(vehicleId: String, tripDistance: Double, completion: @escaping (Result<Void, Error>) -> Void) {
            // Calculate round trip distance
            let roundTripDistance = Int(tripDistance * 2)
            
            let vehicleRef = db.collection("vehicles").document(vehicleId)
            
            // Use transaction to safely update the total distance
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                let vehicleDocument: DocumentSnapshot
                do {
                    try vehicleDocument = transaction.getDocument(vehicleRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                // Get current total distance
                let currentTotalDistance = vehicleDocument.data()?["totalDistance"] as? Int ?? 0
                
                // Add the new round trip distance
                let newTotalDistance = currentTotalDistance + roundTripDistance
                
                // Update the document
                transaction.updateData(["totalDistance": newTotalDistance], forDocument: vehicleRef)
                
                return nil
            }) { (_, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
     
    func assignDriver(to trip: Trip, driver: Driver) { // assign driver function
        let tripRef = Firestore.firestore().collection("trips").document(trip.id!)
        let driverRef = Firestore.firestore().collection("drivers").document(driver.id!)

        trip.assignedDriver = driver
        driver.status = false
        driver.upcomingTrip = trip

        let batch = Firestore.firestore().batch()
        batch.updateData(["assignedDriver": driver.id!], forDocument: tripRef)
        batch.updateData(["status": false, "upcomingTrip": trip.id!], forDocument: driverRef)

        batch.commit { error in
            if let error = error {
                print("Error assigning driver: \(error.localizedDescription)")
            } else {
                print("Driver assigned successfully")
            }
        }
    }
    
    func assignVehicle(to trip: Trip, vehicle: Vehicle) { // assign vehicle function
        let tripRef = Firestore.firestore().collection("trips").document(trip.id!)
        let vehicleRef = Firestore.firestore().collection("vehicles").document(vehicle.id!)

        trip.assignedVehicle = vehicle
        vehicle.status = false // Mark the vehicle as unavailable

        let batch = Firestore.firestore().batch()
        batch.updateData(["assignedVehicle": vehicle.id!], forDocument: tripRef)
        batch.updateData(["status": false, "currentTrip": trip.id!], forDocument: vehicleRef)

        batch.commit { error in
            if let error = error {
                print("Error assigning vehicle: \(error.localizedDescription)")
            } else {
                print("Vehicle assigned successfully")
            }
        }
    }

}

struct AddNewTripView: View {
    @State private var showSuccessAlert = false
    @State private var alertMessage: AlertMessage?
    @State private var fromLocation: String = ""
    @State private var toLocation: String = ""
    @State private var selectedGeoArea: String = "Select Type"
    @State private var deliveryDate: Date = Date()
    @State private var geoAreas = ["Hilly", "Plain"]
    @State private var isLoading = false
    @State private var distance: Double = 0.0
    @State private var estimatedTime: Double = 0.0
    
    let firestoreService = FirestoreService()
    
    @StateObject private var fromLocationVM = LocationSearchViewModel()
    @StateObject private var toLocationVM = LocationSearchViewModel()
    
    var isSaveEnabled: Bool {
            return !fromLocation.isEmpty &&
                   !toLocation.isEmpty &&
                   !selectedGeoArea.isEmpty &&
                   deliveryDate >= Calendar.current.startOfDay(for: Date())
        }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("From")) {
                    LocationInputField(
                        text: $fromLocation, searchViewModel: fromLocationVM, placeholder: "Enter pickup location"
                    ) .font(.system(size: 12))
                        .frame(height: 46)
                        .padding(.vertical, -2)
//                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                        .overlay(HStack { Image(systemName: "mappin.and.ellipse").foregroundColor(.gray); Spacer() }
                            .padding(.leading, -10))
                }
                
                Section(header: Text("To")) {
                    LocationInputField(text: $toLocation, searchViewModel: toLocationVM, placeholder: "Enter destination")
                        .font(.system(size: 12))
                            .frame(height: 46)
                            .padding(.vertical, -2)
//                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                        .overlay(HStack { Image(systemName: "mappin.and.ellipse").foregroundColor(.gray); Spacer() }.padding(.leading, -10))
                }
                
                Section(header: Text("Terrain Type")) {
                    Picker(selection: $selectedGeoArea, label: Text(selectedGeoArea)) {
                        ForEach(geoAreas, id: \ .self) { area in
                            Text(area).tag(area)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Delivery Date")) {
                    DatePicker("Select Date", selection: $deliveryDate, in: Date()..., displayedComponents: .date)
                }
                
                Section(header: Text("Distance & Time")) {
                    Text("Distance: \(distance, specifier: "%.2f") km")
                    Text("Estimated Time: \(estimatedTime, specifier: "%.1f") days")
                }
            }
            
            VStack{
                
                if isLoading {
                    ProgressView()
                } else {
                    Button(action: createTrip) {
                        Text("Create Trip")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(17)
                    }
                    .padding()
                    .disabled(!isSaveEnabled)
                    .opacity((!isSaveEnabled) ? 0.5 : 1)
                }
            }
            Spacer()
        }
        .background(Color(.systemGray6))
        .alert(item: $alertMessage) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
        }
        .navigationBarTitle("Add New Trip", displayMode: .inline)
    }
    
    private func createTrip() {
        guard !fromLocation.isEmpty, !toLocation.isEmpty, selectedGeoArea != "Select Type" else {
            alertMessage = AlertMessage(title: "Error", message: "Please fill all fields correctly.")
            return
        }
        
        isLoading = true
        
        calculateDistance(from: fromLocation, to: toLocation) { calculatedDistance in
            DispatchQueue.main.async {
                self.distance = calculatedDistance
                self.estimatedTime = ceil(calculatedDistance / 250.0)
                
                let newTrip = Trip(
                    tripDate: deliveryDate,
                    startLocation: fromLocation,
                    endLocation: toLocation,
                    distance: Float(self.distance),
                    estimatedTime: Float(self.estimatedTime),
                    assignedDriver: nil,
                    TripStatus: .scheduled,
                    assignedVehicle: nil
                )
                
                firestoreService.addTrip(trip: newTrip) { result in
                    isLoading = false
                    switch result {
                    case .success:
                                    // When a vehicle is assigned, update its total distance
                                    if let vehicleId = newTrip.assignedVehicle?.id {
                                        self.firestoreService.updateVehicleTotalDistance(vehicleId: vehicleId,
                                                                                        tripDistance: calculatedDistance) { updateResult in
                                            switch updateResult {
                                            case .success:
                                                self.alertMessage = AlertMessage(title: "Success",
                                                    message: "Trip added and vehicle distance updated successfully!")
                                            case .failure(let error):
                                                self.alertMessage = AlertMessage(title: "Warning",
                                                    message: "Trip added but failed to update vehicle distance: \(error.localizedDescription)")
                                            }
                                        }
                                    } else {
                                        self.alertMessage = AlertMessage(title: "Done", message: "Trip added successfully!")
                                    }
                                case .failure(let error):
                                    self.alertMessage = AlertMessage(title: "Error", message: error.localizedDescription)
                                }
                }
            }
        }
    }
    
    private func calculateDistance(from: String, to: String, completion: @escaping (Double) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(from) { fromPlacemarks, error in
            guard let fromPlacemark = fromPlacemarks?.first?.location else {
                completion(0.0)
                return
            }
            
            geocoder.geocodeAddressString(to) { toPlacemarks, error in
                guard let toPlacemark = toPlacemarks?.first?.location else {
                    completion(0.0)
                    return
                }
                
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: fromPlacemark.coordinate))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: toPlacemark.coordinate))
                request.transportType = .automobile
                
                let directions = MKDirections(request: request)
                directions.calculate { response, error in
                    if let route = response?.routes.first {
                        completion(route.distance / 1000) // Convert meters to kilometers
                    } else {
                        completion(0.0)
                    }
                }
            }
        }
    }
}


struct TripListView: View {
    @State private var trips: [Trip] = []
        private let db = Firestore.firestore()

        var body: some View {
            NavigationView {
                List(trips) { trip in
                    NavigationLink(destination: TripDetailsView(trip: trip)) {
                        VStack(alignment: .leading) {
                            Text("From: \(trip.startLocation) → To: \(trip.endLocation)")
                                .font(.headline)
                            Text("Status: \(trip.TripStatus.rawValue)")
                                .font(.subheadline)
                        }
                    }
                }
                .onAppear(perform: fetchTrips)
                .navigationTitle("Trips")
            }
        }

    private func fetchTrips() {
        db.collection("trips").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching trips: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.trips = documents.compactMap { doc in
                do {
                    return try doc.data(as: Trip.self)  // Convert Firestore document to Trip
                } catch {
                    print("Error decoding trip: \(error.localizedDescription)")
                    return nil
                }
            }
        }
    }

}


struct TripListView_Previews: PreviewProvider {
    static var previews: some View {
       
        AddNewTripView()
        
    }
}
