//
//  ContentView.swift
//  demo
//
//  Created by Ankush Sharma on 19/02/25.
//
import SwiftUI
import FirebaseFirestore

struct MaintenanceDetailsView: View {
    
    let vehicle: Vehicle
       let userUUID: String?
    @State private var technicianName: String = "Loading..."
    private let db = Firestore.firestore()
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    
    var body: some View {
        ScrollView {
            
                
               
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width:70 ,height: 80)
                            .cornerRadius(12)
                        
                        AsyncImage(url: URL(string: vehicle.vehicleImage)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView() // Show a loading indicator
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:70 ,height: 80)
                                    .cornerRadius(12)
                            case .failure:
                                Image(systemName: "photo") // Fallback image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:70 ,height: 80)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    VStack(alignment: .leading) {
                        Text(vehicle.model)
                            .font(.title3).bold()
                        Text(vehicle.registrationNumber)
                            .font(.subheadline)
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text(vehicle.maintenanceStatus.rawValue) // Assuming maintenanceStatus is a RawRepresentable enum
                                .foregroundColor(.green)
                                .font(.subheadline)
                        }
                        Text(vehicle.fuelType.rawValue)
                            .font(.footnote)
                            .foregroundColor(.gray)
                       
                    }
                    
                    Spacer()
                }
                .padding(20)
                .background(Color(.white))
                .cornerRadius(20)
                
//                    .background(Color(.systemGray6))
                
                HStack {
                    InfoCards(title: "Meliage", value: vehicle.mileage)
                    InfoCards(title: "distance traveled", value:vehicle.totalDistance)
                }
//                
                VStack(alignment: .leading) {
                    Text("Current Service Details").font(.headline)
                    DetailRow(title: "Service Type", value: "Preventive Maintenance")
                    DetailRow(title: "Technician", value: technicianName)
//                    DetailRow(title: "Service Start", value: "Dec 15, 2023 - 9:30 AM")
//                    DetailRow(title: "Location", value: "Central Shop")
                }.padding(20)
                    .background(Color(.white))
                    .cornerRadius(20)
//                    .background(Color(.systemGray6))
//                
//                VStack(alignment: .leading) {
//                    Text("Service Items").font(.headline)
//                    ServiceItemRow(name: "Oil Change", time: "10:15 AM")
//                    ServiceItemRow(name: "Brake Inspection", time: "11:00 AM")
//                    ServiceItemRow(name: "Tire Rotation", time: "11:45 AM")
//                    ServiceItemRow(name: "Filter Replacement", time: "12:30 AM")
//                }
//                .padding(20)
//                .background(Color(.white))
//                .cornerRadius(20)
//                .background(Color(.systemGray6))
//                
//                VStack(alignment: .leading) {
//                    Text("Parts Used").font(.headline)
//                    DetailRow(title: "Engine Oil (5W-300)", value: "1")
//                    DetailRow(title: "Oil Filter", value: "1")
//                    DetailRow(title: "Air Filter", value: "1")
//                    DetailRow(title: "Brake Pads", value: "1")
//                }
//                .padding(20)
//                .background(Color(.white))
//                .cornerRadius(20)
//                .frame(width: 350,height: 45)
                   
            }
//            Spacer()
            .padding()
//            .padding(20)
            .background(Color(.systemGray6))
        }.onAppear {
            fetchUserData()
        }

        
        .navigationTitle("Details")
    }
    private func fetchUserData() {
        guard let userUUID = userUUID else {
            errorMessage = "User not logged in."
            isLoading = false
            return
        }
        
        db.collection("users").document(userUUID).getDocument { (document, error) in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    let userData = document.data() ?? [:]
                    if let name = userData["name"] as? String {
                        self.technicianName = name
                    } else {
                        self.technicianName = "Name not found"
                    }
                } else {
                    self.technicianName = "User data not found"
                }
                self.isLoading = false
            }
        }
    }

}

struct InfoCards: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack {
            Text(title).font(.caption).foregroundColor(.gray)
            Text("\(value)").font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.white))
        .cornerRadius(10)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}

struct ServiceItemRow: View {
    let name: String
    let time: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            VStack(alignment: .leading) {
                Text(name).bold()
                Text("Completed").font(.caption).foregroundColor(.green)
            }
            Spacer()
            Text(time).font(.subheadline).foregroundColor(.gray)
        }
        .padding(.vertical, 4)
        
    }
}

struct MaintenanceDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MaintenanceDetailsView(
                vehicle: Vehicle(
                    type: .car,  // Replace with actual `VehicleType`
                    model: "Toyota Corolla",
                    registrationNumber: "ABC-123",
                    fuelType: .petrol,  // Replace with actual `FuelType`
                    mileage: 15000,
                    rc: "RC123",
                    vehicleImage: "car_image_url",
                    insurance: "Valid until 2026",
                    pollution: "Valid until 2025",
                    status: true,
                    totalDistance: 50000,
                    maintenanceStatus: .scheduled
                ),
                userUUID: "test-user-uuid"
            )
        }
    }
}

