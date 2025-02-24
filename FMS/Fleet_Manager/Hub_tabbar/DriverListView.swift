
import SwiftUI
import FirebaseFirestore

struct DriverListView: View {
    @StateObject private var viewModel = DriverViewModel()
    @State private var searchText = ""
    @State private var selectedStatus: String = "All"
    @State private var showDeleteSuccessAlert = false
    @State private var showDeleteConfirmation = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var driverToDelete: Driver?
    
    let db = Firestore.firestore()
    
    var filteredDrivers: [Driver] {
        viewModel.drivers.filter { driver in
            let matchesSearch = searchText.isEmpty || driver.name.lowercased().contains(searchText.lowercased())
            let matchesStatus = selectedStatus == "All" || (selectedStatus == "Active" && driver.status) || (selectedStatus == "Inactive" && !driver.status)
            return matchesSearch && matchesStatus
        }
    }
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
            
            Picker("Status", selection: $selectedStatus) {
                Text("All").tag("All")
                Text("Active").tag("Active")
                Text("Inactive").tag("Inactive")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            List {
                ForEach(filteredDrivers, id: \.id) { driver in
                    ZStack {
                        DriverRow(driver: driver)
                        NavigationLink(destination: DriverDetails(driver: driver)) {
                            EmptyView()
                        }
                        .opacity(0)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .onDelete(perform: confirmDelete)
            }
            .listStyle(.plain)
            .background(Color.clear)
        }
        .navigationTitle("Drivers")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGray6))
        .onAppear { viewModel.startListeningToDrivers() }
        .onDisappear { viewModel.stopListeningToDrivers() }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Delete Driver", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let driver = driverToDelete {
                    deleteDriver(driver)
                }
            }
        } message: {
            Text("Are you sure you want to delete this driver?")
        }
        .alert("Success", isPresented: $showDeleteSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Driver deleted successfully.")
        }
    }
    
    func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            let driver = filteredDrivers[index]
            
            // Check if driver is active (not assigned to trip)
            if !driver.status {
                showError("Cannot delete driver as they are currently assigned to a trip.")
                return
            }
            
            driverToDelete = driver
            showDeleteConfirmation = true
        }
    }
    
    func deleteDriver(_ driver: Driver) {
        guard let driverId = driver.id else {
            showError("Invalid driver ID, deletion not allowed.")
            return
        }
        
        // Double check status before deletion
        if !driver.status {
            showError("Cannot delete driver as they are currently assigned to a trip.")
            return
        }
        
        let batch = db.batch()
        let userRef = db.collection("users").document(driverId)
        
        // Delete the user document
        batch.deleteDocument(userRef)
        
        // Commit the batch
        batch.commit { error in
            DispatchQueue.main.async {
                if let error = error {
                    showError("Error deleting driver: \(error.localizedDescription)")
                } else {
                    showDeleteSuccessAlert = true
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}

struct DriverRow: View {
    let driver: Driver
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading) {
                Text(driver.name).font(.system(size: 18, weight: .bold))
                Text("+91 \(driver.phone)").font(.system(size: 14)).foregroundColor(.gray)
            }
            Spacer()
            Text(driver.status ? "Active" : "Inactive")
                .font(.subheadline)
                .foregroundColor(driver.status ? .green : .red)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

