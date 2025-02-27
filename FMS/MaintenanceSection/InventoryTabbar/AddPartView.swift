import SwiftUI

struct AddPartView: View {
    @ObservedObject var viewModel: InventoryViewModel
    @State private var newPartName = ""
    @State private var newPartNumber = ""
    @State private var newSupplier = ""
    @State private var newQuantity = ""
    @Environment(\.dismiss) var dismiss

    // Computed property to check if all fields are filled
    private var isFormValid: Bool {
        !newPartName.isEmpty &&
        !newPartNumber.isEmpty &&
        !newSupplier.isEmpty &&
        !newQuantity.isEmpty &&
        Int(newQuantity) != nil // Ensuring quantity is a valid integer
    }

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
                    if let quantityInt = Int(newQuantity) {
                        viewModel.addNewPart(partName: newPartName, partNumber: newPartNumber, supplier: newSupplier, quantity: quantityInt)
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
                .disabled(!isFormValid) // Disables the button if the form is invalid

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
