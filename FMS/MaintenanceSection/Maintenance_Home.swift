//
//  Maintenance_Home.swift
//  FMS
//
//  Created by Vansh Sharma on 19/02/25.
//

import SwiftUI
import FirebaseFirestore

struct MaintenanceTask: Identifiable, Codable {
    @DocumentID var id: String?
    var vehicleId: String
    var taskDescription: String
    var status: MaintenanceStatus
    var createdAt: Date?
    var vehicle: Vehicle?
    
    enum MaintenanceStatus: String, Codable {
        case active = "Active"
        case scheduled = "Scheduled"
        case completed = "Completed"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, vehicleId, taskDescription, status, createdAt
    }
}

struct StatisticCardView: View {
    var iconName: String
    var iconColor: Color
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: iconName)
                            .foregroundColor(iconColor)
                    )
                Spacer()
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MaintenanceHomeView: View {
    @State private var tasks: [MaintenanceTask] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedFilter: MaintenanceTask.MaintenanceStatus = .active
    @State private var searchText = ""
    @State private var showStartConfirmation = false
    @State private var showCompleteConfirmation = false
    @State private var selectedTask: MaintenanceTask?
    
    private let db = Firestore.firestore()
    
    var filteredTasks: [MaintenanceTask] {
        let filtered = tasks.filter { task in
            task.status == selectedFilter
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { task in
                task.vehicle?.registrationNumber.lowercased().contains(searchText.lowercased()) ?? false ||
                task.taskDescription.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var underMaintenanceCount: Int {
        tasks.filter { $0.status == .active }.count
    }
    
    var completedTasksCount: Int {
        tasks.filter { $0.status == .completed }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    // Title and SOS button
                    HStack {
                        Text("Home")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            // SOS Button action placeholder
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    
                    // Statistics cards
                    HStack(spacing: 12) {
                        // Under Maintenance card
                        StatisticCardView(
                            iconName: "square.grid.2x2.fill",
                            iconColor: .blue,
                            title: "Under Maintenance",
                            value: "\(underMaintenanceCount)"
                        )
                        
                        // Completed Tasks card
                        StatisticCardView(
                            iconName: "checkmark.circle.fill",
                            iconColor: .green,
                            title: "Completed Tasks",
                            value: "\(completedTasksCount)"
                        )
                    }
                    
                    // Enlarged segmented filter buttons
                    VStack(spacing: 15) {
                        Picker("Filter", selection: $selectedFilter) {
                            Text("Active").tag(MaintenanceTask.MaintenanceStatus.active)
                            Text("Scheduled").tag(MaintenanceTask.MaintenanceStatus.scheduled)
                            Text("Completed").tag(MaintenanceTask.MaintenanceStatus.completed)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .scaleEffect(1.05)
                        .frame(height: 44)
                    }
                    .padding(.vertical, 5)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search vehicles...", text: $searchText)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            // Additional filter options
                        }) {
                            Image(systemName: "line.3.horizontal.decrease")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.white)
                
                // Task list or loading/error state
                if isLoading {
                    Spacer()
                    ProgressView("Loading maintenance tasks...")
                    Spacer()
                } else if let errorMessage = errorMessage {
                    Spacer()
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Retry") {
                            fetchMaintenanceTasks()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    Spacer()
                } else if filteredTasks.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "wrench.and.screwdriver")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No \(selectedFilter.rawValue.lowercased()) maintenance tasks found")
                            .font(.headline)
                        
                        if !searchText.isEmpty {
                            Text("Try adjusting your search criteria")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredTasks) { task in
                                MaintenanceTaskRow(task: task, selectedFilter: selectedFilter) {
                                    if selectedFilter == .scheduled {
                                        selectedTask = task
                                        showStartConfirmation = true
                                    } else if selectedFilter == .active {
                                        selectedTask = task
                                        showCompleteConfirmation = true
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGray6))
                }
            }
            .onAppear {
                fetchMaintenanceTasks()
            }
            .alert(isPresented: $showStartConfirmation) {
                Alert(
                    title: Text("Start Maintenance"),
                    message: Text("Are you sure you want to start maintenance for \(selectedTask?.vehicle?.registrationNumber ?? "this vehicle")?"),
                    primaryButton: .default(Text("Start")) {
                        if let selectedTask = selectedTask, let taskId = selectedTask.id {
                            updateTaskStatus(taskId: taskId, newStatus: .active)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert("Complete Maintenance", isPresented: $showCompleteConfirmation) {
                Button("Complete", role: .none) {
                    if let selectedTask = selectedTask, let taskId = selectedTask.id {
                        updateTaskStatus(taskId: taskId, newStatus: .completed)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to mark maintenance for \(selectedTask?.vehicle?.registrationNumber ?? "this vehicle") as completed?")
            }
        }
    }
    
    private func fetchMaintenanceTasks() {
        isLoading = true
        errorMessage = nil
        
        // First, fetch maintenance tasks
        db.collection("maintenanceTasks")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "Error loading maintenance tasks: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tasks = []
                    }
                    return
                }
                
                // Parse maintenance tasks
                var maintenanceTasks: [MaintenanceTask] = []
                for document in documents {
                    do {
                        var task = try document.data(as: MaintenanceTask.self)
                        task.id = document.documentID
                        maintenanceTasks.append(task)
                    } catch {
                        print("Error decoding task: \(error)")
                    }
                }
                
                // Now fetch all vehicles to populate the task.vehicle property
                self.db.collection("vehicles").getDocuments { (vehicleSnapshot, vehicleError) in
                    DispatchQueue.main.async {
                        if let vehicleError = vehicleError {
                            self.isLoading = false
                            self.errorMessage = "Error loading vehicles: \(vehicleError.localizedDescription)"
                            return
                        }
                        
                        var vehicles: [String: Vehicle] = [:]
                        
                        // Create a dictionary of vehicles by ID
                        if let vehicleDocs = vehicleSnapshot?.documents {
                            for doc in vehicleDocs {
                                do {
                                    var vehicle = try doc.data(as: Vehicle.self)
                                    vehicle.id = doc.documentID
                                    if let id = vehicle.id {
                                        vehicles[id] = vehicle
                                    }
                                } catch {
                                    print("Error decoding vehicle: \(error)")
                                }
                            }
                        }
                        
                        // Link vehicles to tasks
                        for i in 0..<maintenanceTasks.count {
                            let vehicleId = maintenanceTasks[i].vehicleId
                            maintenanceTasks[i].vehicle = vehicles[vehicleId]
                        }
                        
                        self.tasks = maintenanceTasks
                        self.isLoading = false
                    }
                }
            }
    }
    
    private func updateTaskStatus(taskId: String, newStatus: MaintenanceTask.MaintenanceStatus) {
        db.collection("maintenanceTasks").document(taskId).updateData([
            "status": newStatus.rawValue
        ]) { error in
            if let error = error {
                print("Error updating task status: \(error.localizedDescription)")
            } else {
                // Update local data to reflect the change
                if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                    tasks[index].status = newStatus
                }
            }
        }
    }
}

struct MaintenanceTaskRow: View {
    var task: MaintenanceTask
    var selectedFilter: MaintenanceTask.MaintenanceStatus
    var onAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Vehicle image
            if let vehicleImageURL = task.vehicle?.vehicleImage {
                AsyncImage(url: URL(string: vehicleImageURL)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .overlay(
                            Image(systemName: "car.fill")
                                .foregroundColor(.gray)
                                .opacity(0.5)
                        )
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(8)
                .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "car.fill")
                            .foregroundColor(.gray)
                            .opacity(0.5)
                    )
            }
            
            // Task details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.vehicle?.registrationNumber ?? "Unknown Vehicle")
                    .font(.headline)
                
                Text(task.taskDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Show creation date if available
                if let createdAt = task.createdAt {
                    Text("Created: \(formattedDate(createdAt))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Action buttons only for scheduled and active tasks
            if selectedFilter == .scheduled {
                Button(action: onAction) {
                    HStack {
                        Text("Start")
                            .fontWeight(.medium)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            } else if selectedFilter == .active {
                Button(action: onAction) {
                    Text("Complete")
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.1), radius: 3, x: 0, y: 1)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct  MaintenanceTabView: View {
    var body: some View {
        TabView {
            MaintenanceHomeView()
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            MaintenanceProfileView() // ✅ Replacing Text with ProfileView
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
}

#Preview
{
    MaintenanceTabView()
}
 
