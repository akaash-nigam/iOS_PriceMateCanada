//
//  ProfileView.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var notificationsEnabled = true
    @State private var locationServicesEnabled = true
    @State private var showInFrench = false
    @State private var showingLocationPicker = false
    @State private var showingAbout = false
    @State private var showingPrivacyPolicy = false
    @State private var showingSupport = false
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Header
                Section {
                    ProfileHeader()
                }
                
                // Preferences Section
                Section("Preferences") {
                    // Location
                    HStack {
                        Label("Location", systemImage: "location.fill")
                        Spacer()
                        Text(appState.userLocation)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingLocationPicker = true
                    }
                    
                    // Preferred Stores
                    NavigationLink(destination: PreferredStoresView()) {
                        Label("Preferred Stores", systemImage: "heart.fill")
                        Spacer()
                        Text("\(appState.preferredStores.count) selected")
                            .foregroundColor(.secondary)
                    }
                    
                    // Language Toggle
                    Toggle(isOn: $showInFrench) {
                        Label("Afficher en français", systemImage: "globe")
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Price Drop Alerts", systemImage: "bell.fill")
                    }
                    
                    Toggle(isOn: .constant(true)) {
                        Label("Weekly Flyer Updates", systemImage: "newspaper.fill")
                    }
                    
                    Toggle(isOn: .constant(false)) {
                        Label("Deal Recommendations", systemImage: "star.fill")
                    }
                }
                
                // Privacy Section
                Section("Privacy") {
                    Toggle(isOn: $locationServicesEnabled) {
                        Label("Location Services", systemImage: "location.circle.fill")
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        Label("Data & Privacy", systemImage: "hand.raised.fill")
                    }
                }
                
                // Savings Summary Section
                Section("Your Savings") {
                    SavingsSummaryRow(title: "Total Saved", value: "$247.82", icon: "dollarsign.circle.fill", color: .green)
                    SavingsSummaryRow(title: "Items Tracked", value: "156", icon: "barcode", color: .blue)
                    SavingsSummaryRow(title: "Price Alerts Set", value: "23", icon: "bell.badge.fill", color: .orange)
                    SavingsSummaryRow(title: "Lists Created", value: "12", icon: "list.bullet.rectangle", color: .purple)
                }
                
                // Support Section
                Section("Support") {
                    Button(action: { showingSupport = true }) {
                        Label("Help & Support", systemImage: "questionmark.circle.fill")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {}) {
                        Label("Rate PriceMate Canada", systemImage: "star.fill")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: { showingAbout = true }) {
                        Label("About", systemImage: "info.circle.fill")
                            .foregroundColor(.primary)
                    }
                }
                
                // Legal Section
                Section {
                    Button(action: { showingPrivacyPolicy = true }) {
                        Text("Privacy Policy")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {}) {
                        Text("Terms of Service")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Version")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView(selectedLocation: $appState.userLocation)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingSupport) {
                SupportView()
            }
        }
    }
}

// MARK: - Components

struct ProfileHeader: View {
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red, Color.orange]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Text("PM")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("PriceMate User")
                    .font(.headline)
                
                Text("Member since November 2024")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("Eco Shopper")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct SavingsSummaryRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Sub Views

struct PreferredStoresView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedStores = Set<String>()
    
    let allStores = [
        Store(name: "Loblaws", logo: "cart.fill", distance: 1.2),
        Store(name: "Metro", logo: "cart.fill", distance: 2.5),
        Store(name: "Walmart", logo: "cart.fill", distance: 3.8),
        Store(name: "Costco", logo: "cart.fill", distance: 5.1),
        Store(name: "Sobeys", logo: "cart.fill", distance: 4.3),
        Store(name: "No Frills", logo: "cart.fill", distance: 2.9),
        Store(name: "Canadian Tire", logo: "wrench.fill", distance: 3.5),
        Store(name: "Shoppers Drug Mart", logo: "cross.fill", distance: 1.8)
    ]
    
    var body: some View {
        List {
            Section {
                Text("Select your preferred stores to get personalized deals and price comparisons")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
            
            Section("Available Stores") {
                ForEach(allStores) { store in
                    HStack {
                        Image(systemName: store.logo)
                            .font(.title2)
                            .foregroundColor(.gray)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text(store.name)
                                .fontWeight(.medium)
                            Text("\(String(format: "%.1f", store.distance)) km away")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedStores.contains(store.name) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedStores.contains(store.name) {
                            selectedStores.remove(store.name)
                        } else {
                            selectedStores.insert(store.name)
                        }
                    }
                }
            }
        }
        .navigationTitle("Preferred Stores")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedStores = Set(appState.preferredStores.map { $0.name })
        }
        .onDisappear {
            appState.preferredStores = allStores.filter { selectedStores.contains($0.name) }
        }
    }
}

