//
//  LocationManager.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastError: Error?
    @Published var nearbyStores: [Store] = []
    
    // Canadian store chains with their typical locations
    let storeChains = [
        ("Metro", "metro_logo"),
        ("Loblaws", "loblaws_logo"),
        ("No Frills", "nofrills_logo"),
        ("Walmart", "walmart_logo"),
        ("Costco", "costco_logo"),
        ("Sobeys", "sobeys_logo"),
        ("FreshCo", "freshco_logo"),
        ("Food Basics", "foodbasics_logo"),
        ("Save-On-Foods", "saveonfoods_logo"),
        ("Real Canadian Superstore", "superstore_logo")
    ]
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
            requestLocationPermission()
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func searchNearbyStores() {
        guard let location = userLocation else { return }
        
        // Simulate nearby stores based on location
        // In a real app, this would call an API or use local database
        nearbyStores = generateMockStores(near: location)
    }
    
    private func generateMockStores(near location: CLLocation) -> [Store] {
        var stores: [Store] = []
        
        // Generate 5-10 random stores within 5km radius
        let numberOfStores = Int.random(in: 5...10)
        
        for i in 0..<numberOfStores {
            let randomIndex = Int.random(in: 0..<storeChains.count)
            let (name, logo) = storeChains[randomIndex]
            
            // Generate random distance (0.1 to 5.0 km)
            let distance = Double.random(in: 0.1...5.0)
            
            let store = Store(
                name: name,
                logo: logo,
                distance: distance,
                isPreferred: i < 3 // First 3 stores are preferred
            )
            stores.append(store)
        }
        
        // Sort by distance
        stores.sort { $0.distance < $1.distance }
        
        return stores
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        
        // Update nearby stores when location changes significantly
        if let previousLocation = userLocation {
            let distance = location.distance(from: previousLocation)
            if distance > 100 { // More than 100 meters
                searchNearbyStores()
            }
        } else {
            searchNearbyStores()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        lastError = error
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        case .denied, .restricted:
            // Handle denied access
            nearbyStores = []
        case .notDetermined:
            // Request authorization
            requestLocationPermission()
        @unknown default:
            break
        }
    }
    
    // MARK: - Geocoding
    
    func reverseGeocode(completion: @escaping (String?) -> Void) {
        guard let location = userLocation else {
            completion(nil)
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil,
                  let placemark = placemarks?.first else {
                completion(nil)
                return
            }
            
            var locationString = ""
            
            if let city = placemark.locality {
                locationString = city
            }
            
            if let province = placemark.administrativeArea {
                if !locationString.isEmpty {
                    locationString += ", "
                }
                locationString += province
            }
            
            completion(locationString.isEmpty ? nil : locationString)
        }
    }
}

// MARK: - Location Permission View
struct LocationPermissionView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Enable Location Services")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("PriceMate needs your location to find nearby stores and show you the best deals in your area.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Button(action: {
                locationManager.requestLocationPermission()
            }) {
                Text("Enable Location")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: {}) {
                Text("Not Now")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

// MARK: - Nearby Stores View
struct NearbyStoresView: View {
    @ObservedObject var locationManager: LocationManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack {
                if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                    // Location denied
                    VStack(spacing: 20) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Location Services Disabled")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("Enable location services in Settings to see nearby stores")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Open Settings")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                } else if locationManager.nearbyStores.isEmpty {
                    // No stores or loading
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                    Text("Searching for nearby stores...")
                        .foregroundColor(.gray)
                } else {
                    // Store list
                    List(locationManager.nearbyStores) { store in
                        HStack {
                            // Store logo placeholder
                            Image(systemName: "building.2.crop.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(store.name)
                                    .font(.headline)
                                Text("\(String(format: "%.1f", store.distance)) km away")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                var updatedStore = store
                                updatedStore.isPreferred.toggle()
                                
                                if updatedStore.isPreferred {
                                    appState.addPreferredStore(updatedStore)
                                } else {
                                    appState.removePreferredStore(updatedStore)
                                }
                            }) {
                                Image(systemName: store.isPreferred ? "star.fill" : "star")
                                    .foregroundColor(store.isPreferred ? .yellow : .gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Nearby Stores")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                locationManager.startUpdatingLocation()
            }
            .onDisappear {
                locationManager.stopUpdatingLocation()
            }
        }
    }
}