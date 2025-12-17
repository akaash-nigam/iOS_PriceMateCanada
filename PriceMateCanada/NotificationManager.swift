//
//  NotificationManager.swift
//  PriceMateCanada
//
//  Created on 2025-08-29.
//

import SwiftUI
import UserNotifications
import UIKit
import CoreLocation

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var lastError: Error?
    
    override init() {
        super.init()
        requestAuthorization()
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.lastError = error
                }
                self.checkAuthorizationStatus()
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    // MARK: - Price Alert Notifications
    
    func schedulePriceAlert(for product: Product, store: Store, targetPrice: Double) {
        guard authorizationStatus == .authorized else {
            print("Notification permission not granted")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Price Alert!"
        content.body = "\(product.name) is now $\(String(format: "%.2f", targetPrice)) at \(store.name) - At your target price!"
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        // Add action buttons
        let viewAction = UNNotificationAction(identifier: "VIEW_DEAL", title: "View Deal", options: [])
        let addToListAction = UNNotificationAction(identifier: "ADD_TO_LIST", title: "Add to List", options: [])
        let category = UNNotificationCategory(identifier: "PRICE_ALERT", actions: [viewAction, addToListAction], intentIdentifiers: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "PRICE_ALERT"
        
        // Create trigger - for demo, trigger immediately; in real app would check actual prices
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "price_alert_\(product.id)_\(store.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.lastError = error
                }
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // MARK: - Deal Notifications
    
    func scheduleWeeklyFlyerNotification() {
        guard authorizationStatus == .authorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "New Weekly Flyers Available!"
        content.body = "Check out this week's best deals from Metro, Loblaws, and more stores near you."
        content.sound = .default
        
        // Schedule for every Thursday at 9 AM (when new flyers typically come out)
        var dateComponents = DateComponents()
        dateComponents.weekday = 5 // Thursday
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly_flyers", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling weekly flyer notification: \(error)")
            }
        }
    }
    
    // MARK: - Shopping Reminder Notifications
    
    func scheduleShoppingReminder(for item: ShoppingItem) {
        guard authorizationStatus == .authorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Shopping Reminder"
        content.body = "Don't forget to buy \(item.name) from your shopping list!"
        content.sound = .default
        
        // Schedule for 2 hours from now as a reminder
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2 * 60 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: "shopping_reminder_\(item.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling shopping reminder: \(error)")
            }
        }
    }
    
    // MARK: - Location-based Notifications
    
    func scheduleLocationBasedNotification(for store: Store, userLocation: CLLocation) {
        guard authorizationStatus == .authorized else { return }
        
        // For this demo, we'll create a mock location check
        // In real implementation, you would have store coordinates
        let content = UNMutableNotificationContent()
        content.title = "You're near \(store.name)!"
        content.body = "Check out current deals and prices while you're here."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "location_\(store.id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling location notification: \(error)")
            }
        }
    }
    
    // MARK: - Utility Functions
    
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func clearNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    func testNotification() {
        guard authorizationStatus == .authorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "PriceMate Test"
        content.body = "Push notifications are working correctly!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending test notification: \(error)")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
        let notificationId = response.notification.request.identifier
        
        switch identifier {
        case "VIEW_DEAL":
            // Open app to deals view
            break
        case "ADD_TO_LIST":
            // Add item to shopping list
            break
        default:
            // Default action (tap notification)
            break
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }
}

// MARK: - Preview Support

struct NotificationSettingsView: View {
    @ObservedObject var notificationManager = NotificationManager.shared
    @State private var showTestAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Notification Settings")
                .font(.title)
            
            Group {
                switch notificationManager.authorizationStatus {
                case .notDetermined:
                    Text("Notification permission not requested")
                        .foregroundColor(.gray)
                case .denied:
                    Text("Notifications disabled")
                        .foregroundColor(.red)
                    Button("Open Settings") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                case .authorized, .provisional, .ephemeral:
                    Text("Notifications enabled")
                        .foregroundColor(.green)
                    Button("Test Notification") {
                        notificationManager.testNotification()
                        showTestAlert = true
                    }
                @unknown default:
                    Text("Unknown status")
                }
            }
            
            if let error = notificationManager.lastError {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .alert("Test Sent", isPresented: $showTestAlert) {
            Button("OK") { }
        } message: {
            Text("Test notification scheduled")
        }
    }
}