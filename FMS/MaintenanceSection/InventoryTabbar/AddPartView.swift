import SwiftUI
struct AddPartView: View {
    @ObservedObject var viewModel: InventoryViewModel
    @State private var newPartName = ""
    @State private var newPartNumber = ""
    @State private var newSupplier = ""
    @State private var newQuantity = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                TextField("Part Name", text: $newPartName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Part Number", text: $newPartNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Supplier", text: $newSupplier)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                TextField("Quantity", text: $newQuantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding(.horizontal)

                Button("Add Part") {
                    if let quantityInt = Int(newQuantity), !newPartName.isEmpty, !newPartNumber.isEmpty, !newSupplier.isEmpty {
                        viewModel.addNewPart(partName: newPartName, partNumber: newPartNumber, supplier: newSupplier, quantity: quantityInt)
                        dismiss()
                    } else {
                        print("Invalid input")
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)

                Spacer()
            }
            .padding()
            .navigationTitle("New Part")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
