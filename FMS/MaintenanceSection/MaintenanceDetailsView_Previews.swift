//
//  ContentView.swift
//  demo
//
//  Created by Ankush Sharma on 19/02/25.
//
import SwiftUI

struct MaintenanceDetailsView: View {
    var body: some View {
        ScrollView {
            
                
               
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image("truck_image") // Replace with actual image asset
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                    VStack(alignment: .leading) {
                        Text("Truck#1234")
                            .font(.title3).bold()
                        Text("Freightliner Cascadia 2021")
                            .font(.subheadline)
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("In Service")
                                .foregroundColor(.green)
                                .font(.subheadline)
                        }
                        Text("VIN: 1FJUGLD16MLFY7652")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(20)
                .background(Color(.white))
                .cornerRadius(20)
                
//                    .background(Color(.systemGray6))
                
                HStack {
                    InfoCards(title: "Odometer", value: "234,567 mi")
                    InfoCards(title: "Next Service", value: "Dec 15, 2023")
                }
                
                VStack(alignment: .leading) {
                    Text("Current Service Details").font(.headline)
                    DetailRow(title: "Service Type", value: "Preventive Maintenance")
                    DetailRow(title: "Technician", value: "John Smith")
                    DetailRow(title: "Service Start", value: "Dec 15, 2023 - 9:30 AM")
                    DetailRow(title: "Location", value: "Central Shop")
                }.padding(20)
                    .background(Color(.white))
                    .cornerRadius(20)
//                    .background(Color(.systemGray6))
                
                VStack(alignment: .leading) {
                    Text("Service Items").font(.headline)
                    ServiceItemRow(name: "Oil Change", time: "10:15 AM")
                    ServiceItemRow(name: "Brake Inspection", time: "11:00 AM")
                    ServiceItemRow(name: "Tire Rotation", time: "11:45 AM")
                    ServiceItemRow(name: "Filter Replacement", time: "12:30 AM")
                }
                .padding(20)
                .background(Color(.white))
                .cornerRadius(20)
//                .background(Color(.systemGray6))
                
                VStack(alignment: .leading) {
                    Text("Parts Used").font(.headline)
                    DetailRow(title: "Engine Oil (5W-300)", value: "1")
                    DetailRow(title: "Oil Filter", value: "1")
                    DetailRow(title: "Air Filter", value: "1")
                    DetailRow(title: "Brake Pads", value: "1")
                }
                .padding(20)
                .background(Color(.white))
                .cornerRadius(20)
//                .frame(width: 350,height: 45)
                   
            }
            .padding()
//            .padding(20)
            .background(Color(.systemGray6))
        }
        
        .navigationTitle("Details")
    }
}

struct InfoCards: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title).font(.caption).foregroundColor(.gray)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.white))
        .cornerRadius(10)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}

struct ServiceItemRow: View {
    let name: String
    let time: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            VStack(alignment: .leading) {
                Text(name).bold()
                Text("Completed").font(.caption).foregroundColor(.green)
            }
            Spacer()
            Text(time).font(.subheadline).foregroundColor(.gray)
        }
        .padding(.vertical, 4)
        
    }
}

struct MaintenanceDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MaintenanceDetailsView()
        }
    }
}

