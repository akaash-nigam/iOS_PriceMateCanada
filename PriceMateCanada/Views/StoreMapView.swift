//
//  StoreMapView.swift
//  PriceMateCanada
//
//  MapKit integration for displaying nearby stores
//

import SwiftUI
import MapKit

// MARK: - Store Location Model
struct StoreLocation: Identifiable {
    let id = UUID()
    let store: Store
    let coordinate: CLLocationCoordinate2D
    let address: String
}

// MARK: - Enhanced Nearby Stores Map
struct EnhancedNearbyStoresMap: View {
    let stores: [Store]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832), // Toronto
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedStore: StoreLocation?
    @State private var showingDirections = false

    // Generate mock store locations around Toronto
    var storeLocations: [StoreLocation] {
        stores.enumerated().map { index, store in
            // Generate locations in a circle around Toronto
            let angle = Double(index) * (2.0 * .pi / Double(stores.count))
            let radius = store.distance / 111.0 // Rough conversion: 1 degree ≈ 111 km

            let lat = 43.6532 + radius * cos(angle)
            let lon = -79.3832 + radius * sin(angle)

            return StoreLocation(
                store: store,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                address: generateMockAddress(for: store)
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nearby Stores")
                .font(.headline)

            ZStack(alignment: .bottomTrailing) {
                // Map View
                Map(coordinateRegion: $region, annotationItems: storeLocations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        StoreMapPin(location: location, isSelected: selectedStore?.id == location.id)
                            .onTapGesture {
                                withAnimation {
                                    selectedStore = location
                                }
                            }
                    }
                }
                .frame(height: 250)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )

                // Map controls
                VStack(spacing: 8) {
                    Button(action: recenterMap) {
                        Image(systemName: "location.fill")
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }

                    Button(action: { showingDirections = true }) {
                        Image(systemName: "map.fill")
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                .padding()
            }

            // Selected Store Info
            if let selectedStore = selectedStore {
                SelectedStoreCard(location: selectedStore) {
                    openInMaps(location: selectedStore)
                }
            }
        }
        .sheet(isPresented: $showingDirections) {
            StoreDirectionsView(stores: storeLocations)
        }
        .onAppear {
            if let firstStore = storeLocations.first {
                region.center = firstStore.coordinate
            }
        }
    }

    private func recenterMap() {
        withAnimation {
            if let selectedStore = selectedStore {
                region.center = selectedStore.coordinate
            } else if let firstStore = storeLocations.first {
                region.center = firstStore.coordinate
            }
        }
    }

    private func openInMaps(location: StoreLocation) {
        let placemark = MKPlacemark(coordinate: location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.store.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    private func generateMockAddress(for store: Store) -> String {
        let streets = ["Queen St W", "Yonge St", "Bloor St W", "Dundas St E", "King St W", "College St"]
        let randomStreet = streets.randomElement() ?? "Main St"
        let randomNumber = Int.random(in: 100...9999)
        return "\(randomNumber) \(randomStreet), Toronto, ON"
    }
}

// MARK: - Store Map Pin
struct StoreMapPin: View {
    let location: StoreLocation
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.red : Color.blue)
                    .frame(width: 40, height: 40)
                    .shadow(radius: 4)

                Image(systemName: "cart.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }

            // Pin pointer
            Triangle()
                .fill(isSelected ? Color.red : Color.blue)
                .frame(width: 12, height: 8)
                .offset(y: -2)
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Triangle Shape for Pin
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Selected Store Card
struct SelectedStoreCard: View {
    let location: StoreLocation
    let onDirections: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(location.store.name)
                    .font(.headline)

                Text(location.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                    Text("\(String(format: "%.1f", location.store.distance)) km away")
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }

            Spacer()

            Button(action: onDirections) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                    Text("Directions")
                        .font(.caption2)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Store Directions View
struct StoreDirectionsView: View {
    @Environment(\.dismiss) var dismiss
    let stores: [StoreLocation]
    @State private var selectedStores = Set<UUID>()
    @State private var travelMode: TravelMode = .driving

    enum TravelMode: String, CaseIterable {
        case driving = "Driving"
        case walking = "Walking"
        case transit = "Transit"

        var icon: String {
            switch self {
            case .driving: return "car.fill"
            case .walking: return "figure.walk"
            case .transit: return "bus.fill"
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Info Banner
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "map.fill")
                            .foregroundColor(.blue)
                        Text("Plan Your Shopping Route")
                            .fontWeight(.medium)
                    }

                    Text("Select stores to visit and we'll optimize your route to save time and fuel.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))

                // Travel Mode Picker
                Picker("Travel Mode", selection: $travelMode) {
                    ForEach(TravelMode.allCases, id: \.self) { mode in
                        Label(mode.rawValue, systemImage: mode.icon)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                // Store List
                List(stores) { location in
                    HStack {
                        Button(action: {
                            if selectedStores.contains(location.id) {
                                selectedStores.remove(location.id)
                            } else {
                                selectedStores.insert(location.id)
                            }
                        }) {
                            Image(systemName: selectedStores.contains(location.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedStores.contains(location.id) ? .green : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(location.store.name)
                                .fontWeight(.medium)

                            Text(location.address)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("\(String(format: "%.1f", location.store.distance)) km • ~\(estimatedTime(for: location)) min")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }

                // Action Button
                if !selectedStores.isEmpty {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(selectedStores.count) stores selected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Est. \(totalTime()) min")
                                    .font(.headline)
                            }

                            Spacer()

                            Button(action: startNavigation) {
                                Text("Start Navigation")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .cornerRadius(25)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                    }
                }
            }
            .navigationTitle("Directions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func estimatedTime(for location: StoreLocation) -> Int {
        switch travelMode {
        case .driving:
            return Int(location.store.distance * 2) + 5 // ~2 min per km + 5 min buffer
        case .walking:
            return Int(location.store.distance * 12) // ~12 min per km
        case .transit:
            return Int(location.store.distance * 4) + 10 // ~4 min per km + wait time
        }
    }

    private func totalTime() -> Int {
        let selectedLocations = stores.filter { selectedStores.contains($0.id) }
        return selectedLocations.reduce(0) { $0 + estimatedTime(for: $1) }
    }

    private func startNavigation() {
        // In a real app, this would launch Apple Maps with multi-stop directions
        let selectedLocations = stores.filter { selectedStores.contains($0.id) }

        if let firstLocation = selectedLocations.first {
            let placemark = MKPlacemark(coordinate: firstLocation.coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = firstLocation.store.name
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        }

        dismiss()
    }
}

// MARK: - Previews
struct EnhancedNearbyStoresMap_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedNearbyStoresMap(stores: [
            Store(name: "Loblaws", logo: "cart.fill", distance: 1.2),
            Store(name: "Metro", logo: "cart.fill", distance: 2.5),
            Store(name: "Walmart", logo: "cart.fill", distance: 3.8),
            Store(name: "Costco", logo: "cart.fill", distance: 5.1)
        ])
        .padding()
    }
}
