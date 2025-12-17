//
//  ShoppingListView.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject var appState: AppState
    @State private var isEditing = false
    @State private var showingAddItem = false
    @State private var selectedCategory = "All"
    @State private var showingOptimizeRoute = false
    
    let categories = ["All", "Produce", "Dairy", "Meat", "Bakery", "Snacks", "Beverages", "Other"]
    
    var filteredItems: [ShoppingItem] {
        if selectedCategory == "All" {
            return appState.shoppingList
        } else {
            return appState.shoppingList.filter { $0.category == selectedCategory }
        }
    }
    
    var totalItems: Int {
        appState.shoppingList.reduce(0) { $0 + $1.quantity }
    }
    
    var checkedItems: Int {
        appState.shoppingList.filter { $0.isChecked }.reduce(0) { $0 + $1.quantity }
    }
    
    var estimatedTotal: Double {
        // Mock calculation - in real app would use actual prices
        appState.shoppingList.reduce(0) { total, item in
            total + (Double(item.quantity) * (item.targetPrice ?? 4.99))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Header
                if !appState.shoppingList.isEmpty {
                    ProgressHeader(checkedItems: checkedItems, totalItems: totalItems, estimatedTotal: estimatedTotal)
                }
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            CategoryChip(
                                title: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding()
                }
                
                // Shopping List
                if appState.shoppingList.isEmpty {
                    EmptyListView {
                        showingAddItem = true
                    }
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            ShoppingItemRow(item: item, isEditing: isEditing) {
                                toggleItem(item)
                            }
                        }
                        .onDelete { indexSet in
                            deleteItems(at: indexSet)
                        }
                        
                        // Add Item Button in List
                        Button(action: { showingAddItem = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.red)
                                Text("Add Item")
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !appState.shoppingList.isEmpty {
                        Button(isEditing ? "Done" : "Edit") {
                            isEditing.toggle()
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !appState.shoppingList.isEmpty {
                        Button(action: { showingOptimizeRoute = true }) {
                            Image(systemName: "map")
                        }
                    }
                    
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
            .sheet(isPresented: $showingOptimizeRoute) {
                OptimizeRouteView()
            }
        }
    }
    
    private func toggleItem(_ item: ShoppingItem) {
        if let index = appState.shoppingList.firstIndex(where: { $0.id == item.id }) {
            appState.shoppingList[index].isChecked.toggle()
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredItems[$0] }
        appState.shoppingList.removeAll { item in
            itemsToDelete.contains { $0.id == item.id }
        }
    }
}

// MARK: - Components

struct ProgressHeader: View {
    let checkedItems: Int
    let totalItems: Int
    let estimatedTotal: Double
    
    var progress: Double {
        totalItems > 0 ? Double(checkedItems) / Double(totalItems) : 0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(checkedItems) of \(totalItems) items")
                        .font(.headline)
                    Text("Est. Total: $\(String(format: "%.2f", estimatedTotal))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                CircularProgressView(progress: progress)
                    .frame(width: 50, height: 50)
            }
            
            ProgressView(value: progress)
                .tint(.red)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.red, lineWidth: 4)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.bold)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.red : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ShoppingItemRow: View {
    let item: ShoppingItem
    let isEditing: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.isChecked ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .strikethrough(item.isChecked)
                    .foregroundColor(item.isChecked ? .secondary : .primary)
                
                HStack {
                    Text("Qty: \(item.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let targetPrice = item.targetPrice {
                        Text("• Target: $\(String(format: "%.2f", targetPrice))")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            if !isEditing {
                // Price Status
                if let targetPrice = item.targetPrice {
                    VStack(alignment: .trailing) {
                        Text("$\(String(format: "%.2f", targetPrice * Double(item.quantity)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Mock price status
                        if Bool.random() {
                            Text("On Sale")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyListView: View {
    let onAddItem: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("Your shopping list is empty")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add items to start saving on groceries")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onAddItem) {
                Label("Add First Item", systemImage: "plus.circle.fill")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Add Item View
struct AddItemView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var itemName = ""
    @State private var quantity = 1
    @State private var selectedCategory = "Other"
    @State private var targetPrice = ""
    @State private var searchResults: [String] = []
    
    let categories = ["Produce", "Dairy", "Meat", "Bakery", "Snacks", "Beverages", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item name", text: $itemName)
                        .onChange(of: itemName) { _ in
                            updateSearchResults()
                        }
                    
                    if !searchResults.isEmpty {
                        ForEach(searchResults, id: \.self) { result in
                            HStack {
                                Text(result)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                itemName = result
                                searchResults = []
                            }
                        }
                    }
                }
                
                Section("Quantity") {
                    Stepper(value: $quantity, in: 1...99) {
                        Text("\(quantity) item\(quantity == 1 ? "" : "s")")
                    }
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Target Price (Optional)") {
                    TextField("Enter target price", text: $targetPrice)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addItem()
                    }
                    .fontWeight(.semibold)
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }
    
    private func updateSearchResults() {
        // Mock search results
        if itemName.count > 2 {
            searchResults = [
                "\(itemName) - Brand A",
                "\(itemName) - Brand B",
                "\(itemName) - Store Brand"
            ]
        } else {
            searchResults = []
        }
    }
    
    private func addItem() {
        let newItem = ShoppingItem(
            name: itemName,
            quantity: quantity,
            targetPrice: Double(targetPrice),
            category: selectedCategory
        )
        appState.shoppingList.append(newItem)
        dismiss()
    }
}

// MARK: - Optimize Route View
struct OptimizeRouteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedStores: Set<String> = []
    
    let stores = ["Loblaws", "Metro", "Walmart", "Costco", "Sobeys", "No Frills"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Info Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("Optimize Your Shopping Route")
                            .fontWeight(.medium)
                    }
                    
                    Text("Select stores to include in your optimized route. We'll find the best prices and shortest path.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                
                Form {
                    Section("Select Stores") {
                        ForEach(stores, id: \.self) { store in
                            HStack {
                                Text(store)
                                Spacer()
                                if selectedStores.contains(store) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedStores.contains(store) {
                                    selectedStores.remove(store)
                                } else {
                                    selectedStores.insert(store)
                                }
                            }
                        }
                    }
                    
                    Section("Route Options") {
                        Toggle("Include sale items only", isOn: .constant(true))
                        Toggle("Avoid tolls", isOn: .constant(false))
                        Toggle("Walking distance only", isOn: .constant(false))
                    }
                }
                
                Button(action: {
                    // Calculate optimized route
                    dismiss()
                }) {
                    Text("Calculate Route")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding()
                .disabled(selectedStores.isEmpty)
            }
            .navigationTitle("Optimize Route")
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
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
            .environmentObject(AppState())
    }
}