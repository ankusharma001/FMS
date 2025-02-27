import SwiftUI
import FirebaseFirestore

struct TripDetailsView: View {
    let trip: Trip
    @State private var showDriverList = false
    @State private var showVehicleList = false
    @State private var showSuccessMessage = false
    @State private var successMessage = ""
    @State private var updatedTrip: Trip
    @Environment(\.presentationMode) var presentationMode
    
    init(trip: Trip) {
        self.trip = trip
        _updatedTrip = State(initialValue: trip)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Trip details card
                VStack(alignment: .leading, spacing: 12) {
                    Group {
                        Text("From")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(updatedTrip.startLocation)
                            .font(.body)
                            .bold()
                            .fixedSize(horizontal: false, vertical: true) // Allow text wrapping
                    }
                    
                    Divider()
                    
                    Group {
                        Text("To")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(updatedTrip.endLocation)
                            .font(.body)
                            .bold()
                            .fixedSize(horizontal: false, vertical: true) // Allow text wrapping
                    }
                    
                    Divider()
                    
                    Text("Status: \(updatedTrip.TripStatus.rawValue)")
                        .font(.body)
                        .bold()
                        .foregroundColor(getStatusColor(updatedTrip.TripStatus))
                    
                    Divider()
                    
                    Text("Distance: \(updatedTrip.distance, specifier: "%.2f") km")
                        .font(.body)
                    
                    Divider()
                    
                    Text("Estimated Time: \(updatedTrip.estimatedTime, specifier: "%.2f") mins")
                        .font(.body)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Driver Information Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Driver Information")
                        .font(.headline)
                    
                    if let driver = updatedTrip.assignedDriver {
                        HStack(spacing: 12) {
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(driver.name).bold()
                                Text(driver.email)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("Experience: \(driver.experience.rawValue)")
                                    .font(.caption)
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle")
                                .foregroundColor(.gray)
                                .frame(width: 24, height: 24)
                            
                            Text("Not Assigned")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Vehicle Information Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vehicle Information")
                        .font(.headline)
                    
                    if let vehicle = updatedTrip.assignedVehicle {
                        HStack(spacing: 12) {
                            Image(systemName: "car.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(vehicle.model) (\(vehicle.type.rawValue))")
                                    .bold()
                                Text("Reg: \(vehicle.registrationNumber)")
                                    .font(.caption)
                                Text("Fuel: \(vehicle.fuelType.rawValue)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            Image(systemName: "car.circle")
                                .foregroundColor(.gray)
                                .frame(width: 24, height: 24)
                            
                            Text("Not Assigned")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Buttons Section
                VStack(spacing: 16) {
                    // Buttons for Assigning Driver and Vehicle
                    HStack(spacing: 16) {
                        Button(action: { showDriverList = true }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text(updatedTrip.assignedDriver == nil ? "Assign Driver" : "Change Driver")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }

                        Button(action: { showVehicleList = true }) {
                            HStack {
                                Image(systemName: "car.fill")
                                Text(updatedTrip.assignedVehicle == nil ? "Assign Vehicle" : "Change Vehicle")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Start Trip Button (enabled only when both driver and vehicle are assigned)
                    if updatedTrip.TripStatus == .scheduled && updatedTrip.assignedDriver != nil && updatedTrip.assignedVehicle != nil {
                        Button(action: { startTrip() }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Create Trip")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray6))
        .navigationTitle("Trip Details")
        .sheet(isPresented: $showDriverList) {
            AvailableDriverView(trip: trip) { assignedDriver in
                assignDriver(assignedDriver)
            }
        }
        .sheet(isPresented: $showVehicleList) {
            AvailableVehicleView(trip: trip) { assignedVehicle in
                assignVehicle(assignedVehicle)
            }
        }
        .alert(isPresented: $showSuccessMessage) {
            Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            fetchUpdatedTripData()
        }
        .onDisappear {
            if updatedTrip.TripStatus == .scheduled {
                removeDriverAndVehicle()
            }
        }
    }
    
    // Keep all existing functions unchanged
    private func getStatusColor(_ status: TripStatus) -> Color {
        switch status {
        case .scheduled: return .orange
        case .inprogress: return .blue
        case .completed: return .green
        }
    }
    
    private func fetchUpdatedTripData() {
        guard let tripId = trip.id else { return }
        
        let db = Firestore.firestore()
        db.collection("trips").document(tripId).getDocument { document, error in
            if let error = error {
                print("Error fetching trip data: \(error)")
                return
            }
            
            if let document = document, document.exists {
                if let updatedTrip = try? document.data(as: Trip.self) {
                    self.updatedTrip = updatedTrip
                }
            }
        }
    }

    private func assignDriver(_ driver: Driver) {
        guard let tripId = trip.id, let driverId = driver.id else { return }
        
        let db = Firestore.firestore()
        let tripRef = db.collection("trips").document(tripId)
        let driverRef = db.collection("users").document(driverId)
        
        if let previousDriver = updatedTrip.assignedDriver, let previousDriverId = previousDriver.id {
            let prevDriverRef = db.collection("users").document(previousDriverId)
            prevDriverRef.updateData([
                "status": true,
                "upcomingTrip": FieldValue.delete()
            ])
        }

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let driverSnapshot: DocumentSnapshot
            do {
                driverSnapshot = try transaction.getDocument(driverRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let driverData = driverSnapshot.data(),
                  let isAvailable = driverData["status"] as? Bool,
                  isAvailable else {
                errorPointer?.pointee = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Driver is no longer available"]
                )
                return nil
            }
            
            let tripReference = [
                "id": tripId,
                "startLocation": trip.startLocation,
                "endLocation": trip.endLocation,
                "tripDate": trip.tripDate
            ] as [String : Any]
            
            transaction.updateData([
                "status": false,
                "upcomingTrip": tripReference
            ], forDocument: driverRef)
            
            transaction.updateData([
                "assignedDriver": [
                    "id": driver.id!,
                    "name": driver.name,
                    "email": driver.email,
                    "phone": driver.phone,
                    "experience": driver.experience.rawValue
                ]
            ], forDocument: tripRef)
            
            return nil
        }) { (_, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                successMessage = "Failed to assign driver: \(error.localizedDescription)"
            } else {
                var updatedTripCopy = self.updatedTrip
                updatedTripCopy.assignedDriver = driver
                self.updatedTrip = updatedTripCopy
                
                successMessage = "Driver assigned successfully!"
                checkAndUpdateTripStatus()
            }
            showSuccessMessage = true
        }
    }

    private func assignVehicle(_ vehicle: Vehicle) {
        guard let tripId = trip.id, let vehicleId = vehicle.id else { return }
        
        let db = Firestore.firestore()
        
        let tripRef = db.collection("trips").document(tripId)
        let vehicleRef = db.collection("vehicles").document(vehicleId)
        
        if let previousVehicle = updatedTrip.assignedVehicle, let previousVehicleId = previousVehicle.id {
            let prevVehicleRef = db.collection("vehicles").document(previousVehicleId)
            prevVehicleRef.updateData(["status": true])
        }

        vehicleRef.getDocument { document, error in
            if let document = document, document.exists {
                if let currentDistance = document.data()?["totalDistance"] as? Int {
                    let newDistance = currentDistance + Int(updatedTrip.distance * 2);
                    
                    vehicleRef.updateData(["totalDistance": newDistance]) { error in
                        if let error = error {
                            print("Error updating totalDistance: \(error.localizedDescription)")
                        } else {
                            print("Successfully updated totalDistance to \(newDistance)")
                        }
                    }
                } else {
                    print("totalDistance field missing or invalid")
                }
            } else {
                print("Vehicle document not found: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let vehicleSnapshot: DocumentSnapshot
            do {
                vehicleSnapshot = try transaction.getDocument(vehicleRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let vehicleData = vehicleSnapshot.data(),
                  let isAvailable = vehicleData["status"] as? Bool,
                  isAvailable else {
                errorPointer?.pointee = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Vehicle is no longer available"]
                )
                return nil
            }
            
            transaction.updateData([
                "assignedVehicle": [
                    "id": vehicle.id!,
                    "type": vehicle.type.rawValue,
                    "model": vehicle.model,
                    "registrationNumber": vehicle.registrationNumber,
                    "fuelType": vehicle.fuelType.rawValue
                ]
            ], forDocument: tripRef)
            
            transaction.updateData([
                "status": false
            ], forDocument: vehicleRef)
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                successMessage = "Failed to assign vehicle: \(error.localizedDescription)"
            } else {
                var updatedTripCopy = self.updatedTrip
                updatedTripCopy.assignedVehicle = vehicle
                self.updatedTrip = updatedTripCopy
            
                successMessage = "Vehicle assigned successfully!"
                checkAndUpdateTripStatus()
            }
            showSuccessMessage = true
        }
    }
    
    private func checkAndUpdateTripStatus() {
        if updatedTrip.assignedDriver != nil && updatedTrip.assignedVehicle != nil && updatedTrip.TripStatus == .scheduled {
            successMessage += " Both driver and vehicle are now assigned. Trip is ready to Create!"
        }
    }
    
    private func startTrip() {
        guard let tripId = trip.id else { return }
        
        let db = Firestore.firestore()
        let tripRef = db.collection("trips").document(tripId)
        
        tripRef.updateData([
            "TripStatus": TripStatus.inprogress.rawValue
        ]) { error in
            if let error = error {
                print("Error starting trip: \(error)")
                successMessage = "Failed to Create trip: \(error.localizedDescription)"
            } else {
                var updatedTripCopy = self.updatedTrip
                updatedTripCopy.TripStatus = .inprogress
                
                self.updatedTrip = updatedTripCopy
                successMessage = "Trip Created successfully!"
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            showSuccessMessage = true
        }
    }
    
    private func removeDriverAndVehicle() {
        guard let tripId = trip.id else { return }
        
        let db = Firestore.firestore()
        let tripRef = db.collection("trips").document(tripId)
        var updates: [String: Any] = [:]
    
        if let driver = updatedTrip.assignedDriver, let driverId = driver.id {
            let driverRef = db.collection("users").document(driverId)
            driverRef.updateData([
                "status": true,
                "upcomingTrip": FieldValue.delete()
            ])
            updates["assignedDriver"] = FieldValue.delete()
        }
    
        if let vehicle = updatedTrip.assignedVehicle, let vehicleId = vehicle.id {
            let vehicleRef = db.collection("vehicles").document(vehicleId)
            vehicleRef.updateData(["status": true])
            updates["assignedVehicle"] = FieldValue.delete()
        }
    
        if !updates.isEmpty {
            tripRef.updateData(updates) { error in
                if let error = error {
                    print("Failed to reset trip assignments: \(error)")
                } else {
                    print("Trip assignments reset successfully")
                }
            }
        }
    }
}

struct TripDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailsView(trip: Trip(
            tripDate: Date(),
            startLocation: "123 Business Park, Los Angeles",
            endLocation: "456 Industrial Zone, San Francisco",
            distance: 150.5,
            estimatedTime: 120.0,
            assignedDriver: nil,
            TripStatus: .scheduled,
            assignedVehicle: nil
        ))
    }
}







//
//import SwiftUI
//
//import FirebaseFirestore
//
//
//struct TripDetailsView: View {
//    let trip: Trip
//    @State private var showDriverList = false
//    @State private var showVehicleList = false
//    @State private var showSuccessMessage = false
//    @State private var successMessage = ""
//    @State private var updatedTrip: Trip
//    
//    init(trip: Trip) {
//        self.trip = trip
//        _updatedTrip = State(initialValue: trip)
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Trip Details")
//                .font(.headline)
//                .padding()
//
//            VStack(alignment: .leading, spacing: 12) {
//                Text("From: \(updatedTrip.startLocation)")
//                    .font(.body)
//                    .bold()
//                Text("To: \(updatedTrip.endLocation)")
//                    .font(.body)
//                    .bold()
//                Text("Status: \(updatedTrip.TripStatus.rawValue)")
//                    .font(.body)
//                    .bold()
//                    .foregroundColor(getStatusColor(updatedTrip.TripStatus))
//                Text("Distance: \(updatedTrip.distance, specifier: "%.2f") km")
//                    .font(.body)
//                Text("Estimated Time: \(updatedTrip.estimatedTime, specifier: "%.2f") mins")
//                    .font(.body)
//            }
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//            .padding(.horizontal)
//            
//            // Driver Information Section
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Driver Information").font(.headline)
//                
//                if let driver = updatedTrip.assignedDriver {
//                    HStack {
//                        Image(systemName: "person.fill")
//                            .foregroundColor(.blue)
//                        VStack(alignment: .leading) {
//                            Text(driver.name).bold()
//                            Text(driver.email)
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                            Text("Experience: \(driver.experience.rawValue)")
//                                .font(.caption)
//                        }
//                    }
//                } else {
//                    HStack {
//                        Image(systemName: "person.circle")
//                            .foregroundColor(.gray)
//                        Text("Not Assigned")
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//            .padding(.horizontal)
//            
//            // Vehicle Information Section
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Vehicle Information").font(.headline)
//                
//                if let vehicle = updatedTrip.assignedVehicle {
//                    HStack {
//                        Image(systemName: "car.fill")
//                            .foregroundColor(.blue)
//                        VStack(alignment: .leading) {
//                            Text("\(vehicle.model) (\(vehicle.type.rawValue))").bold()
//                            Text("Reg: \(vehicle.registrationNumber)")
//                                .font(.caption)
//                            Text("Fuel: \(vehicle.fuelType.rawValue)")
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                        }
//                    }
//                } else {
//                    HStack {
//                        Image(systemName: "car.circle")
//                            .foregroundColor(.gray)
//                        Text("Not Assigned")
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//            .padding(.horizontal)
//
//            // Buttons for Assigning Driver and Vehicle
//            HStack(spacing: 16) {
//                Button(action: { showDriverList = true }) {
//                    HStack {
//                        Image(systemName: "person.fill")
//                        Text(updatedTrip.assignedDriver == nil ? "Assign Driver" : "Change Driver")
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//
//                Button(action: { showVehicleList = true }) {
//                    HStack {
//                        Image(systemName: "car.fill")
//                        Text(updatedTrip.assignedVehicle == nil ? "Assign Vehicle" : "Change Vehicle")
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//            }
//            .padding(.horizontal)
//            
//            // Start Trip Button (enabled only when both driver and vehicle are assigned)
//            if updatedTrip.TripStatus == .scheduled && updatedTrip.assignedDriver != nil && updatedTrip.assignedVehicle != nil {
//                Button(action: { startTrip() }) {
//                    HStack {
//                        Image(systemName: "play.fill")
//                        Text("Start Trip")
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//                .padding(.horizontal)
//            }
//
//            Spacer()
//        }
//        .navigationTitle("Trip Details")
//        .sheet(isPresented: $showDriverList) {
//            AvailableDriverView(trip: trip) { assignedDriver in
//                assignDriver(assignedDriver)
//            }
//        }
//        .sheet(isPresented: $showVehicleList) {
//            AvailableVehicleView(trip: trip) { assignedVehicle in
//                assignVehicle(assignedVehicle)
//            }
//        }
//        .alert(isPresented: $showSuccessMessage) {
//            Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
//        }
//        .onAppear {
//            fetchUpdatedTripData()
//        }
//    }
//    
//    private func getStatusColor(_ status: TripStatus) -> Color {
//        switch status {
//        case .scheduled: return .orange
//        case .inprogress: return .blue
//        case .completed: return .green
//        }
//    }
//    
//    private func fetchUpdatedTripData() {
//        guard let tripId = trip.id else { return }
//        
//        let db = Firestore.firestore()
//        db.collection("trips").document(tripId).getDocument { document, error in
//            if let error = error {
//                print("Error fetching trip data: \(error)")
//                return
//            }
//            
//            if let document = document, document.exists {
//                if let updatedTrip = try? document.data(as: Trip.self) {
//                    self.updatedTrip = updatedTrip
//                }
//            }
//        }
//    }
//
//    private func assignDriver(_ driver: Driver) {
//        guard let tripId = trip.id, let driverId = driver.id else { return }
//        
//        let db = Firestore.firestore()
//        let tripRef = db.collection("trips").document(tripId)
//        let driverRef = db.collection("users").document(driverId)
//        
//        if let previousDriver = updatedTrip.assignedDriver, let previousDriverId = previousDriver.id {
//            let prevDriverRef = db.collection("users").document(previousDriverId)
//            prevDriverRef.updateData([
//                "status": true,
//                "upcomingTrip": FieldValue.delete()
//            ])
//        }
//
//        db.runTransaction({ (transaction, errorPointer) -> Any? in
//            let driverSnapshot: DocumentSnapshot
//            do {
//                driverSnapshot = try transaction.getDocument(driverRef)
//            } catch let fetchError as NSError {
//                errorPointer?.pointee = fetchError
//                return nil
//            }
//            
//            guard let driverData = driverSnapshot.data(),
//                  let isAvailable = driverData["status"] as? Bool,
//                  isAvailable else {
//                errorPointer?.pointee = NSError(
//                    domain: "AppErrorDomain",
//                    code: -1,
//                    userInfo: [NSLocalizedDescriptionKey: "Driver is no longer available"]
//                )
//                return nil
//            }
//            
//            let tripReference = [
//                "id": tripId,
//                "startLocation": trip.startLocation,
//                "endLocation": trip.endLocation,
//                "tripDate": trip.tripDate
//            ] as [String : Any]
//            
//            transaction.updateData([
//                "status": false,
//                "upcomingTrip": tripReference
//            ], forDocument: driverRef)
//            
//            transaction.updateData([
//                "assignedDriver": [
//                    "id": driver.id!,
//                    "name": driver.name,
//                    "email": driver.email,
//                    "phone": driver.phone,
//                    "experience": driver.experience.rawValue
//                ]
//            ], forDocument: tripRef)
//            
//            return nil
//        }) { (_, error) in
//            if let error = error {
//                print("Transaction failed: \(error)")
//                successMessage = "Failed to assign driver: \(error.localizedDescription)"
//            } else {
//                var updatedTripCopy = self.updatedTrip
//                updatedTripCopy.assignedDriver = driver
//                self.updatedTrip = updatedTripCopy
//                
//                successMessage = "Driver assigned successfully!"
//                checkAndUpdateTripStatus()
//            }
//            showSuccessMessage = true
//        }
//    }
//
//    private func assignVehicle(_ vehicle: Vehicle) {
//        guard let tripId = trip.id, let vehicleId = vehicle.id else { return }
//        
//        let db = Firestore.firestore()
//        
//        let tripRef = db.collection("trips").document(tripId)
//        let vehicleRef = db.collection("vehicles").document(vehicleId)
//        
//        if let previousVehicle = updatedTrip.assignedVehicle, let previousVehicleId = previousVehicle.id {
//            let prevVehicleRef = db.collection("vehicles").document(previousVehicleId)
//            prevVehicleRef.updateData(["status": true])
//        }
//
//        db.runTransaction({ (transaction, errorPointer) -> Any? in
//            let vehicleSnapshot: DocumentSnapshot
//            do {
//                vehicleSnapshot = try transaction.getDocument(vehicleRef)
//            } catch let fetchError as NSError {
//                errorPointer?.pointee = fetchError
//                return nil
//            }
//            
//            guard let vehicleData = vehicleSnapshot.data(),
//                  let isAvailable = vehicleData["status"] as? Bool,
//                  isAvailable else {
//                errorPointer?.pointee = NSError(
//                    domain: "AppErrorDomain",
//                    code: -1,
//                    userInfo: [NSLocalizedDescriptionKey: "Vehicle is no longer available"]
//                )
//                return nil
//            }
//            
//
//            
//            transaction.updateData([
//                "assignedVehicle": [
//                    "id": vehicle.id!,
//                    "type": vehicle.type.rawValue,
//                    "model": vehicle.model,
//                    "registrationNumber": vehicle.registrationNumber,
//                    "fuelType": vehicle.fuelType.rawValue
//                ]
//            ], forDocument: tripRef)
//            
//            transaction.updateData([
//                "status": false
//            ], forDocument: vehicleRef)
//            
//            
//
//            return nil
//        }) { (object, error) in
//            if let error = error {
//                print("Transaction failed: \(error)")
//                successMessage = "Failed to assign vehicle: \(error.localizedDescription)"
//            } else {
//                var updatedTripCopy = self.updatedTrip
//                updatedTripCopy.assignedVehicle = vehicle
//                self.updatedTrip = updatedTripCopy
//                
//                successMessage = "Vehicle assigned successfully!"
//                checkAndUpdateTripStatus()
//            }
//            showSuccessMessage = true
//        }
//    }
//    
//   
//    private func checkAndUpdateTripStatus() {
//        if updatedTrip.assignedDriver != nil && updatedTrip.assignedVehicle != nil && updatedTrip.TripStatus == .scheduled {
//            successMessage += " Both driver and vehicle are now assigned. Trip is ready to start!"
//        }
//    }
//    
//    private func startTrip() {
//        guard let tripId = trip.id else { return }
//        
//        let db = Firestore.firestore()
//        let tripRef = db.collection("trips").document(tripId)
//        
//        tripRef.updateData([
//            "TripStatus": TripStatus.inprogress.rawValue
//        ]) { error in
//            if let error = error {
//                print("Error starting trip: \(error)")
//                successMessage = "Failed to start trip: \(error.localizedDescription)"
//            } else {
//                var updatedTripCopy = self.updatedTrip
//                updatedTripCopy.TripStatus = .inprogress
//                self.updatedTrip = updatedTripCopy
//                
//                successMessage = "Trip started successfully!"
//            }
//            showSuccessMessage = true
//        }
//    }
//}
//
//
//struct TripDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TripDetailsView(trip: Trip(
//            tripDate: Date(),
//            startLocation: "123 Business Park, Los Angeles",
//            endLocation: "456 Industrial Zone, San Francisco",
//            distance: 150.5,
//            estimatedTime: 120.0,
//            assignedDriver: nil,
//            TripStatus: .scheduled,
//            assignedVehicle: nil
//        ))
//    }
//}
