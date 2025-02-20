//
//  Maintenance_Home.swift
//  FMS
//
//  Created by Soham Chakraborty on 18/02/25.
//

import SwiftUI
import FirebaseFirestore

struct MaintenanceTask: Identifiable {
    var id: String = UUID().uuidString
    var vehicle: Vehicle
    var taskDescription: String
    var status: MaintenanceStatus
    
    enum MaintenanceStatus: String {
        case active = "Active"
        case scheduled = "Scheduled"
        case completed = "Completed"
    }
}

struct MaintenanceHomeView: View {
    @State private var tasks: [MaintenanceTask] = []
    @State private var selectedFilter: MaintenanceTask.MaintenanceStatus = .active
    @State private var searchText = ""
    @State private var showStartConfirmation = false
    @State private var showCompleteConfirmation = false
    @State private var selectedTask: MaintenanceTask?
    
    var filteredTasks: [MaintenanceTask] {
        let filtered = tasks.filter { task in
            task.status == selectedFilter
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { task in
                task.vehicle.registrationNumber.lowercased().contains(searchText.lowercased()) ||
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
        NavigationView
        {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    //                    Title and notification
                    //                    HStack {
                    //                        Text("Home")
                    //                            .font(.largeTitle)
                    //                            .fontWeight(.bold)
                    //
                    //                        Spacer()
                    //
                    //                        Button(action: {
                    //                            // Handle notification action
                    //                        }) {
                    //                            ZStack {
                    //                                Circle()
                    //                                    .fill(Color.red.opacity(0.2))
                    //                                    .frame(width: 44, height: 44)
                    //
                    //                                Image(systemName: "bell.fill")
                    //                                    .foregroundColor(.red)
                    //                                    .font(.system(size: 20))
                    //                            }
                    //                        }
                    //                    }
                    //                }
                    
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
                        .scaleEffect(1.05) // Slightly increase the scale
                        .frame(height: 44) // Increase height
                    }
                    .padding(.vertical, 5) // Add some vertical padding
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search vehicles...", text: $searchText)
                            .background(Color.white)
                            .foregroundColor(.white)
                        
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
                .background(Color(.systemGray6))
                
                // Task list
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
                
                // Tab bar
                HStack {
                    TabBarItem(iconName: "house.fill", title: "Home", isSelected: true)
                    Spacer()
                    TabBarItem(iconName: "wrench.fill", title: "Inventory", isSelected: false)
                    Spacer()
                    TabBarItem(iconName: "person.fill", title: "Profile", isSelected: false)
                }
                .padding(.top, 8)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                .background(Color.white)
                .navigationTitle("Maintenance ")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // Handle notification action
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
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
                loadSampleData()
            }
            .alert(isPresented: $showStartConfirmation) {
                Alert(
                    title: Text("Start Maintenance"),
                    message: Text("Are you sure you want to start maintenance for \(selectedTask?.vehicle.registrationNumber ?? "this vehicle")?"),
                    primaryButton: .default(Text("Start")) {
                        if let selectedTask = selectedTask,
                           let index = tasks.firstIndex(where: { $0.id == selectedTask.id }) {
                            tasks[index].status = .active
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert("Complete Maintenance", isPresented: $showCompleteConfirmation) {
                Button("Complete", role: .none) {
                    if let selectedTask = selectedTask,
                       let index = tasks.firstIndex(where: { $0.id == selectedTask.id }) {
                        tasks[index].status = .completed
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to mark maintenance for \(selectedTask?.vehicle.registrationNumber ?? "this vehicle") as completed?")
            }
            
        }
       
    }
        private func loadSampleData() {
            // Create some sample vehicles with unique registration numbers
            let truck1 = Vehicle(
                type: .truck,
                model: "Freightliner",
                registrationNumber: "Truck#1234",
                fuelType: .diesel,
                mileage: 50000,
                rc: "RC12345",
                vehicleImage: "freightliner_image",
                insurance: "INS789",
                pollution: "PUC456",
                status: true
            )
            
            let truck2 = Vehicle(
                type: .truck,
                model: "Volvo",
                registrationNumber: "Truck#5678",
                fuelType: .diesel,
                mileage: 65000,
                rc: "RC67890",
                vehicleImage: "volvo_image",
                insurance: "INS012",
                pollution: "PUC789",
                status: true
            )
            
            let truck3 = Vehicle(
                type: .truck,
                model: "Peterbilt",
                registrationNumber: "Truck#9101",
                fuelType: .diesel,
                mileage: 42000,
                rc: "RC24680",
                vehicleImage: "peterbilt_image",
                insurance: "INS345",
                pollution: "PUC012",
                status: true
            )
            
            // Create sample tasks with different vehicles
            tasks = [
                MaintenanceTask(vehicle: truck1, taskDescription: "Oil Change", status: .active),
                MaintenanceTask(vehicle: truck2, taskDescription: "Engine Repair", status: .active),
                MaintenanceTask(vehicle: truck3, taskDescription: "Transmission Service", status: .active),
                MaintenanceTask(vehicle: truck1, taskDescription: "Brake Inspection", status: .scheduled),
                MaintenanceTask(vehicle: truck2, taskDescription: "Tire Rotation", status: .scheduled),
                MaintenanceTask(vehicle: truck3, taskDescription: "Engine Tuning", status: .scheduled),
                MaintenanceTask(vehicle: truck1, taskDescription: "AC Service", status: .completed),
                MaintenanceTask(vehicle: truck2, taskDescription: "Filter Replacement", status: .completed)
            ]
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

struct MaintenanceTaskRow: View {
    var task: MaintenanceTask
    var selectedFilter: MaintenanceTask.MaintenanceStatus
    var onAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Vehicle image
            AsyncImage(url: URL(string: "https://via.placeholder.com/80")) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            .clipped()
            
            // Task details
            VStack(alignment: .leading, spacing: 4) {
                Text(task.vehicle.registrationNumber)
                    .font(.headline)
                
                Text(task.taskDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
            // No button or label in completed section
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

struct TabBarItem: View {
    var iconName: String
    var title: String
    var isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .blue : .gray)
            
            Text(title)
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .gray)
        }
    }
}

struct MaintenanceHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MaintenanceHomeView()
    }
}
