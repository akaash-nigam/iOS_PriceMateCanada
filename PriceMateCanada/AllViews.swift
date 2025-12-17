//
//  AllViews.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI
import AVFoundation

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var locationManager: LocationManager
    @State private var showNearbyStores = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Location Header
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.red)
                        Text(appState.userLocation)
                            .font(.subheadline)
                        Spacer()
                        Button(action: { showNearbyStores = true }) {
                            Text("Nearby Stores")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Actions")
                            .font(.headline)
                        
                        HStack(spacing: 15) {
                            QuickActionButton(icon: "barcode.viewfinder", title: "Scan Product", color: .red) {
                                appState.selectedTab = .scan
                            }
                            QuickActionButton(icon: "list.bullet", title: "Shopping List", color: .blue) {
                                appState.selectedTab = .list
                            }
                            QuickActionButton(icon: "newspaper", title: "Weekly Flyers", color: .green) {
                                appState.selectedTab = .flyers
                            }
                            QuickActionButton(icon: "bell", title: "Price Alerts", color: .orange) {
                                // Show price alerts
                            }
                        }
                    }
                    
                    // Recent Scans
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Scans")
                            .font(.headline)
                        
                        Text("No recent scans")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    // Today's Best Deals
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Today's Best Deals")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                DealCard(storeName: "Metro", discount: "30% OFF", category: "Produce")
                                DealCard(storeName: "Loblaws", discount: "Buy 2 Get 1", category: "Dairy")
                                DealCard(storeName: "No Frills", discount: "$2 OFF", category: "Bakery")
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("PriceMate Canada")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showNearbyStores) {
                NearbyStoresView(locationManager: locationManager)
                    .environmentObject(appState)
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.1))
                    .cornerRadius(10)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct DealCard: View {
    let storeName: String
    let discount: String
    let category: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(storeName)
                .font(.headline)
            Text(discount)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.red)
            Text(category)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 150)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - Scanner View
struct ScannerView: View {
    @EnvironmentObject var appState: AppState
    @State private var isScanning = false
    @State private var scannedCode: String?
    @State private var showManualEntry = false
    @State private var manualBarcode = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isScanning {
                    // Real barcode scanner
                    BarcodeScannerView(scannedCode: $scannedCode, isScanning: $isScanning)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Spacer()
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 100))
                        .foregroundColor(.gray)
                    Text("Tap to start scanning")
                        .foregroundColor(.gray)
                    Spacer()
                    
                    VStack(spacing: 15) {
                        Button(action: {
                            isScanning = true
                        }) {
                            Text("Start Scanning")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        // Manual entry option
                        Button(action: {
                            showManualEntry = true
                        }) {
                            Label("Enter barcode manually", systemImage: "keyboard")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle("Scan Product")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: isScanning ? Button("Cancel") {
                isScanning = false
            } : nil)
            .sheet(isPresented: .constant(scannedCode != nil)) {
                if let code = scannedCode {
                    PriceComparisonView(barcode: code)
                        .environmentObject(appState)
                        .onDisappear {
                            scannedCode = nil
                        }
                }
            }
            .sheet(isPresented: $showManualEntry) {
                ManualBarcodeEntryView(barcode: $manualBarcode, isPresented: $showManualEntry) {
                    if !manualBarcode.isEmpty {
                        scannedCode = manualBarcode
                        manualBarcode = ""
                    }
                }
            }
        }
    }
}

// MARK: - Manual Barcode Entry View
struct ManualBarcodeEntryView: View {
    @Binding var barcode: String
    @Binding var isPresented: Bool
    let onSubmit: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Barcode Number")) {
                    TextField("Barcode", text: $barcode)
                        .keyboardType(.numberPad)
                        .focused($isFocused)
                }
                
                Section {
                    Text("Enter the numbers below the barcode")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSubmit()
                        isPresented = false
                    }
                    .disabled(barcode.isEmpty)
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
}

// MARK: - Price Comparison View
struct PriceComparisonView: View {
    let barcode: String
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Price Comparison")
                    .font(.title)
                Text("Barcode: \(barcode)")
                    .foregroundColor(.gray)
                
                // Mock product data - in real app this would come from API
                Text("Product: Example Product")
                    .padding()
                
                Button(action: {
                    // Save scan to history
                    appState.addScanToHistory(barcode: barcode, product: nil)
                    dismiss()
                }) {
                    Text("Add to Shopping List")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Compare Prices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { 
                        appState.addScanToHistory(barcode: barcode, product: nil)
                        dismiss() 
                    }
                }
            }
        }
        .onAppear {
            // Save to scan history when view appears
            appState.addScanToHistory(barcode: barcode, product: nil)
        }
    }
}

