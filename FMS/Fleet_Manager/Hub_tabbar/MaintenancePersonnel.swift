import SwiftUI
import FirebaseFirestore

struct MaintenancePerson: Identifiable {
    let id: String
    let name: String
    let email: String
    
    init(id: String = UUID().uuidString, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
    
    // Initialize from Firestore document
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let name = data["name"] as? String,
              let email = data["email"] as? String else {
            return nil
        }
        self.id = document.documentID
        self.name = name
        self.email = email
    }
}

struct MaintenanceListView: View {
    var body: some View {
        NavigationStack {
            MaintenancePersonnelListview()
        }.navigationTitle("Maintenance Personnel")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct MaintenancePersonnelListview: View {
    @State private var searchText = ""
    @State private var maintenanceList: [MaintenancePerson] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    var filteredList: [MaintenancePerson] {
        if searchText.isEmpty {
            return maintenanceList
        } else {
            return maintenanceList.filter { person in
                person.name.localizedCaseInsensitiveContains(searchText) ||
                person.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
            Spacer()

            if isLoading {
                ProgressView()
                    .padding()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List {
                    ForEach(filteredList) { person in
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 45, height: 45)
                                
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(person.name)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(person.email)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
//                                Image(systemName: "ellipsis")
//                                    .foregroundColor(.gray)
//                                    .padding(.trailing, 8)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .onDelete(perform: deletePerson)
                }
                .listStyle(.plain)
            }
        }
        .padding(.top, 20)
        .background(Color(.systemGray6))
        .onAppear {
            fetchMaintenancePersonnel()
        }
    }

    private func fetchMaintenancePersonnel() {
        isLoading = true
        db.collection("users")
            .whereField("role", isEqualTo: "Maintenance Personnel")
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No maintenance personnel found"
                    return
                }
                
                self.maintenanceList = documents.compactMap { document in
                    MaintenancePerson(document: document)
                }
            }
    }

    private func deletePerson(at offsets: IndexSet) {
        let personsToDelete = offsets.map { maintenanceList[$0] }
        
        // Remove from local array first for UI responsiveness
        maintenanceList.remove(atOffsets: offsets)
        
        // Delete from Firestore
        for person in personsToDelete {
            db.collection("users").document(person.id).delete { error in
                if let error = error {
                    print("Error deleting document: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    MaintenanceListView()
}
