import SwiftUI
import FirebaseFirestore


struct DriverListView: View {
    @StateObject private var viewModel = DriverViewModel()
    @State private var searchText = ""
    @State var users: [User] = []
    @State private var showDeleteSuccessAlert = false
    @State private var showDeleteConfirmation = false
    @State private var userToDelete: User?
    @State private var selectedStatus: String = "All"
    
    let db = Firestore.firestore()
    
   
    var filteredUsers: [User] {
            if searchText.isEmpty {
                return users
            } else {
                return users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            }
        }
        



    
    var body: some View {
        //        NavigationView{
        VStack {
            TextField("Search", text: $searchText)
                .padding(10)
                .background(Color(.white))
                .cornerRadius(10)
                .padding(.horizontal)
            //                    .padding(.top, 70)
            
            List {
                ForEach(viewModel.drivers, id: \.id) { driver in
                    ZStack {
                        DriverRow(driver: driver)
                            .frame(maxWidth: .infinity) // Ensures full width
                            .cornerRadius(15)
                        
                        NavigationLink(destination: DriverDetails(user: driver)) {
                            EmptyView()
                        }
                        .opacity(0)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets()) // Removes default padding
                }
                .onDelete(perform: confirmDelete)
            }
            
            .listStyle(.plain)
            .background(Color.clear)
            .padding(.top, 10)
        }.padding(.top, 10)
            .navigationTitle("Drivers")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGray6))
            .onAppear(perform: fetchUsersDriver)
            .alert(isPresented: $showDeleteSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("User deleted successfully."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to delete this driver?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let user = userToDelete {
                            deleteUser(user)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
    
//        }
    }
    
    private func fetchUsersDriver() {
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
    
    func confirmDelete(at offsets: IndexSet) {
           if let index = offsets.first {
               let user = users[index]
               if user.id != nil {  // Ensure valid ID
                   userToDelete = user
                   showDeleteConfirmation = true
               } else {
                   print("User ID is nil, cannot delete")
               }
           }
       }
       
       
       func deleteUser(_ user: User) {
           db.collection("users").document(user.id ?? "").delete { error in
               if let error = error {
                   print("Error deleting user: \(error.localizedDescription)")
               } else {
                   DispatchQueue.main.async {
                       self.users.removeAll { $0.id == user.id }
                       self.showDeleteSuccessAlert = true // Show success alert
                   }
               }
           }
       }

}

struct DriverRow: View {
    let driver: Driver
    var body: some View {
        HStack {
            VStack {
                HStack{
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(driver.name)
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("+91 \(driver.phone)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("\(driver.status ? "Active" : "Inactive")")
                        .font(.subheadline)
                        .foregroundColor(driver.status ? .green : .red)
                }
                HStack{
                    VStack(alignment: .leading){
                        
                        Text("Experience : \(driver.experience.rawValue)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("Terrain : \(driver.geoPreference.rawValue)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.trailing,65)
//                            .background(Color.red)
//                            .frame(width:100)
                    }
//                        .background(Color.red)
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
        .padding(.top, 10)
        .padding(.bottom, 10)
        
    }
}

#Preview {
    DriverListView()
}

//
//
////
////  MaintenancePersonnel.swift
////  FMS
////
////  Created by Ankush Sharma on 13/02/25.
////
//
//import SwiftUI
//import FirebaseFirestore
//
//struct DriverListView: View {
//    @State private var searchText = ""
//    @State var users: [User] = []
//    @State private var showAlert = false
//    @State private var showDeleteSuccessAlert = false
//    @State private var userToDelete: User?
//    
//    let db = Firestore.firestore()
//    
//    var filteredUsers: [User] {
//        if searchText.isEmpty {
//            return users
//        } else {
//            return users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
//        }
//    }
//    
//    var body: some View {
////        NavigationView {
//            VStack {
//                TextField("Search", text: $searchText)
//                    .padding(10)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(10)
//                    .padding(.horizontal)
//                    .padding(.top, 20)
//                
//                List {
//                    ForEach(filteredUsers, id: \.id) { user in
//                        NavigationLink(destination: DriverDetails(user: user)) {
//                            DriverRow(user: user)
//                        }
//                    }
//                    .onDelete(perform: confirmDelete)
//                }
//                .listStyle(PlainListStyle())
//            }
//            .padding(.top, 30)
//            .onAppear(perform: fetchUsersDriver)
//            .alert(isPresented: $showAlert) {
//                Alert(
//                    title: Text("Confirm Delete"),
//                    message: Text("Are you sure you want to delete this driver?"),
//                    primaryButton: .destructive(Text("Delete")) {
//                        if let user = userToDelete {
//                            deleteUser(user)
//                        }
//                    },
//                    secondaryButton: .cancel()
//                )
//            }
//            .alert(isPresented: $showDeleteSuccessAlert) {
//                Alert(
//                    title: Text("Success"),
//                    message: Text("User deleted successfully."),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
//            .navigationTitle("Drivers")
//            .navigationBarTitleDisplayMode(.inline)
////        }
//    }
//    
//    func fetchUsersDriver() {
//        db.collection("users").whereField("role", isEqualTo: "Driver").getDocuments { snapshot, error in
//            guard let documents = snapshot?.documents, error == nil else {
//                print("Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            self.users = documents.compactMap { doc in
//                let user = try? doc.data(as: User.self)
//                return user?.id != nil ? user : nil
//            }
//        }
//    }
//    
//    func confirmDelete(at offsets: IndexSet) {
//        if let index = offsets.first {
//            let user = users[index]
//            if user.id != nil {  // Ensure valid ID
//                userToDelete = user
//                showAlert = true
//            } else {
//                print("User ID is nil, cannot delete")
//            }
//        }
//    }
//    
//    
//    func deleteUser(_ user: User) {
//        db.collection("users").document(user.id ?? "").delete { error in
//            if let error = error {
//                print("Error deleting user: \(error.localizedDescription)")
//            } else {
//                DispatchQueue.main.async {
//                    self.users.removeAll { $0.id == user.id }
//                    self.showDeleteSuccessAlert = true // Show success alert
//                }
//            }
//        }
//    }
//}
//struct DriverRow: View {
//    let user: User
//
//    var body: some View {
//        
//        HStack {
//            VStack(alignment: .leading) {
//                HStack(alignment: .top) {
//                    Image(systemName: "person.crop.circle.fill")
//                        .foregroundColor(.black)
//                        .font(.largeTitle)
//                    
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text(user.name)
//                            .font(.headline)
//                            .bold()
//                            .foregroundColor(.black)
//                        
//                        Text(user.phone)
//                            .font(.subheadline)
//                            .foregroundColor(.black)
//                    }
//                }
//
//                VStack(alignment: .leading) {
//                    Text("Experience: \(user.name)")
//                        .font(.footnote)
//                        .foregroundColor(.black)
//
//                    Text("Terrain specialization: \(user.name)")
//                        .font(.footnote)
//                        .foregroundColor(.black)
//                }
//            }
//            .padding(.leading, -55)
//        }
//        .frame(width: 300, height: 100)
//        .padding()
//        
//        .background(Color(.systemGray6))
//        .cornerRadius(10)
//
//
//    }
//}
//
//#Preview {
//    DriverListView()
//}
