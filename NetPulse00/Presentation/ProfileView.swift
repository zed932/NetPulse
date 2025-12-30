//
//  ProfileView.swift
//  NetPulse00
//
//  Created by Сергей Мещеряков on 30.12.2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            VStack {
                if let user = userManager.currentUser {
                    Text("Привет, \(user.name)!")
                        .font(.title)
                        .padding()
                    
                    Text("Статус: \(user.status.description)")
                        .padding()
                    
                    Button("Сменить статус") {
                        if let user = userManager.currentUser {
                                let newStatus: UserStatus
                                switch user.status {
                                case .online: newStatus = .offline
                                case .offline: newStatus = .working
                                case .working: newStatus = .studying
                                case .studying: newStatus = .online
                                }
                                userManager.updateCurrentUserStatus(newStatus)
                            }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Выйти") {
                        userManager.logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Профиль")
        }
    }
}
