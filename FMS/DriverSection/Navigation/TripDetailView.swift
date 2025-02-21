//
//  TripDetailView.swift
//  Navigation Screen
//
//  Created by Kushgra Grover on 20/02/25.
//

import SwiftUI
import MapKit

// MARK: - Trip Details Data Model
struct TripDetails {
    let startLocation: String
    let endLocation: String
    let tripDate: String
    let distance: String
    let vehicleName: String
    let vehicleModel: String
    let driverName: String
}

struct TripDetailView: View {
    let trip = TripDetails(
        startLocation: "infosys",
        endLocation: "Rajpura",
        tripDate: "Feb 15, 2024",
        distance: "8.5 miles",
        vehicleName: "Ford Transit",
        vehicleModel: "Model XZ2025",
        driverName: "John Smith"
    )

    var body: some View {
        ScrollView {  // 🛠️ Makes screen scrollable
            VStack(spacing: 0) {
                // **Real Map with Route**
                RouteMapView(startAddress: trip.startLocation, endAddress: trip.endLocation)
                    .frame(height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                // **Trip Status**
                Text("In Progress")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))

                // **Trip Details Section**
                VStack(alignment: .leading, spacing: 12) {
                    tripInfoRow(icon: "mappin.circle.fill", title: "Start Location", value: trip.startLocation)
                    tripInfoRow(icon: "location.fill", title: "End Location", value: trip.endLocation)

                    // **Grid Layout for Detail Boxes**
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        infoBox(icon: "calendar", title: "Trip Date", value: trip.tripDate)
                        infoBox(icon: "map.fill", title: "Distance", value: trip.distance)
                        vehicleBox(icon: "truck.box.fill", vehicleName: trip.vehicleName, model: trip.vehicleModel)  // 🚛 Truck Icon
                        infoBox(icon: "person.fill", title: "Driver", value: trip.driverName)
                    }
                    .padding(.top, 10)
                }
                .padding()

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    // **Row for Start & End Location**
    private func tripInfoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.body)
                    .bold()
            }
            Spacer()
        }
    }

    // **Standard Box for Trip Info (Date, Distance, Driver)**
    private func infoBox(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(value)
                        .font(.body)
                        .bold()
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 3)
    }

    // **Vehicle Box with Name and Model**
    private func vehicleBox(icon: String, vehicleName: String, model: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vehicle")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(vehicleName)
                        .font(.body)
                        .bold()
                    Text(model) // 🚘 Model Number
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}

// **Map View with Route**
struct RouteMapView: UIViewRepresentable {
    let startAddress: String
    let endAddress: String
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false // Hide live location
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        fetchCoordinates(for: startAddress, endAddress, on: mapView)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    // Convert addresses to coordinates & draw route
    private func fetchCoordinates(for start: String, _ end: String, on mapView: MKMapView) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(start) { startPlacemarks, _ in
            geocoder.geocodeAddressString(end) { endPlacemarks, _ in
                if let startLocation = startPlacemarks?.first?.location,
                   let endLocation = endPlacemarks?.first?.location {
                    
                    let startCoordinate = startLocation.coordinate
                    let endCoordinate = endLocation.coordinate
                    
                    let startAnnotation = MKPointAnnotation()
                    startAnnotation.coordinate = startCoordinate
                    startAnnotation.title = "Start"
                    
                    let endAnnotation = MKPointAnnotation()
                    endAnnotation.coordinate = endCoordinate
                    endAnnotation.title = "Destination"
                    
                    mapView.addAnnotations([startAnnotation, endAnnotation])
                    
                    let request = MKDirections.Request()
                    request.source = MKMapItem(placemark: MKPlacemark(coordinate: startCoordinate))
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: endCoordinate))
                    request.transportType = .automobile
                    
                    let directions = MKDirections(request: request)
                    directions.calculate { response, _ in
                        if let route = response?.routes.first {
                            mapView.addOverlay(route.polyline)
                            mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        }
                    }
                }
            }
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}

// **Preview**
struct TripDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailView()
    }
}