struct PrivacySettingsView: View {
    @State private var shareAnonymousData = true
    @State private var personalizedAds = false
    @State private var shareWithPartners = false
    
    var body: some View {
        Form {
            Section {
                Text("Your privacy is important to us. We comply with PIPEDA and all Canadian privacy regulations.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
            
            Section("Data Collection") {
                Toggle("Share Anonymous Usage Data", isOn: $shareAnonymousData)
                Toggle("Personalized Recommendations", isOn: $personalizedAds)
                Toggle("Share Data with Partners", isOn: $shareWithPartners)
            }
            
            Section("Data Management") {
                Button("Download My Data") {
                    // Handle data download
                }
                
                Button("Delete My Account") {
                    // Handle account deletion
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Data & Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LocationPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLocation: String
    @State private var searchText = ""
    
    let cities = [
        "Toronto, ON",
        "Montreal, QC",
        "Vancouver, BC",
        "Calgary, AB",
        "Edmonton, AB",
        "Ottawa, ON",
        "Winnipeg, MB",
        "Quebec City, QC",
        "Hamilton, ON",
        "Kitchener, ON",
        "London, ON",
        "Halifax, NS",
        "Oshawa, ON",
        "Victoria, BC",
        "Windsor, ON",
        "Saskatoon, SK",
        "Regina, SK",
        "St. John's, NL",
        "Barrie, ON",
        "Kelowna, BC"
    ]
    
    var filteredCities: [String] {
        if searchText.isEmpty {
            return cities
        }
        return cities.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding()
                
                List(filteredCities, id: \.self) { city in
                    HStack {
                        Text(city)
                        Spacer()
                        if selectedLocation == city {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedLocation = city
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Location")
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

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // App Icon
                    HStack {
                        Spacer()
                        Image(systemName: "cart.fill.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PriceMate Canada")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Your smart grocery shopping companion for finding the best prices across Canadian stores.")
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Divider()
                        
                        Text("Features")
                            .font(.headline)
                        
                        FeatureRow(icon: "barcode", title: "Barcode Scanning", description: "Instantly compare prices")
                        FeatureRow(icon: "dollarsign.circle", title: "Price Tracking", description: "Monitor price changes")
                        FeatureRow(icon: "bell", title: "Smart Alerts", description: "Get notified of price drops")
                        FeatureRow(icon: "list.bullet", title: "Shopping Lists", description: "Organize your shopping")
                        FeatureRow(icon: "newspaper", title: "Digital Flyers", description: "Browse weekly deals")
                        
                        Divider()
                        
                        Text("Made with 🇨🇦 in Canada")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.red)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("Last updated: November 2024")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PolicySection(
                            title: "Information We Collect",
                            content: "We collect information you provide directly to us, such as when you create an account, use our barcode scanning feature, or create shopping lists. This may include your location (with permission), shopping preferences, and product searches."
                        )
                        
                        PolicySection(
                            title: "How We Use Your Information",
                            content: "We use the information we collect to provide and improve our services, including price comparisons, personalized deals, and shopping recommendations. We never sell your personal information."
                        )
                        
                        PolicySection(
                            title: "PIPEDA Compliance",
                            content: "PriceMate Canada complies with the Personal Information Protection and Electronic Documents Act (PIPEDA) and all applicable Canadian privacy laws. You have the right to access, correct, or delete your personal information at any time."
                        )
                        
                        PolicySection(
                            title: "Data Security",
                            content: "We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction."
                        )
                        
                        PolicySection(
                            title: "Contact Us",
                            content: "If you have any questions about this Privacy Policy, please contact us at privacy@pricematecanada.ca"
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct SupportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Get Help") {
                    NavigationLink(destination: EmptyView()) {
                        Label("FAQs", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink(destination: EmptyView()) {
                        Label("How to Use", systemImage: "book")
                    }
                    
                    NavigationLink(destination: EmptyView()) {
                        Label("Troubleshooting", systemImage: "wrench")
                    }
                }
                
                Section("Contact Support") {
                    Button(action: {}) {
                        Label("Email Support", systemImage: "envelope")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {}) {
                        Label("Report a Bug", systemImage: "ant")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {}) {
                        Label("Request a Feature", systemImage: "lightbulb")
                            .foregroundColor(.primary)
                    }
                }
                
                Section("Community") {
                    Button(action: {}) {
                        Label("Join our Facebook Group", systemImage: "person.3")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {}) {
                        Label("Follow on Twitter", systemImage: "bird")
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AppState())
    }
}