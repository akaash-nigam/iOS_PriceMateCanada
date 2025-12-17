//
//  HomeView.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var showingLocationPicker = false
    
    let mockDeals = [
        Deal(title: "Milk 2% 4L", store: "Loblaws", price: 5.99, regularPrice: 7.49, savings: 20),
        Deal(title: "Chicken Breast", store: "Metro", price: 8.99, regularPrice: 12.99, savings: 31),
        Deal(title: "Bread Whole Wheat", store: "Walmart", price: 2.47, regularPrice: 3.99, savings: 38),
        Deal(title: "Bananas per lb", store: "Sobeys", price: 0.59, regularPrice: 0.89, savings: 34)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    // Location Header
                    LocationHeader(location: appState.userLocation) {
                        showingLocationPicker = true
                    }
                    .padding(.horizontal)
                    
                    // Quick Actions
                    QuickActionsGrid()
                        .padding(.horizontal)
                    
                    // Today's Best Deals
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Best Deals")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(mockDeals) { deal in
                                    DealCard(deal: deal)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Nearby Stores
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stores Near You")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            StoreRow(name: "Loblaws", distance: 1.2, isOpen: true)
                            StoreRow(name: "Metro", distance: 2.5, isOpen: true)
                            StoreRow(name: "Walmart", distance: 3.8, isOpen: false)
                            StoreRow(name: "Costco", distance: 5.1, isOpen: true)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .navigationTitle("PriceMate Canada")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Components

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search products or stores...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 8)
    }
}

struct LocationHeader: View {
    let location: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.red)
                Text(location)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickActionsGrid: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            QuickActionButton(
                title: "Scan Product",
                icon: "barcode.viewfinder",
                color: .blue
            ) {
                appState.selectedTab = .scan
            }
            
            QuickActionButton(
                title: "Price Alerts",
                icon: "bell.fill",
                color: .orange
            ) {
                // Navigate to alerts
            }
            
            QuickActionButton(
                title: "Shopping List",
                icon: "list.bullet",
                color: .green
            ) {
                appState.selectedTab = .list
            }
            
            QuickActionButton(
                title: "Weekly Flyers",
                icon: "newspaper.fill",
                color: .purple
            ) {
                appState.selectedTab = .flyers
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
        }
    }
}

struct DealCard: View {
    let deal: Deal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Store Badge
            Text(deal.store)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(8)
            
            // Product Name
            Text(deal.title)
                .font(.headline)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Price Info
            HStack {
                Text("$\(String(format: "%.2f", deal.price))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                Text("$\(String(format: "%.2f", deal.regularPrice))")
                    .font(.body)
                    .strikethrough()
                    .foregroundColor(.secondary)
            }
            
            // Savings Badge
            Text("Save \(deal.savings)%")
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding()
        .frame(width: 180)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct StoreRow: View {
    let name: String
    let distance: Double
    let isOpen: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "cart.fill")
                .font(.title2)
                .foregroundColor(.gray)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    Text("\(String(format: "%.1f", distance)) km")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(isOpen ? "Open" : "Closed")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(isOpen ? .green : .red)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Models
struct Deal: Identifiable {
    let id = UUID()
    let title: String
    let store: String
    let price: Double
    let regularPrice: Double
    let savings: Int
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppState())
    }
}