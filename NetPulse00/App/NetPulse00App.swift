//
//  NetPulse00App.swift
//  NetPulse00
//
//  Created by Сергей Мещеряков on 29.12.2025.
//

import SwiftUI

@main
struct NetPulse00App: App {
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
