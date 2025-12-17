//
//  PriceComparisonView.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI

struct PriceComparisonView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    let barcode: String
    
    @State private var product: Product? = nil
    @State private var isLoading = true
    @State private var showingAddToList = false
    @State private var showingPriceAlert = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Finding best prices...")
                        .padding()
                } else if let product = product {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Product Header
                            ProductHeader(product: product)
                            
                            // Quick Actions
                            HStack(spacing: 16) {
                                Button(action: { showingAddToList = true }) {
                                    Label("Add to List", systemImage: "plus.circle.fill")
                                        .font(.caption)
                                }
                                .buttonStyle(ActionButtonStyle(color: .blue))
                                
                                Button(action: { showingPriceAlert = true }) {
                                    Label("Price Alert", systemImage: "bell.fill")
                                        .font(.caption)
                                }
                                .buttonStyle(ActionButtonStyle(color: .orange))
                            }
                            .padding(.horizontal)
                            
                            // Price Comparison
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Price Comparison")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(product.prices) { priceEntry in
                                    PriceRow(priceEntry: priceEntry, product: product)
                                }
                            }
                            
                            // Price History
                            PriceHistoryChart(product: product)
                                .padding(.horizontal)
                            
                            // Nearby Stores Map
                            NearbyStoresMap()
                                .frame(height: 200)
                                .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Product not found")
                            .font(.headline)
                        Text("Try scanning again or enter the barcode manually")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Price Comparison")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadProductData()
            }
            .sheet(isPresented: $showingAddToList) {
                AddToListView(product: product ?? createMockProduct())
            }
            .sheet(isPresented: $showingPriceAlert) {
                PriceAlertView(product: product ?? createMockProduct())
            }
        }
    }
    
    private func loadProductData() {
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.product = createMockProduct()
            self.isLoading = false
        }
    }
    
    private func createMockProduct() -> Product {
        let stores = [
            Store(name: "Loblaws", logo: "cart.fill", distance: 1.2),
            Store(name: "Metro", logo: "cart.fill", distance: 2.5),
            Store(name: "Walmart", logo: "cart.fill", distance: 3.8),
            Store(name: "Sobeys", logo: "cart.fill", distance: 4.1),
            Store(name: "Costco", logo: "cart.fill", distance: 5.2)
        ]
        
        let prices = [
            PriceEntry(store: stores[0], price: 4.99, regularPrice: 5.99, saleEndDate: Date().addingTimeInterval(86400 * 3), unitPrice: "$1.25/100g", inStock: true, lastUpdated: Date()),
            PriceEntry(store: stores[1], price: 5.49, regularPrice: 5.49, saleEndDate: nil, unitPrice: "$1.37/100g", inStock: true, lastUpdated: Date()),
            PriceEntry(store: stores[2], price: 4.47, regularPrice: 4.97, saleEndDate: Date().addingTimeInterval(86400 * 5), unitPrice: "$1.12/100g", inStock: true, lastUpdated: Date()),
            PriceEntry(store: stores[3], price: 5.99, regularPrice: 5.99, saleEndDate: nil, unitPrice: "$1.50/100g", inStock: false, lastUpdated: Date()),
            PriceEntry(store: stores[4], price: 3.99, regularPrice: 4.99, saleEndDate: Date().addingTimeInterval(86400 * 7), unitPrice: "$1.00/100g", inStock: true, lastUpdated: Date())
        ]
        
        return Product(
            barcode: barcode,
            name: "Christie Oreo Cookies",
            brand: "Christie",
            imageUrl: nil,
            category: "Snacks & Cookies",
            prices: prices
        )
    }
}

// MARK: - Components

struct ProductHeader: View {
    let product: Product
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Product Image
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(product.brand)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(product.name)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(product.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                Text("Barcode: \(product.barcode)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct PriceRow: View {
    let priceEntry: PriceEntry
    let product: Product
    
    var lowestPrice: Bool {
        guard let minPrice = product.prices.map({ $0.price }).min() else { return false }
        return priceEntry.price == minPrice
    }
    
    var body: some View {
        HStack {
            // Store Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(priceEntry.store.name)
                        .fontWeight(.medium)
                    
                    if lowestPrice {
                        Text("LOWEST")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }
                
                HStack(spacing: 8) {
                    Text("\(String(format: "%.1f", priceEntry.store.distance)) km")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let unitPrice = priceEntry.unitPrice {
                        Text("• \(unitPrice)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !priceEntry.inStock {
                        Text("• Out of Stock")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
            
            // Price Info
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 8) {
                    if let regularPrice = priceEntry.regularPrice,
                       regularPrice > priceEntry.price {
                        Text("$\(String(format: "%.2f", regularPrice))")
                            .font(.caption)
                            .strikethrough()
                            .foregroundColor(.secondary)
                    }
                    
                    Text("$\(String(format: "%.2f", priceEntry.price))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(lowestPrice ? .green : .primary)
                }
                
                if let saleEndDate = priceEntry.saleEndDate {
                    Text("Sale ends \(saleEndDate, style: .relative)")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(lowestPrice ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct PriceHistoryChart: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price History")
                .font(.headline)
            
            // Placeholder for chart
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 150)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.largeTitle)
                            .foregroundColor(.gray.opacity(0.5))
                        Text("Price trend over last 30 days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
    }
}

struct NearbyStoresMap: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nearby Stores")
                .font(.headline)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    VStack {
                        Image(systemName: "map")
                            .font(.largeTitle)
                            .foregroundColor(.gray.opacity(0.5))
                        Text("Tap to view on map")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
    }
}

struct ActionButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

// MARK: - Add to List View
struct AddToListView: View {
    @Environment(\.dismiss) var dismiss
    let product: Product
    @State private var quantity = 1
    @State private var targetPrice = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Product") {
                    HStack {
                        Text(product.name)
                        Spacer()
                        Text(product.brand)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Quantity") {
                    Stepper(value: $quantity, in: 1...99) {
                        Text("\(quantity) item\(quantity == 1 ? "" : "s")")
                    }
                }
                
                Section("Target Price (Optional)") {
                    TextField("Enter target price", text: $targetPrice)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add to Shopping List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        // Add to shopping list
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Price Alert View
struct PriceAlertView: View {
    @Environment(\.dismiss) var dismiss
    let product: Product
    @State private var targetPrice = ""
    @State private var selectedStores: Set<String> = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Product") {
                    HStack {
                        Text(product.name)
                        Spacer()
                        Text("Current: $\(String(format: "%.2f", product.prices.first?.price ?? 0))")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Alert me when price drops to") {
                    TextField("Enter target price", text: $targetPrice)
                        .keyboardType(.decimalPad)
                }
                
                Section("Monitor these stores") {
                    ForEach(product.prices) { priceEntry in
                        HStack {
                            Text(priceEntry.store.name)
                            Spacer()
                            if selectedStores.contains(priceEntry.store.name) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedStores.contains(priceEntry.store.name) {
                                selectedStores.remove(priceEntry.store.name)
                            } else {
                                selectedStores.insert(priceEntry.store.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Set Price Alert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save price alert
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(targetPrice.isEmpty || selectedStores.isEmpty)
                }
            }
        }
        .onAppear {
            // Select all stores by default
            selectedStores = Set(product.prices.map { $0.store.name })
        }
    }
}

struct PriceComparisonView_Previews: PreviewProvider {
    static var previews: some View {
        PriceComparisonView(barcode: "0123456789")
            .environmentObject(AppState())
    }
}