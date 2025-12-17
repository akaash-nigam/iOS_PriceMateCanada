//
//  ContentView.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppState.Tab.home)
            
            ScannerView()
                .tabItem {
                    Label("Scan", systemImage: "barcode.viewfinder")
                }
                .tag(AppState.Tab.scan)
            
            ShoppingListView()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                .tag(AppState.Tab.list)
            
            FlyersView()
                .tabItem {
                    Label("Flyers", systemImage: "newspaper")
                }
                .tag(AppState.Tab.flyers)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(AppState.Tab.profile)
        }
        .accentColor(.red)
        .onAppear {
            // Update user location when app starts
            locationManager.reverseGeocode { locationString in
                if let location = locationString {
                    appState.updateUserLocation(location)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}