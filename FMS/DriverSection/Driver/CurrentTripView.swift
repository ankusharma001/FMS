//
//  CurrentTripView.swift
//  FMS
//
//  Created by Prince on 14/02/25.
//



import SwiftUI

struct CurrentTripView: View {
    

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text("Current Trip")
                .font(.headline)
                .padding(.horizontal)

            // Trip Details Card
            VStack(alignment: .leading, spacing: 12) {
                // Assigned Vehicle
                HStack {
                    Image(systemName: "truck.box.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vehicle #PB10AB0505")
                            .font(.headline)
                        Text("2019 Bharat Benz")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }

                Divider()

                // From - To Section with Line
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center, spacing: 8) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)

                        VStack(alignment: .leading) {
                            Text("From")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text("Los Angeles Port Terminal")
                                .font(.body)
                        }
                    }

                    // Vertical Line between "From" and "To"
                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 2, height: 20)
                            .padding(.leading, 3.5)
                        Spacer()
                    }

                    HStack(alignment: .center, spacing: 8) {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 8, height: 8)

                        VStack(alignment: .leading) {
                            Text("To")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Street 4, LA")
                                .font(.body)
                        }
                    }
                }

                Divider()

                // Action Buttons
                HStack(spacing: 12) {
                    TripActionButton(title: "Start Trip", systemImage: "play.fill", bgColor: Color.green.opacity(0.2), fgColor: .green)
                    
                    TripActionButton(title: "End Trip", systemImage: "stop.fill", bgColor: Color.red.opacity(0.2), fgColor: .red)
                    
                    TripActionButton(title: "SOS", systemImage: "exclamationmark.triangle.fill", bgColor: Color.orange.opacity(0.2), fgColor: .orange)
                }
            }
            .padding()
            .background(Color.white) // White background for the trip card
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2) // Soft shadow for elevation
            .padding(.horizontal)
        }
        .padding(.top, 10)
        .background(Color(.systemGray6)) // Light gray background for the whole screen
    }
}

// Reusable Button Component
struct TripActionButton: View {
    var title: String
    var systemImage: String
    var bgColor: Color
    var fgColor: Color

    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, minHeight: 44) // ✅ Ensuring equal size for all buttons
            .padding()
            .background(bgColor)
            .foregroundColor(fgColor)
            .cornerRadius(8)
        }
    }
}

// Full-screen background to separate the section
struct CurrentTripScreen: View {
    var body: some View {
        VStack {
            CurrentTripView()
            Spacer()
        }
        .background(Color(.systemGray6)) // Full-screen gray background
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    CurrentTripScreen()
}
