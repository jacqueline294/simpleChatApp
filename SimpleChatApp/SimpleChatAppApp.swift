//
//  SimpleChatAppApp.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI
import FirebaseCore
import UserNotifications // Import UserNotifications

// AppDelegate for Push Notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // Using a static variable to hold AuthViewModel. This is a common workaround.
    // Ensure this is set appropriately, e.g., when the app starts and AuthViewModel is initialized.
    static var authViewModel: AuthViewModel?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() // Ensure Firebase is configured here if not done elsewhere or if done multiple times.
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
                return
            }
            if granted {
                print("Notification authorization granted.")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("Notification authorization denied.")
            }
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let hexStringToken = tokenParts.joined()
        print("FCM Device Token: \(hexStringToken)")
        
        // Access AuthViewModel through the static variable
        if let authViewModel = AppDelegate.authViewModel {
            authViewModel.updateUserFCMToken(token: hexStringToken)
        } else {
            print("AuthViewModel not available in AppDelegate.")
            // Optionally, store the token temporarily and update when AuthViewModel becomes available
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // Handle foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Received foreground notification: \(userInfo)")
        // Show alert, sound, and badge for foreground notifications
        completionHandler([.banner, .sound, .badge])
    }

    // Handle background/inactive notifications tapped by user
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Received background/tapped notification: \(userInfo)")
        // Handle the notification (e.g., navigate to a specific screen)
        completionHandler()
    }
}

@main
struct SimpleChatAppApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authViewModel = AuthViewModel() // Make sure AuthViewModel is @StateObject

    init() {
        // FirebaseApp.configure() // Already configured in AppDelegate or here. Ensure it's configured once.
        // Set the static authViewModel in AppDelegate
        AppDelegate.authViewModel = authViewModel
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel) // Inject authViewModel
        }
    }
}
