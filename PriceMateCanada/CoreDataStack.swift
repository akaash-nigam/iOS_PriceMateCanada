//
//  CoreDataStack.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

// MARK: - Core Data Managed Object Classes
@objc(CDShoppingItem)
public class CDShoppingItem: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var quantity: Int16
    @NSManaged public var targetPrice: Double
    @NSManaged public var category: String?
    @NSManaged public var isChecked: Bool
}

@objc(CDPriceAlert)
public class CDPriceAlert: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var productName: String?
    @NSManaged public var targetPrice: Double
    @NSManaged public var currentPrice: Double
    @NSManaged public var storeId: UUID?
    @NSManaged public var isActive: Bool
}

@objc(CDStore)
public class CDStore: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var logo: String?
    @NSManaged public var distance: Double
    @NSManaged public var isPreferred: Bool
}

@objc(CDProduct)
public class CDProduct: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var barcode: String?
    @NSManaged public var name: String?
    @NSManaged public var brand: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var category: String?
    @NSManaged public var scanHistory: NSSet?
}

@objc(CDScanHistory)
public class CDScanHistory: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var barcode: String?
    @NSManaged public var scanDate: Date?
    @NSManaged public var product: CDProduct?
}

// MARK: - Core Data Repository
class DataRepository {
    private let coreDataStack = CoreDataStack.shared
    
    // MARK: - Shopping List
    func fetchShoppingList() -> [ShoppingItem] {
        let request = NSFetchRequest<CDShoppingItem>(entityName: "CDShoppingItem")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let cdItems = try coreDataStack.context.fetch(request)
            return cdItems.compactMap { cdItem -> ShoppingItem? in
                guard let id = cdItem.id,
                      let name = cdItem.name,
                      let category = cdItem.category else { return nil }
                
                return ShoppingItem(
                    id: id,
                    name: name,
                    quantity: Int(cdItem.quantity),
                    targetPrice: cdItem.targetPrice > 0 ? cdItem.targetPrice : nil,
                    category: category,
                    isChecked: cdItem.isChecked
                )
            }
        } catch {
            print("Error fetching shopping list: \(error)")
            return []
        }
    }
    
    func addShoppingItem(_ item: ShoppingItem) {
        let cdItem = CDShoppingItem(context: coreDataStack.context)
        cdItem.id = item.id
        cdItem.name = item.name
        cdItem.quantity = Int16(item.quantity)
        cdItem.targetPrice = item.targetPrice ?? 0
        cdItem.category = item.category
        cdItem.isChecked = item.isChecked
        
        coreDataStack.save()
    }
    
    func updateShoppingItem(_ item: ShoppingItem) {
        let request = NSFetchRequest<CDShoppingItem>(entityName: "CDShoppingItem")
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        do {
            let results = try coreDataStack.context.fetch(request)
            if let cdItem = results.first {
                cdItem.name = item.name
                cdItem.quantity = Int16(item.quantity)
                cdItem.targetPrice = item.targetPrice ?? 0
                cdItem.category = item.category
                cdItem.isChecked = item.isChecked
                coreDataStack.save()
            }
        } catch {
            print("Error updating shopping item: \(error)")
        }
    }
    
    func deleteShoppingItem(_ item: ShoppingItem) {
        let request = NSFetchRequest<CDShoppingItem>(entityName: "CDShoppingItem")
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        do {
            let results = try coreDataStack.context.fetch(request)
            if let cdItem = results.first {
                coreDataStack.context.delete(cdItem)
                coreDataStack.save()
            }
        } catch {
            print("Error deleting shopping item: \(error)")
        }
    }
    
    // MARK: - Scan History
    func addScanHistory(barcode: String, product: Product?) {
        let scanHistory = CDScanHistory(context: coreDataStack.context)
        scanHistory.id = UUID()
        scanHistory.barcode = barcode
        scanHistory.scanDate = Date()
        
        if let product = product {
            // Check if product already exists
            let request = NSFetchRequest<CDProduct>(entityName: "CDProduct")
            request.predicate = NSPredicate(format: "barcode == %@", barcode)
            
            do {
                let results = try coreDataStack.context.fetch(request)
                if let existingProduct = results.first {
                    scanHistory.product = existingProduct
                } else {
                    // Create new product
                    let cdProduct = CDProduct(context: coreDataStack.context)
                    cdProduct.id = product.id
                    cdProduct.barcode = product.barcode
                    cdProduct.name = product.name
                    cdProduct.brand = product.brand
                    cdProduct.imageUrl = product.imageUrl
                    cdProduct.category = product.category
                    scanHistory.product = cdProduct
                }
            } catch {
                print("Error checking for existing product: \(error)")
            }
        }
        
        coreDataStack.save()
    }
    
    func fetchRecentScans(limit: Int = 10) -> [CDScanHistory] {
        let request = NSFetchRequest<CDScanHistory>(entityName: "CDScanHistory")
        request.sortDescriptors = [NSSortDescriptor(key: "scanDate", ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try coreDataStack.context.fetch(request)
        } catch {
            print("Error fetching recent scans: \(error)")
            return []
        }
    }
    
    // MARK: - Stores
    func fetchPreferredStores() -> [Store] {
        let request = NSFetchRequest<CDStore>(entityName: "CDStore")
        request.predicate = NSPredicate(format: "isPreferred == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "distance", ascending: true)]
        
        do {
            let cdStores = try coreDataStack.context.fetch(request)
            return cdStores.compactMap { cdStore -> Store? in
                guard let id = cdStore.id,
                      let name = cdStore.name,
                      let logo = cdStore.logo else { return nil }
                
                return Store(
                    id: id,
                    name: name,
                    logo: logo,
                    distance: cdStore.distance,
                    isPreferred: cdStore.isPreferred
                )
            }
        } catch {
            print("Error fetching preferred stores: \(error)")
            return []
        }
    }
    
    func addStore(_ store: Store) {
        let cdStore = CDStore(context: coreDataStack.context)
        cdStore.id = store.id
        cdStore.name = store.name
        cdStore.logo = store.logo
        cdStore.distance = store.distance
        cdStore.isPreferred = store.isPreferred
        
        coreDataStack.save()
    }
    
    func updateStore(_ store: Store) {
        let request = NSFetchRequest<CDStore>(entityName: "CDStore")
        request.predicate = NSPredicate(format: "id == %@", store.id as CVarArg)
        
        do {
            let results = try coreDataStack.context.fetch(request)
            if let cdStore = results.first {
                cdStore.name = store.name
                cdStore.logo = store.logo
                cdStore.distance = store.distance
                cdStore.isPreferred = store.isPreferred
                coreDataStack.save()
            }
        } catch {
            print("Error updating store: \(error)")
        }
    }
}