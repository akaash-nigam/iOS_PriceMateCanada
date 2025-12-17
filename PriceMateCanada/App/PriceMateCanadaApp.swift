//
//  PriceMateCanadaApp.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI

@main
struct PriceMateCanadaApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var isScanning = false
    @Published var shoppingList: [ShoppingItem] = []
    @Published var priceAlerts: [PriceAlert] = []
    @Published var userLocation: String = "Toronto, ON"
    @Published var preferredStores: [Store] = []
    
    enum Tab {
        case home
        case scan
        case list
        case flyers
        case profile
    }
}

// MARK: - Models
struct ShoppingItem: Identifiable {
    let id = UUID()
    var name: String
    var quantity: Int
    var targetPrice: Double?
    var category: String
    var isChecked: Bool = false
}

struct PriceAlert: Identifiable {
    let id = UUID()
    var productName: String
    var targetPrice: Double
    var currentPrice: Double
    var store: Store
    var isActive: Bool
}

struct Store: Identifiable {
    let id = UUID()
    var name: String
    var logo: String
    var distance: Double
    var isPreferred: Bool = false
}

struct Product: Identifiable {
    let id = UUID()
    var barcode: String
    var name: String
    var brand: String
    var imageUrl: String?
    var category: String
    var prices: [PriceEntry]
}

struct PriceEntry: Identifiable {
    let id = UUID()
    var store: Store
    var price: Double
    var regularPrice: Double?
    var saleEndDate: Date?
    var unitPrice: String?
    var inStock: Bool
    var lastUpdated: Date
}