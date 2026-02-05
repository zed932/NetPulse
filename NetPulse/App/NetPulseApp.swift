//
//  NetPulseApp.swift
//  NetPulse
//

import SwiftUI

@main
struct NetPulseApp: App {
    @StateObject private var userManager = UserManager()

    var body: some Scene {
        WindowGroup {
            if userManager.currentUser != nil {
                MainTabView()
                    .environmentObject(userManager)
            } else {
                RegistrationView()
                    .environmentObject(userManager)
            }
        }
    }
}
