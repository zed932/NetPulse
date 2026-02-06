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
                HomeView()
            }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
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
