# PriceMate Canada - Feature Roadmap

## Priority Features (To Implement)

### 1. Real Barcode Scanning 🎯
- Integrate AVFoundation camera for actual barcode scanning
- Replace placeholder scanner with real camera view
- Connect to product database API (Open Food Facts or custom)
- Add manual barcode entry option
- Support for various barcode formats (UPC, EAN, etc.)

### 3. Location Services 📍
- Use CoreLocation to find nearby stores
- Calculate real distances from user location
- Show store hours and contact information
- Add turn-by-turn directions integration
- Store locator map view

### 4. Data Persistence 💾
- Add Core Data or SwiftData for offline storage
- Save shopping lists locally
- Store price history and comparisons
- Cache product information
- Save user preferences and settings
- Sync across devices with CloudKit

### 6. Push Notifications 🔔
- Price drop alerts for watched items
- Weekly flyer release notifications
- Shopping list reminders
- Sale ending alerts
- Custom price threshold notifications

## Future Considerations

### 2. Store Price Integration 💰 (APIs to be researched)
- Connect to real Canadian store APIs (Loblaws, Metro, etc.)
- Implement web scraping for stores without APIs
- Add price history tracking
- Real-time inventory checking
- Digital receipt integration

### 5. French Localization 🇨🇦
- Implement full bilingual support
- Add Localizable.strings files
- Support Quebec market requirements
- French-first option for Quebec users
- Bilingual product search

## Technical Implementation Order
1. **Real Barcode Scanning** - Core functionality
2. **Data Persistence** - Foundation for all features
3. **Location Services** - Enhanced user experience
4. **Push Notifications** - User engagement

## Notes
- Store API integration pending research on available Canadian retail APIs
- Consider PIPEDA compliance for all data features
- Ensure offline functionality for core features