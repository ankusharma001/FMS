//
//  DriverHeaderView.swift
//  FMS
//
//  Created by Prince on 14/02/25.
//
//

//
//  DriverHeaderView.swift
//  FMS
//
//  Created by Prince on 14/02/25.
//
import SwiftUI
import FirebaseFirestore

struct DriverHeaderView: View {
    @State private var isAvailable: Bool = true
    let userName: String

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 2) {
                    Text(userName)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Professional Driver")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                HStack(spacing: 5) {
                    Text("Available")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Toggle("", isOn: $isAvailable)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}

// Parent View with Reserved Space for Navigation
struct DriverScreen: View {
    let userName: String
   
    var body: some View {
        let user : User
        VStack(spacing: 0) {
            Spacer() // Reserve space for navigation (adjust later dynamically)
                .frame(height: 44) // Standard navigation bar height
            
            DriverHeaderView(userName: userName)
            
            Spacer()
        }
        .background(Color(.systemGray6)) // Light gray background
        .edgesIgnoringSafeArea(.bottom) // Prevents cutting at bottom
    }
    
}

#Preview {
    DriverScreen(userName: "jayash")
}
