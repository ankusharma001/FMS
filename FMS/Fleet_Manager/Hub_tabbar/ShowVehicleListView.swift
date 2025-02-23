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
                   Image(systemName: "fuelpump.fill" )
                       .foregroundColor(.red)
                   
                   Text(selectedFuelType?.rawValue ?? " ")
                       .foregroundColor(.black)
                   Image(systemName: "chevron.down")
                       .foregroundColor(.gray)
               }
               .padding(7)
               .background(Color.white.opacity(0.1))
               .overlay(
                   RoundedRectangle(cornerRadius: 8)
                       .stroke(Color.blue, lineWidth: 2) // 20 is the border width
               )
               .cornerRadius(8)

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
                   Text(selectedVehicleType?.rawValue ?? "")
                       .foregroundColor(.black)
                   Image(systemName: "chevron.down")
                       .foregroundColor(.gray)
               }
               .padding(7)
               .background(Color.white.opacity(0.1))
               .overlay(
                   RoundedRectangle(cornerRadius: 8)
                       .stroke(Color.blue, lineWidth: 2) // 20 is the border width
               )
               .cornerRadius(8)
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
                Text(selectedStatus == nil ? "" : (selectedStatus! ? "Active" : "Inactive"))
                    .foregroundColor(.black)
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding(7)
            .background(Color.white.opacity(0.1))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
            .cornerRadius(8)
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
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)
                
                List(filteredVehicles, id: \.id) { vehicle in
                    NavigationLink(destination: VehicleDetailsView(vehicle: vehicle)) {
                        HStack {
                            Image(systemName: "truck.box.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(.leading, 8)

                            VStack(alignment: .leading) {
                                Text(vehicle.model)
                                    .foregroundColor(.black)
                                    .font(.headline)
                                Text(vehicle.type.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)

                            Spacer()

                            HStack {
                                Circle()
                                    .fill(vehicle.status ? Color.green : Color.red)
                                    .frame(width: 8, height: 8)
                                Text(vehicle.status ? "Active" : "Inactive")
                                    .foregroundColor(vehicle.status ? .green : .red)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }.padding(.top,20)
        .onAppear {
            fetchVehicles()
        }
        .navigationTitle("Vehicle List")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search vehicles...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
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
