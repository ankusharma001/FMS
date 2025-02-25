import SwiftUI

struct SOSAlert: Identifiable {
    let id = UUID()
    let name: String
    let idNumber: String
    let address: String
    let time: String
    let minutesAgo: String
}

struct SosView: View {
    let alerts: [SOSAlert] = [
        SOSAlert(name: "Michael Johnson", idNumber: "DR45892", address: "123 Emergency Street, New York, NY", time: "10:45 AM", minutesAgo: "2m ago"),
        SOSAlert(name: "Sarah Williams", idNumber: "DR45893", address: "456 Safety Avenue, Brooklyn, NY", time: "10:42 AM", minutesAgo: "5m ago"),
        SOSAlert(name: "David Brown", idNumber: "DR45894", address: "789 Alert Road, Queens, NY", time: "10:40 AM", minutesAgo: "7m ago")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) { // Adds space between cards
                    ForEach(alerts) { alert in
                        SOSCard(alert: alert)
                    }
                }
                .padding(.top, 10) // Space at the top
                .padding(.horizontal) // Prevents cards from touching screen edges
            }
            .background(Color(.systemGroupedBackground)) // Light gray background
            .navigationTitle("SOS")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Handle back action
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct SOSCard: View {
    let alert: SOSAlert
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SOS ACTIVE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(alert.time)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(alert.minutesAgo)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            
            Text(alert.name)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(alert.idNumber)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.red)
                
                Text(alert.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white) // FULL card is white now
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Subtle shadow
    }
}

struct SOSView_Previews: PreviewProvider {
    static var previews: some View {
        SosView()
    }
}
