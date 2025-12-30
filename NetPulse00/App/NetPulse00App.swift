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
            Group {
                if let currentUser = userManager.currentUser {
                    ContentView(user: currentUser)
                        .environmentObject(userManager)
                } else {
                    RegistrationView()
                        .environmentObject(userManager)
                }
            }
        }
    }
}
