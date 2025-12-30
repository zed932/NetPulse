//
//  MainTabView.swift
//  NetPulse00
//
//  Created by Сергей Мещеряков on 30.12.2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        TabView {
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Профиль")
                }
            
            FriendsListView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Друзья")
                }
        }
    }
}
