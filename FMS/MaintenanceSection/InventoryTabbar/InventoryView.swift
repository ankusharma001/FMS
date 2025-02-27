import SwiftUI
import FirebaseFirestore

struct InventoryItem: Identifiable {
    var id: String
    var partName: String
    var quantity: Int
    var partNumber: String
    var supplier: String
    var lastUpdated: Date
}

class InventoryViewModel: ObservableObject {
    @Published var inventory: [InventoryItem] = []
    private let db = Firestore.firestore()

    init() {
        fetchInventory()
    }

    func fetchInventory() {
        db.collection("inventory").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching inventory: \(error)")
                return
            }

            DispatchQueue.main.async {
                self.inventory = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    guard let partName = data["partName"] as? String,
                          let quantity = data["quantity"] as? Int,
                          let partNumber = data["partNumber"] as? String,
                          let supplier = data["supplier"] as? String,
                          let timestamp = data["lastUpdated"] as? Timestamp else {
                        return nil
                    }
                    return InventoryItem(
                        id: document.documentID,
                        partName: partName,
                        quantity: quantity,
                        partNumber: partNumber,
                        supplier: supplier,
                        lastUpdated: timestamp.dateValue()
                    )
                } ?? []
            }
        }
    }

    func updateInventoryItem(itemId: String, newQuantity: Int) {
        db.collection("inventory").document(itemId).updateData([
            "quantity": newQuantity,
            "lastUpdated": Timestamp()
        ]) { error in
            if let error = error {
                print("Error updating inventory: \(error)")
            } else {
                print("Inventory updated successfully!")
                self.fetchInventory()
            }
        }
    }

    func addNewPart(partName: String, partNumber: String, supplier: String, quantity: Int) {
        let newPart: [String: Any] = [
            "partName": partName,
            "partNumber": partNumber,
            "supplier": supplier,
            "quantity": quantity,
            "lastUpdated": Timestamp()
        ]

        db.collection("inventory").addDocument(data: newPart) { error in
            if let error = error {
                print("Error adding new part: \(error)")
            } else {
                print("New part added successfully!")
                self.fetchInventory()
            }
        }
    }

    func deleteInventoryItem(itemId: String) {
        db.collection("inventory").document(itemId).delete { error in
            if let error = error {
                print("Error deleting inventory item: \(error)")
            } else {
                print("Inventory item deleted successfully!")
                DispatchQueue.main.async {
                    self.inventory.removeAll { $0.id == itemId }
                }
            }
        }
    }
}

struct InventoryView: View {
    @StateObject private var viewModel = InventoryViewModel()
    @State private var isShowingAddPartScreen = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.inventory) { item in
                    VStack(alignment: .leading) {
                        Text(item.partName).font(.headline)
                        Text("Part Number: \(item.partNumber)").font(.subheadline)
                        Text("Supplier: \(item.supplier)").font(.footnote)

                        HStack {
                            Text("Quantity:")
                            Spacer()
                            Stepper("\(item.quantity)", onIncrement: {
                                viewModel.updateInventoryItem(itemId: item.id, newQuantity: item.quantity + 1)
                            }, onDecrement: {
                                if item.quantity > 0 {
                                    viewModel.updateInventoryItem(itemId: item.id, newQuantity: item.quantity - 1)
                                }
                            })
                        }
                    }
                    .padding()
                }
                .onDelete(perform: deleteItem)
            }
            
            .navigationTitle("Inventory")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowingAddPartScreen = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddPartScreen) {
                AddPartView(viewModel: viewModel)
            }
        }
    }

    private func deleteItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let item = viewModel.inventory[index]
            viewModel.deleteInventoryItem(itemId: item.id)
        }
    }
}

#Preview{
    InventoryView()
}
