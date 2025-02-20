//
//  TripdashBoard.swift
//  FMS
//
//  Created by Ankush Sharma on 17/02/25.
//

import SwiftUI
import FirebaseFirestore

struct StatCard: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            Text("\(count)")
                .font(.title2)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 110, height: 100)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
struct StatsView: View {
    var body: some View {
        HStack(spacing: 20) {
            StatCard(icon: "truck.box", count: 12, label: "Active", color: .blue)
            StatCard(icon: "checkmark.circle.fill", count: 45, label: "Completed", color: .green)
            StatCard(icon: "clipboard", count: 8, label: "Unassigned", color: .orange)
        }
        .padding()
    }
}

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
struct SearchBarView: View {
    var body: some View {
        HStack {
            TextField("Search", text: .constant(""))
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
//            Image(systemName: "mic.fill")
//                .padding()
        }
    }
}
struct StatusTag: View {
    let status: TripStatus
    
    var body: some View {
        Text(statusText)
            .padding(6)
            .background(statusColor)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
    
    private var statusText: String {
        switch status {
        case .inprogress: return "Active"
        case .completed: return "Completed"
        case .scheduled: return "Unassigned"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .inprogress: return .green
        case .completed: return .blue
        case .scheduled: return .orange
        }
    }
}


struct TripdashBoard: View {
    var body: some View {
        NavigationStack{
            SearchBarView()
            StatsView()
           
            TripListView()
        }.navigationTitle("Trips")
    }
}

#Preview {
    TripdashBoard()
}
