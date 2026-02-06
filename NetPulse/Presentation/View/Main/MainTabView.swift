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

            NavigationView {
                ActiveSessionView()
            }
            .tabItem {
                Image(systemName: "timer")
                Text("Сессия")
            }
        }
    }
}
