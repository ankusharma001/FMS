//
//  MaintenancePersonnel.swift
//  FMS
//
//  Created by Ankush Sharma on 13/02/25.
//
//
import SwiftUI
import FirebaseFirestore

struct DriverListView: View {
    @State private var searchText = ""
    @State var users: [User] = []
    @State private var showDeleteSuccessAlert = false
    @State private var showDeleteConfirmation = false
    @State private var userToDelete: User?
    @State private var selectedUserID: String?
    @State private var offsets: [String: CGFloat] = [:]  // Store offsets per user ID
    
    let db = Firestore.firestore()
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
//        NavigationStack {
            VStack {
                VStack{
                    TextField("Search", text: $searchText)
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }.padding(.top,70)
                
                ScrollView {
                    
                    VStack(spacing: 0) {
                        ForEach(filteredUsers, id: \.id) { user in
                            ZStack {
                                // Background delete button
                                HStack {
                                    Spacer()
                                    Button {
                                        // Trigger confirmation before deleting
                                        userToDelete = user
                                        showDeleteConfirmation = true
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .padding(.trailing, 20)
                                }
                                
                                // User Row with swipe gesture
                                DriverRow(user: user)
                                    .cornerRadius(15)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                                    .offset(x: offsets[user.id ?? ""] ?? 0)
                                    .gesture(
                                        DragGesture()
                                            .onChanged { gesture in
                                                if gesture.translation.width < 0 {
                                                    offsets[user.id ?? ""] = gesture.translation.width
                                                }
                                            }
                                            .onEnded { _ in
                                                if (offsets[user.id ?? ""] ?? 0) < -100 {
                                                    withAnimation {
                                                        for key in offsets.keys {
                                                            if key != user.id {
                                                                offsets[key] = 0
                                                            }
                                                        }
                                                        offsets[user.id ?? ""] = -100
                                                    }
                                                } else {
                                                    withAnimation {
                                                        offsets[user.id ?? ""] = 0
                                                    }
                                                }
                                            }
                                    )
                                    .onTapGesture {
                                        selectedUserID = user.id
                                    }
                                
                                // Invisible NavigationLink for details
                                NavigationLink(
                                    destination: DriverDetails(user: user),
                                    tag: user.id ?? "",
                                    selection: $selectedUserID,
                                    label: { EmptyView() }
                                )
                                .opacity(0)
                            }
                            .frame(height: 160)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Drivers")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGray6))
//            .padding(.top, 40)
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
//            .navigationTitle("Drivers")
//            .navigationBarTitleDisplayMode(.inline)
//            .background(Color(.systemGray6))
//        }
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
    func deleteUser(_ user: User) {
        guard let userId = user.id else {
            print("User ID is nil, cannot delete.")
            return
        }
        
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.users.removeAll { $0.id == user.id }
                    self.showDeleteSuccessAlert = true
                }
            }
        }
    }
}

struct DriverRow: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
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
            }
            .padding(.bottom, 5)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Experience: \(user.name) years")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Terrain: \(user.role)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}





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
//        //        NavigationView {
//        VStack{
//            VStack {
//                TextField("Search", text: $searchText)
//                    .padding(10)
//                    .background(Color(.white))
//                    .cornerRadius(10)
//                    .padding(.horizontal)
//                //                    .padding(.top, 20)
//
//                //                List {
//                //            ForEach(filteredUsers, id: \.id) { user in
//                //                NavigationLink(destination: DriverDetails(user: user)) {
//                //                    DriverRow(user: user)
//                //                }
//                //                //                    }
//                //                //                    .onDelete(perform: confirmDelete)
//                //            }
//                //            .listStyle(PlainListStyle())
//            }
//            .background(Color(.systemGray6))
//            ScrollView {
//                ForEach(filteredUsers, id: \.id) { user in
//                    NavigationLink(destination: DriverDetails(user: user)) {
//                        DriverRow(user: user)
//
//                    }
//                }
//            }
//
//
////            ScrollView{
////                //                List {
////                ForEach(filteredUsers, id: \.id) { user in
////                    NavigationLink(destination: DriverDetails(user: user)) {
////                        DriverRow(user: user)
////                    }
////                    //                    }
////                    //                    .onDelete(perform: confirmDelete)
////                }
////                //            .listStyle(PlainListStyle())
////
////            }
//        }
//
//
//
////            .padding(.top, -50)
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
//            .background(Color(.systemGray6))
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
//            HStack {
//                VStack {
//                    HStack{
//                        Image(systemName: "person.circle.fill")
//                            .resizable()
//                            .frame(width: 50, height: 50)
//                            .foregroundColor(.gray)
//
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(user.name)
//                                .font(.system(size: 18, weight: .bold))
//
//                            Text("+91 \(user.phone)")
//                                .font(.system(size: 14))
//                                .foregroundColor(.gray)
//                        }
//                        Spacer()
//                        Text("hello")
//                    }
//                    HStack{
//                        VStack{
//
//                            Text("Experience : \(user.name) years")
//                                .font(.system(size: 14))
//                                .foregroundColor(.gray)
//
//                            Text("Terrain : \(user.role)")
//                                .font(.system(size: 14))
//                                .foregroundColor(.gray)
//                                .padding(.trailing,65)
//                        }.padding(.trailing,150)
//
//                        Spacer()
//                        Image(systemName: "chevron.right").foregroundColor(.gray)
//                    }
//
//
//
//                }
//                .padding()
//    //            .background(Color.white)
//    //            .cornerRadius(15)
//    //            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
//    //            .padding(.horizontal)
//    //            Spacer()
//    //            Text("hello")
//            }.background(Color.white)
//                .cornerRadius(15)
//                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
//                .padding(.horizontal)
//            .padding(.top, 5)
//        }
//
////        HStack {
////            VStack(alignment: .leading) {
////                HStack(alignment: .top) {
////                    Image(systemName: "person.crop.circle.fill")
////                        .foregroundColor(.black)
////                        .font(.largeTitle)
////
////                    VStack(alignment: .leading, spacing: 5) {
////                        Text(user.name)
////                            .font(.headline)
////                            .bold()
////                            .foregroundColor(.black)
////
////                        Text(user.phone)
////                            .font(.subheadline)
////                            .foregroundColor(.black)
////                    }
////                }
////
////                VStack(alignment: .leading) {
////                    Text("Experience: \(user.name)")
////                        .font(.footnote)
////                        .foregroundColor(.black)
////
////                    Text("Terrain specialization: \(user.name)")
////                        .font(.footnote)
////                        .foregroundColor(.black)
////                }
////            }
//////            .padding(.leading, -55)
////        }
////        .frame(width: 300, height: 100)
////        .padding()
////
////        .background(Color(.white))
////        .cornerRadius(10)
//
//
//}


#Preview {
    DriverListView()
}
