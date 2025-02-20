//
//  asignDriverList.swift
//  FMS

import SwiftUI
import FirebaseFirestore


//func generateExampleTrips() -> [Driver] {
//    let driver1 = Driver(name: "John Doe", email: "john@example.com", phone: "123-456-7890", experience: .moreThanFive, license: "D12345", geoPreference: .plain, vehiclePreference: .truck, status: true)
//
//    let driver2 = Driver(name: "Alice Smith", email: "alice@example.com", phone: "987-654-3210", experience: .lessThanFive, license: "A67890", geoPreference: .hilly, vehiclePreference: .van, status: true)
//    
//  
//
//    return [driver2, driver1]
//}


struct asignDriverList: View {
    let db = Firestore.firestore()
    @State var users: [User] = []
    @State private var searchText = ""
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
               
               
                HStack {
                    TextField("Search", text: $searchText)
                        .padding(10)
                        .background(Color(.white))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
//                    Image(systemName: "mic.fill")
//                        .foregroundColor(.gray)
//                        .padding(.trailing)
                }
                
                // Driver Cards
                ScrollView {
                    ForEach(filteredUsers, id: \.id) { user in
//                        NavigationLink(destination: DriverDetails(user: user)) {
                            asignDriverCard(user: user)
//                        }
                    }
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle("Select Driver")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Back") {
//                        // Action for back button
//                    }
//                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Action for done button
                    }
                }
            }
            .onAppear {
                fetchUsersDriver()
            }
        }
    }
    
    func fetchUsersDriver() {
        db.collection("users").whereField("role", isEqualTo: "Driver").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.users = documents.compactMap { doc in
                let user = try? doc.data(as: User.self)
                return user?.id != nil ? user : nil
            }
        }
    }
}

struct asignDriverCard: View {
    let user: User
    var body: some View {
        HStack {
            VStack {
                HStack{
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("+91 \(user.phone)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("hello")
                }
                HStack{
                    VStack{
                        
                        Text("Experience : \(user.name) years")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("Terrain : \(user.role)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.trailing,65)
                    }.padding(.trailing,150)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.gray)
                    
                }
                
                                
               
            }
            .padding()
//            .background(Color.white)
//            .cornerRadius(15)
//            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
//            .padding(.horizontal)
//            Spacer()
//            Text("hello")
        }.background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
            .padding(.horizontal)
        .padding(.top, 5)
    }
}
#Preview {
    asignDriverList()
}
