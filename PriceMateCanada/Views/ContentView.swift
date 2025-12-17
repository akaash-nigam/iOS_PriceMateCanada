//
//  ContentView.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
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
                    Label("Flyers", systemImage: "newspaper.fill")
                }
                .tag(AppState.Tab.flyers)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(AppState.Tab.profile)
        }
        .tint(Color(red: 0.8, green: 0.1, blue: 0.1)) // Canadian red
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}