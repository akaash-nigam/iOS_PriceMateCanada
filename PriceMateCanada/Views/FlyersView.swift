//
//  FlyersView.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI

struct FlyersView: View {
    @State private var selectedStore: String = "All Stores"
    @State private var selectedCategory: String = "All Categories"
    @State private var searchText = ""
    @State private var showingFlyerDetail = false
    @State private var selectedFlyer: Flyer? = nil
    
    let stores = ["All Stores", "Loblaws", "Metro", "Walmart", "Costco", "Sobeys", "No Frills", "Canadian Tire"]
    let categories = ["All Categories", "Grocery", "Electronics", "Home & Garden", "Clothing", "Pharmacy", "Seasonal"]
    
    var filteredFlyers: [Flyer] {
        var flyers = mockFlyers
        
        if selectedStore != "All Stores" {
            flyers = flyers.filter { $0.storeName == selectedStore }
        }
        
        if selectedCategory != "All Categories" {
            flyers = flyers.filter { $0.category == selectedCategory }
        }
        
        if !searchText.isEmpty {
            flyers = flyers.filter {
                $0.storeName.lowercased().contains(searchText.lowercased()) ||
                $0.title.lowercased().contains(searchText.lowercased())
            }
        }
        
        return flyers
    }
    
    let mockFlyers = [
        Flyer(storeName: "Loblaws", title: "Weekly Savings", category: "Grocery", validUntil: Date().addingTimeInterval(86400 * 5), coverImage: "cart.fill", dealCount: 142, isNew: true),
        Flyer(storeName: "Metro", title: "Super Weekend Sale", category: "Grocery", validUntil: Date().addingTimeInterval(86400 * 3), coverImage: "cart.fill", dealCount: 89, isNew: false),
        Flyer(storeName: "Canadian Tire", title: "Spring Into Savings", category: "Home & Garden", validUntil: Date().addingTimeInterval(86400 * 7), coverImage: "wrench.and.screwdriver.fill", dealCount: 215, isNew: true),
        Flyer(storeName: "Walmart", title: "Rollback Prices", category: "Grocery", validUntil: Date().addingTimeInterval(86400 * 4), coverImage: "cart.fill", dealCount: 178, isNew: false),
        Flyer(storeName: "Costco", title: "Member Exclusive", category: "Electronics", validUntil: Date().addingTimeInterval(86400 * 10), coverImage: "cart.fill", dealCount: 67, isNew: false),
        Flyer(storeName: "Sobeys", title: "Fresh Deals", category: "Grocery", validUntil: Date().addingTimeInterval(86400 * 6), coverImage: "cart.fill", dealCount: 124, isNew: true)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Filters
                VStack(spacing: 12) {
                    // Store Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(stores, id: \.self) { store in
                                FilterChip(
                                    title: store,
                                    isSelected: selectedStore == store
                                ) {
                                    selectedStore = store
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                FilterChip(
                                    title: category,
                                    isSelected: selectedCategory == category,
                                    color: .orange
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Flyers Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredFlyers) { flyer in
                            FlyerCard(flyer: flyer)
                                .onTapGesture {
                                    selectedFlyer = flyer
                                    showingFlyerDetail = true
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Weekly Flyers")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingFlyerDetail) {
                if let flyer = selectedFlyer {
                    FlyerDetailView(flyer: flyer)
                }
            }
        }
    }
}

// MARK: - Components

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .red
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct FlyerCard: View {
    let flyer: Flyer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover Image
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red.opacity(0.8), Color.orange.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)
                    .overlay(
                        VStack {
                            Image(systemName: flyer.coverImage)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text("\(flyer.dealCount) Deals")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    )
                
                if flyer.isNew {
                    Text("NEW")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(8)
                }
            }
            
            // Flyer Info
            VStack(alignment: .leading, spacing: 8) {
                Text(flyer.storeName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(flyer.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text("Valid until \(flyer.validUntil, style: .date)")
                        .font(.caption2)
                }
                .foregroundColor(.orange)
            }
            .padding(12)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Flyer Detail View

struct FlyerDetailView: View {
    @Environment(\.dismiss) var dismiss
    let flyer: Flyer
    @State private var selectedDeal: FlyerDeal? = nil
    @State private var showingAddToList = false
    @State private var searchText = ""
    
    let mockDeals = [
        FlyerDeal(productName: "Chicken Breast Family Pack", originalPrice: 15.99, salePrice: 9.99, savings: 37, unit: "per lb", category: "Meat", limit: "Limit 2"),
        FlyerDeal(productName: "Coca-Cola 12 Pack", originalPrice: 7.99, salePrice: 3.99, savings: 50, unit: "355ml x 12", category: "Beverages", limit: nil),
        FlyerDeal(productName: "Wonder Bread", originalPrice: 3.49, salePrice: 1.99, savings: 43, unit: "675g", category: "Bakery", limit: "Limit 4"),
        FlyerDeal(productName: "Bananas", originalPrice: 1.29, salePrice: 0.69, savings: 47, unit: "per lb", category: "Produce", limit: nil),
        FlyerDeal(productName: "Milk 2% 4L", originalPrice: 6.49, salePrice: 4.99, savings: 23, unit: "4L", category: "Dairy", limit: "Limit 2"),
        FlyerDeal(productName: "Eggs Large", originalPrice: 4.99, salePrice: 2.99, savings: 40, unit: "12 pack", category: "Dairy", limit: nil)
    ]
    
    var filteredDeals: [FlyerDeal] {
        if searchText.isEmpty {
            return mockDeals
        }
        return mockDeals.filter {
            $0.productName.lowercased().contains(searchText.lowercased()) ||
            $0.category.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Flyer Header
                FlyerHeader(flyer: flyer)
                
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
                // Deals List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredDeals) { deal in
                            FlyerDealRow(deal: deal) {
                                selectedDeal = deal
                                showingAddToList = true
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(flyer.storeName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddToList) {
                if let deal = selectedDeal {
                    AddDealToListView(deal: deal)
                }
            }
        }
    }
}

struct FlyerHeader: View {
    let flyer: Flyer
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flyer.title)
                        .font(.headline)
                    Text("Valid until \(flyer.validUntil, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(flyer.dealCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("Total Deals")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                Button(action: {}) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.caption)
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button(action: {}) {
                    Label("Download PDF", systemImage: "arrow.down.doc")
                        .font(.caption)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
}

struct FlyerDealRow: View {
    let deal: FlyerDeal
    let onAddToList: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Product Image Placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(deal.productName)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    Text(deal.unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let limit = deal.limit {
                        Text("• \(limit)")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                HStack {
                    Text("$\(String(format: "%.2f", deal.originalPrice))")
                        .font(.caption)
                        .strikethrough()
                        .foregroundColor(.secondary)
                    
                    Text("$\(String(format: "%.2f", deal.salePrice))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    Text("Save \(deal.savings)%")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            Button(action: onAddToList) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct AddDealToListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    let deal: FlyerDeal
    @State private var quantity = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section("Product") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(deal.productName)
                            .fontWeight(.medium)
                        
                        HStack {
                            Text(deal.unit)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.2f", deal.salePrice))")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("Quantity") {
                    Stepper(value: $quantity, in: 1...99) {
                        Text("\(quantity) item\(quantity == 1 ? "" : "s")")
                    }
                }
                
                Section {
                    HStack {
                        Text("Total")
                            .fontWeight(.medium)
                        Spacer()
                        Text("$\(String(format: "%.2f", deal.salePrice * Double(quantity)))")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add to List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addToList()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func addToList() {
        let newItem = ShoppingItem(
            name: deal.productName,
            quantity: quantity,
            targetPrice: deal.salePrice,
            category: deal.category
        )
        appState.shoppingList.append(newItem)
        dismiss()
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

// MARK: - Models

struct Flyer: Identifiable {
    let id = UUID()
    let storeName: String
    let title: String
    let category: String
    let validUntil: Date
    let coverImage: String
    let dealCount: Int
    let isNew: Bool
}

struct FlyerDeal: Identifiable {
    let id = UUID()
    let productName: String
    let originalPrice: Double
    let salePrice: Double
    let savings: Int
    let unit: String
    let category: String
    let limit: String?
}

struct FlyersView_Previews: PreviewProvider {
    static var previews: some View {
        FlyersView()
            .environmentObject(AppState())
    }
}