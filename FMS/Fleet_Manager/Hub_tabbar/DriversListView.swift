//
//  DriversListView.swift
//  FMS
//
//  Created by Aastik Mehta on 21/02/25.
//

import SwiftUI

struct DriversListView: View {
    @StateObject private var viewModel = DriverViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.drivers, id: \.id) { driver in
                        DriverCardView(driver: driver)
                    }
                }
                .padding()
            }
            .navigationTitle("Drivers")
        }
    }
}

struct DriverCardView: View {
    let driver: Driver

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(driver.name)
                .font(.title2)
                .fontWeight(.bold)

            Text("License: \(driver.license)")
                .font(.subheadline)

            Text("Experience: \(driver.experience.rawValue)")
                .font(.subheadline)

            Text("Geo Preference: \(driver.geoPreference.rawValue)")
                .font(.subheadline)

            Text("Vehicle Preference: \(driver.vehiclePreference.rawValue)")
                .font(.subheadline)

            Text("Status: \(driver.status ? "Active" : "Inactive")")
                .font(.subheadline)
                .foregroundColor(driver.status ? .green : .red)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