// MARK: - Shopping List View
struct ShoppingListView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddItem = false
    
    var body: some View {
        NavigationView {
            VStack {
                if appState.shoppingList.isEmpty {
                    Spacer()
                    Image(systemName: "cart")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Your shopping list is empty")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(appState.shoppingList) { item in
                            Button(action: {
                                appState.toggleShoppingItem(item)
                            }) {
                                HStack {
                                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isChecked ? .green : .gray)
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .strikethrough(item.isChecked)
                                            .foregroundColor(.primary)
                                        Text("Qty: \(item.quantity)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                appState.removeFromShoppingList(appState.shoppingList[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddItem = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddShoppingItemView(isPresented: $showAddItem)
                    .environmentObject(appState)
            }
        }
    }
}

// MARK: - Add Shopping Item View
struct AddShoppingItemView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var notificationManager: NotificationManager
    @Binding var isPresented: Bool
    
    @State private var itemName = ""
    @State private var quantity = "1"
    @State private var category = "Groceries"
    @State private var targetPrice = ""
    
    let categories = ["Groceries", "Produce", "Dairy", "Meat", "Bakery", "Frozen", "Beverages", "Snacks", "Health", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item name", text: $itemName)
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("1", text: $quantity)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat)
                        }
                    }
                }
                
                Section(header: Text("Target Price (Optional)")) {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $targetPrice)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !itemName.isEmpty {
                            let item = ShoppingItem(
                                name: itemName,
                                quantity: Int(quantity) ?? 1,
                                targetPrice: Double(targetPrice),
                                category: category,
                                isChecked: false
                            )
                            appState.addToShoppingList(item)
                            
                            // Schedule price alert notification if target price is set
                            if let targetPrice = item.targetPrice, targetPrice > 0 {
                                // Create a mock product and store for notification (in real app, would use actual data)
                                let product = Product(
                                    barcode: "",
                                    name: item.name,
                                    brand: "Unknown",
                                    imageUrl: nil,
                                    category: item.category,
                                    prices: []
                                )
                                let store = Store(name: "Your preferred stores", logo: "", distance: 0)
                                
                                notificationManager.schedulePriceAlert(for: product, store: store, targetPrice: targetPrice)
                            }
                            
                            isPresented = false
                        }
                    }
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Flyers View
struct FlyersView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(["Metro", "Loblaws", "No Frills", "Walmart"], id: \.self) { store in
                        FlyerCard(storeName: store)
                    }
                }
                .padding()
            }
            .navigationTitle("Weekly Flyers")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FlyerCard: View {
    let storeName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(storeName)
                    .font(.headline)
                Spacer()
                Text("Valid until Dec 31")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 150)
                .overlay(
                    Text("Flyer Preview")
                        .foregroundColor(.gray)
                )
            
            HStack {
                Button(action: {}) {
                    Label("View Flyer", systemImage: "doc.text")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                Spacer()
                Button(action: {}) {
                    Label("Save Deals", systemImage: "bookmark")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var notificationsEnabled = true
    @State private var showInFrench = false
    @State private var showNotificationTest = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Account") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("Guest User")
                                .font(.headline)
                            Text("Sign in to sync your data")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    Button(action: {}) {
                        Text("Sign In / Create Account")
                            .foregroundColor(.red)
                    }
                }
                
                Section("Preferences") {
                    HStack {
                        Label("Location", systemImage: "location")
                        Spacer()
                        Text(appState.userLocation)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Label("Push Notifications", systemImage: "bell")
                        Spacer()
                        Group {
                            switch notificationManager.authorizationStatus {
                            case .authorized, .provisional, .ephemeral:
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Enabled")
                                    .foregroundColor(.green)
                            case .denied:
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Disabled")
                                    .foregroundColor(.red)
                            case .notDetermined:
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(.orange)
                                Text("Not Set")
                                    .foregroundColor(.orange)
                            @unknown default:
                                Text("Unknown")
                                    .foregroundColor(.gray)
                            }
                        }
                        .font(.caption)
                    }
                    .onTapGesture {
                        if notificationManager.authorizationStatus == .denied {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        } else if notificationManager.authorizationStatus == .notDetermined {
                            notificationManager.requestAuthorization()
                        }
                    }
                    
                    Toggle("Afficher en français", isOn: $showInFrench)
                    
                    if notificationManager.authorizationStatus == .authorized {
                        Button("Test Notification") {
                            notificationManager.testNotification()
                            showNotificationTest = true
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
                
                Section {
                    Button(action: {}) {
                        Text("Contact Support")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .alert("Test Notification Sent", isPresented: $showNotificationTest) {
                Button("OK") { }
            } message: {
                Text("Check your notification center to see the test notification")
            }
        }
    }
}