//
//  ShowVehicleListView.swift
//  FMS
//
//  Created by Deepankar Garg on 17/02/25.
//
import SwiftUI
import FirebaseFirestore

struct ShowVehicleListView: View {
   
    @State private var vehicles: [Vehicle] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var selectedVehicleType: VehicleType?
    @State private var selectedFuelType: FuelType?
    @State private var selectedStatus: Bool? // New state for filtering by status

    private var filteredVehicles: [Vehicle] {
        var filtered = vehicles
        
        if !searchText.isEmpty {
            filtered = filtered.filter { vehicle in
                vehicle.model.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let selectedType = selectedVehicleType {
            filtered = filtered.filter { $0.type == selectedType }
        }
        
        if let selectedFuel = selectedFuelType {
            filtered = filtered.filter { $0.fuelType == selectedFuel }
        }
        
        if let status = selectedStatus {
            filtered = filtered.filter { $0.status == status }
        }
        
        return filtered
    }

    func fetchVehicles() {
        let db = Firestore.firestore()
        db.collection("vehicles").getDocuments { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching vehicles: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let snapshot = snapshot else {
                DispatchQueue.main.async {
                    self.errorMessage = "No vehicles found."
                    self.isLoading = false
                }
                return
            }
            
            let vehicles = snapshot.documents.compactMap { document -> Vehicle? in
                do {
                    return try document.data(as: Vehicle.self)
                } catch {
                    print("Error decoding vehicle: \(error)")
                    return nil
                }
            }
            
            DispatchQueue.main.async {
                self.vehicles = vehicles
                self.isLoading = false
            }
        }
    }
    
    private var fuelfilterPicker: some View {
           Menu {
               // Option to show all fuel types
               Button(action: { selectedFuelType = nil }) {
                   HStack {
                       Text("All Fuel Types")
                       if selectedFuelType == nil {
                           Image(systemName: "checkmark")
                       }
                   }
               }
               
               // Filter options for each fuel type
               ForEach(FuelType.allCases, id: \.self) { fuel in
                   Button(action: { selectedFuelType = fuel }) {
                       HStack {
                           Text(fuel.rawValue)
                           if selectedFuelType == fuel {
                               Image(systemName: "checkmark")
                           }
                       }
                   }
               }
           } label: {
               HStack {
                   Image(systemName: "fuelpump.fill")
                       .foregroundColor(.black)
                   
                   Text(selectedFuelType?.rawValue ?? "All")
                       .foregroundColor(.black)
                       .font(.system(size: 12)) // Adjust font size if needed
                   
                   Image(systemName: "chevron.down")
                       .foregroundColor(.gray)
               }
               .padding(7)
               .background(Color.white)
               
               .cornerRadius(8)
               .padding(.top,20)
               .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
           }

       }

       private var filterPicker: some View {
           Menu {
               Button(action: { selectedVehicleType = nil }) {
                   HStack {
                       Text("vehicle")
                       if selectedVehicleType == nil {
                           Image(systemName: "checkmark")
                       }
                   }
               }
               
               ForEach(VehicleType.allCases, id: \.self) { type in
                   Button(action: { selectedVehicleType = type }) {
                       HStack {
                           Text(type.rawValue)
                           if selectedVehicleType == type {
                               Image(systemName: "checkmark")
                           }
                       }
                   }
               }
           } label: {
               HStack {
                   Image(systemName: "truck.box.fill")
                       .foregroundColor(.black)
                   Text(selectedVehicleType?.rawValue ?? "All")
                       .font(.system(size: 12))
                       .foregroundColor(.black)
                   Image(systemName: "chevron.down")
                       .foregroundColor(.gray)
               }
               .padding(7)
               .background(Color.white)
               
              
               .cornerRadius(8)
               .padding(.top,20)
               .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
           }
       }
       

    private var statusFilterPicker: some View {
        Menu {
            Button(action: { selectedStatus = nil }) {
                HStack {
                    Text("All Status")
                    if selectedStatus == nil { Image(systemName: "checkmark") }
                }
            }
            Button(action: { selectedStatus = true }) {
                HStack {
                    Text("Active")
                    if selectedStatus == true { Image(systemName: "checkmark") }
                }
            }
            Button(action: { selectedStatus = false }) {
                HStack {
                    Text("Inactive")
                    if selectedStatus == false { Image(systemName: "checkmark") }
                }
            }
        } label: {
            HStack {
                Image(systemName: "power.circle.fill")
                    .foregroundColor(.green)
                Text(selectedStatus == nil ? "All" : (selectedStatus! ? "Active" : "Inactive"))
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding(7)
            .background(Color.white)
            
            .cornerRadius(8)
            .padding(.top,20)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                VStack {
                    SearchBar(text: $searchText)
                    
                    HStack {
                        filterPicker
                        Spacer()
                        fuelfilterPicker
                        Spacer()
                        statusFilterPicker
                    }
                    .padding(.horizontal)
//                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)
                
                List(filteredVehicles, id: \.id) { vehicle in
                    NavigationLink(destination: VehicleDetailsView(vehicle: vehicle)) {
                        HStack {
                            // Image Container
                            ZStack {
                                // Background with gradient and shadow
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.3)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 70, height: 80)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                
                                // AsyncImage for vehicle image
                                AsyncImage(url: URL(string: vehicle.vehicleImage)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 70, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .transition(.opacity.combined(with: .scale)) // Smooth transition
                                    case .failure:
                                        Image(systemName: "car.fill") // Fallback icon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.gray.opacity(0.5))
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            
                            // Vehicle Details
                            VStack(alignment: .leading, spacing: 4) {
                                Text(vehicle.model)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Text(vehicle.type.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            .padding(.leading, 8)
                            
                            Spacer()
                            
                            // Status Indicator
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(vehicle.status ? Color.green : Color.red)
                                    .frame(width: 8, height: 8)
                                    .shadow(color: vehicle.status ? Color.green.opacity(0.3) : Color.red.opacity(0.3), radius: 3, x: 0, y: 2)
                                
                                Text(vehicle.status ? "Active" : "Inactive")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(vehicle.status ? .green : .red)
                            }
                            .padding(.trailing, 8)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .animation(.easeInOut(duration: 0.3), value: vehicle.status) // Animate status change
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .background(Color.clear)

            }
        }.padding(.top,8)
            .background(Color(.systemGray6))
        .onAppear {
            fetchVehicles()
        }
        .navigationTitle("Vehicle List")
        .background(Color(.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search...", text: $text)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top,10)
         
            
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    ShowVehicleListView()
}
