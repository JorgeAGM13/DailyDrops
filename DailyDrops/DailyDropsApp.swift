//  DailyDropsApp.swift

//  DailyDrops

//  Created by ByteBosses


import SwiftUI
import UserNotifications

@main
struct DailyDropsApp: App {
    let notificationDelegate = NotificationDelegate()

    init() {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
