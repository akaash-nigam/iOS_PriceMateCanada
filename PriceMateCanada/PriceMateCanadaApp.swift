//
//  PriceMateCanadaApp.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI
import UserNotifications

@main
struct PriceMateCanadaApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(locationManager)
                .environmentObject(notificationManager)
                .preferredColorScheme(.light)
                .onAppear {
                    setupNotifications()
                }
        }
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = notificationManager
        
        // Schedule weekly flyer notifications
        notificationManager.scheduleWeeklyFlyerNotification()
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
    
    private let dataRepository = DataRepository()
    
    enum Tab {
        case home
        case scan
        case list
        case flyers
        case profile
    }
    
    init() {
        loadData()
    }
    
    func loadData() {
        shoppingList = dataRepository.fetchShoppingList()
        preferredStores = dataRepository.fetchPreferredStores()
    }
    
    func addToShoppingList(_ item: ShoppingItem) {
        shoppingList.append(item)
        dataRepository.addShoppingItem(item)
    }
    
    func updateShoppingItem(_ item: ShoppingItem) {
        if let index = shoppingList.firstIndex(where: { $0.id == item.id }) {
            shoppingList[index] = item
            dataRepository.updateShoppingItem(item)
        }
    }
    
    func removeFromShoppingList(_ item: ShoppingItem) {
        shoppingList.removeAll { $0.id == item.id }
        dataRepository.deleteShoppingItem(item)
    }
    
    func toggleShoppingItem(_ item: ShoppingItem) {
        var updatedItem = item
        updatedItem.isChecked.toggle()
        updateShoppingItem(updatedItem)
    }
    
    func addScanToHistory(barcode: String, product: Product?) {
        dataRepository.addScanHistory(barcode: barcode, product: product)
    }
    
    func addPreferredStore(_ store: Store) {
        if !preferredStores.contains(where: { $0.id == store.id }) {
            preferredStores.append(store)
            dataRepository.addStore(store)
        }
    }
    
    func removePreferredStore(_ store: Store) {
        preferredStores.removeAll { $0.id == store.id }
        var updatedStore = store
        updatedStore.isPreferred = false
        dataRepository.updateStore(updatedStore)
    }
    
    func updateUserLocation(_ location: String) {
        userLocation = location
    }
}

// MARK: - Models
struct ShoppingItem: Identifiable {
    let id: UUID
    var name: String
    var quantity: Int
    var targetPrice: Double?
    var category: String
    var isChecked: Bool
    
    init(id: UUID = UUID(), name: String, quantity: Int, targetPrice: Double?, category: String, isChecked: Bool = false) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.targetPrice = targetPrice
        self.category = category
        self.isChecked = isChecked
    }
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
    let id: UUID
    var name: String
    var logo: String
    var distance: Double
    var isPreferred: Bool
    
    init(id: UUID = UUID(), name: String, logo: String, distance: Double, isPreferred: Bool = false) {
        self.id = id
        self.name = name
        self.logo = logo
        self.distance = distance
        self.isPreferred = isPreferred
    }
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