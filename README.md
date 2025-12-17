# PriceMate Canada iOS

A smart grocery price comparison app for Canadian shoppers, built with SwiftUI for iOS.

## Features

### 🔍 Barcode Scanning
- Instant product scanning using device camera
- Manual barcode entry option
- Support for all major barcode formats (EAN, UPC, Code 128, etc.)

### 💰 Price Comparison
- Real-time price comparison across major Canadian retailers
- Shows regular price vs sale price
- Highlights the lowest price option
- Unit price calculations for easy comparison

### 📝 Shopping Lists
- Create and manage multiple shopping lists
- Set target prices for items
- Track checked/unchecked items
- Optimize shopping route across stores

### 📰 Digital Flyers
- Browse weekly flyers from all major stores
- Filter by store and category
- Search for specific deals
- Add flyer items directly to shopping list

### 🔔 Smart Alerts
- Price drop notifications
- Sale ending reminders
- New flyer alerts
- Customizable notification preferences

### 👤 Profile & Settings
- Bilingual support (English/French)
- Location-based store recommendations
- Privacy controls (PIPEDA compliant)
- Savings tracking and statistics

## Supported Stores

- Loblaws
- Metro
- Walmart
- Costco
- Sobeys
- No Frills
- Canadian Tire
- Shoppers Drug Mart

## Technical Details

### Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for state management
- **AVFoundation**: Camera and barcode scanning
- **CoreLocation**: Location services for nearby stores

### Project Structure
```
PriceMateCanada/
├── App/
│   └── PriceMateCanadaApp.swift    # App entry point & models
├── Views/
│   ├── ContentView.swift           # Tab navigation
│   ├── HomeView.swift             # Home screen with deals
│   ├── ScannerView.swift          # Barcode scanner
│   ├── PriceComparisonView.swift  # Price comparison results
│   ├── ShoppingListView.swift     # Shopping list management
│   ├── FlyersView.swift           # Digital flyers browser
│   └── ProfileView.swift          # User profile & settings
└── Info.plist                     # App permissions & config
```

## Setup Instructions

1. Open `PriceMateCanada.xcodeproj` in Xcode
2. Select your development team in project settings
3. Build and run on simulator or device

## Privacy & Compliance

- Fully PIPEDA compliant
- User data stored locally by default
- Optional cloud sync with explicit consent
- No data sharing with third parties
- Transparent privacy policy

## Localization

The app supports both official Canadian languages:
- English (en-CA)
- French (fr-CA)

## Future Enhancements

- [ ] Receipt scanning and price matching
- [ ] Loyalty card integration
- [ ] Social features (share lists, deals)
- [ ] Apple Watch companion app
- [ ] Widget support for quick price checks
- [ ] Siri Shortcuts integration

## Development Notes

- Uses mock data for development/testing
- Real API integration requires API keys
- Camera permissions required for barcode scanning
- Location permissions optional but recommended