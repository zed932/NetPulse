//
//  MainTabView.swift
//  NetPulse
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        TabView {
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Статус")
            }

            NavigationStack {
                FriendsScreen()
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Друзья")
            }

            NavigationStack {
                ActiveSessionView()
            }
            .tabItem {
                Image(systemName: "timer")
                Text("Сессия")
            }
        }
    }
}
