////
////  TripdashBoard.swift
////  FMS
////
////  Created by Ankush Sharma on 17/02/25.
////
//
//import SwiftUI
//import FirebaseFirestore
//
//struct StatCard: View {
//    let icon: String
//    let count: Int
//    let label: String
//    let color: Color
//    
//    var body: some View {
//        VStack {
//            Image(systemName: icon)
//                .font(.title)
//                .foregroundColor(color)
//            Text("\(count)")
//                .font(.title2)
//                .bold()
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.gray)
//        }
//        .frame(width: 110, height: 100)
//        .background(Color(.systemGray6))
//        .cornerRadius(10)
//    }
//}
//struct StatsView: View {
//    var body: some View {
//        HStack(spacing: 20) {
//            StatCard(icon: "truck.box", count: 12, label: "Active", color: .blue)
//            StatCard(icon: "checkmark.circle.fill", count: 45, label: "Completed", color: .green)
//            StatCard(icon: "clipboard", count: 8, label: "Unassigned", color: .orange)
//        }
//        .padding()
//    }
//}
//
////struct TripListView: View {
////    @State private var trips: [Trip] = []
////    private let db = Firestore.firestore()
////   
////    var body: some View {
////        List(trips, id: \.id) { trip in
////            VStack(alignment: .leading) {
////                Text("From: \(trip.startLocation) → To: \(trip.endLocation)")
////                    .font(.headline)
////                Text("Status: \(trip.TripStatus.rawValue)")
////                    .font(.subheadline)
////            }
////        }
////        .onAppear(perform: fetchTrips)
////        .navigationTitle("Trips")
////    }
////    
////    private func fetchTrips() {
////        db.collection("trips").getDocuments { snapshot, error in
////            guard let documents = snapshot?.documents, error == nil else {
////                print("Error fetching trips: \(error?.localizedDescription ?? "Unknown error")")
////                return
////            }
////            self.trips = documents.compactMap { doc in
////                try? doc.data(as: Trip.self)
////            }
////        }
////    }
////}
//struct SearchBarView: View {
//    var body: some View {
//        HStack {
//            TextField("Search", text: .constant(""))
//                .padding(10)
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//                .padding()
////            Image(systemName: "mic.fill")
////                .padding()
//        }
//    }
//}
//struct StatusTag: View {
//    let status: TripStatus
//    
//    var body: some View {
//        Text(statusText)
//            .padding(6)
//            .background(statusColor)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//    }
//    
//    private var statusText: String {
//        switch status {
//        case .inprogress: return "Active"
//        case .completed: return "Completed"
//        case .scheduled: return "Unassigned"
//        }
//    }
//    
//    private var statusColor: Color {
//        switch status {
//        case .inprogress: return .green
//        case .completed: return .blue
//        case .scheduled: return .orange
//        }
//    }
//}
//
//
//struct TripdashBoard: View {
//    var body: some View {
//        NavigationStack{
//            SearchBarView()
//            StatsView()
//           
//            TripListView()
//        }.navigationTitle("Trips")
//    }
//}
//
//#Preview {
//    TripdashBoard()
//}


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
                .foregroundColor(.black)
            Text(label)
                .font(.caption)
                .foregroundColor(.black)
        }
        .frame(width: 98, height: 100)
        .cornerRadius(10)

    }
}

struct StatsView: View {
    @State private var activeTripsCount: Int = 0
    @State private var completedTripsCount: Int = 0
    @State private var unassignedTripsCount: Int = 0

    var body: some View {
        HStack(spacing: 20) {
            StatCard(icon: "truck.box", count: activeTripsCount, label: "Active", color: .blue)
            StatCard(icon: "checkmark.circle.fill", count: completedTripsCount, label: "Completed", color: .green)
            StatCard(icon: "clipboard", count: unassignedTripsCount, label: "Unassigned", color: .orange)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
        .onAppear {
            fetchTripCounts()
        }
    }

    private func fetchTripCounts() {
        let db = Firestore.firestore()

        db.collection("trips").whereField("TripStatus", isEqualTo: TripStatus.inprogress.rawValue).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching active trips: \(error)")
            } else {
                activeTripsCount = snapshot?.documents.count ?? 0
            }
        }

        db.collection("trips").whereField("TripStatus", isEqualTo: TripStatus.completed.rawValue).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching completed trips: \(error)")
            } else {
                completedTripsCount = snapshot?.documents.count ?? 0
            }
        }

        db.collection("trips").whereField("TripStatus", isEqualTo: TripStatus.scheduled.rawValue).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching unassigned trips: \(error)")
            } else {
                unassignedTripsCount = snapshot?.documents.count ?? 0
            }
        }
    }
}

struct SearchBarView: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            TextField("Search location or date", text: $searchText)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
                .padding(.horizontal)
                .overlay(
                    HStack {
                        Spacer()
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 20)
                        }
                    }
                )
        }
    }
}

struct StatusTag: View {
    let status: TripStatus

    var body: some View {
        Text(statusText)
            .padding(1)
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
    @State private var searchText: String = ""
    @State private var trips: [Trip] = []
    private let db = Firestore.firestore()

    var filteredTrips: [Trip] {
        if searchText.isEmpty {
            return trips
        } else {
            return trips.filter { trip in
                let locationMatch = trip.startLocation.lowercased().contains(searchText.lowercased()) ||
                                    trip.endLocation.lowercased().contains(searchText.lowercased())

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM"
                let tripDateString = dateFormatter.string(from: trip.tripDate)
                let dateMatch = tripDateString.lowercased().contains(searchText.lowercased())

                return locationMatch || dateMatch
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBarView(searchText: $searchText)
                StatsView()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredTrips) { trip in
                            NavigationLink(destination: TripDetailsView(trip: trip)) {
                                TripCardView2(trip: trip)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Trips") // Correct placement of navigation title
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .onAppear {
            fetchTrips()
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
                    return try doc.data(as: Trip.self)
                } catch {
                    print("Error decoding trip: \(error.localizedDescription)")
                    return nil
                }
            }
        }
    }
}

struct TripDashboard_Previews: PreviewProvider {
    static var previews: some View {
        TripdashBoard()
    }
}
