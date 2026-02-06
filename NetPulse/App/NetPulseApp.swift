//
//  NetPulseApp.swift
//  NetPulse
//

import SwiftUI
import Combine

@main
struct NetPulseApp: App {
    @StateObject private var userManager = UserManager()
    @StateObject private var sessionManager = SessionManager()

    var body: some Scene {
        WindowGroup {
            if userManager.currentUser != nil {
                MainTabView()
                    .environmentObject(userManager)
                    .environmentObject(sessionManager)
            } else {
                RegistrationView()
                    .environmentObject(userManager)
            }
        }
    }
}
