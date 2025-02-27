//import SwiftUI
//
//struct AddPartView: View {
//    @ObservedObject var viewModel: InventoryViewModel
//    @State private var newPartName = ""
//    @State private var newPartNumber = ""
//    @State private var newSupplier = ""
//    @State private var newQuantity = ""
//    @Environment(\.dismiss) var dismiss
//    
//    // Computed property to check if all fields are filled
//    private var isFormValid: Bool {
//        !newPartName.isEmpty &&
//        !newPartNumber.isEmpty &&
//        !newSupplier.isEmpty &&
//        !newQuantity.isEmpty &&
//        Int(newQuantity) != nil // Ensuring quantity is a valid integer
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                TextField("Part Name", text: $newPartName)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                
//                TextField("Part Number", text: $newPartNumber)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                
//                TextField("Supplier", text: $newSupplier)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                
//                TextField("Quantity", text: $newQuantity)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .keyboardType(.numberPad)
//                    .padding(.horizontal)
//                
//                Button("Add Part") {
//                    if let quantityInt = Int(newQuantity) {
//                        viewModel.addNewPart(partName: newPartName, partNumber: newPartNumber, supplier: newSupplier, quantity: quantityInt)
//                        dismiss()
//                    }
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.top)
//                .disabled(!isFormValid) // Disables the button if the form is invalid
//                
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("New Part")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//            }
//            
//        }
//    }
//}
//#Preview {
//    AddPartView(viewModel: InventoryViewModel())
//}

//------------------------------


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
            VStack(alignment: .leading, spacing: 15) {
                Text("Part Name")
                    .font(.headline)
                    .padding(.horizontal)
                
                TextField("Enter part name", text: $newPartName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Text("Part Number")
                    .font(.headline)
                    .padding(.horizontal)
                
                TextField("Enter part number", text: $newPartNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Text("Supplier")
                    .font(.headline)
                    .padding(.horizontal)

                TextField("Enter supplier name", text: $newSupplier)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Text("Quantity")
                    .font(.headline)
                    .padding(.horizontal)

                TextField("Enter quantity", text: $newQuantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding(.horizontal)

                Spacer()
                
                Button(action: {
                    if let quantityInt = Int(newQuantity) {
                        viewModel.addNewPart(partName: newPartName, partNumber: newPartNumber, supplier: newSupplier, quantity: quantityInt)
                        dismiss()
                    }
                }) {
                    Text("Add Part")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.headline)
                }
                .padding(.horizontal)
                .disabled(!isFormValid)

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Add New Part")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// Preview with a mock viewModel
#Preview {
    AddPartView(viewModel: InventoryViewModel()) // Ensure InventoryViewModel is available
}

