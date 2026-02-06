//
//  FriendsScreen.swift
//  NetPulse
//

import SwiftUI

/// Экран «Друзья»: QR, приглашения и полный список друзей.
struct FriendsScreen: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var friendsViewModel = FriendsListViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                qrSection
                invitationsSection
                friendsSection
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Друзья")
        .navigationBarTitleDisplayMode(.large)
    }

    private var qrSection: some View {
        NavigationLink {
            MyQRView()
        } label: {
            HStack {
                Image(systemName: "qrcode")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Мой QR‑код")
                        .font(.headline)
                    Text("По нему друзья смогут быстро найти вас по нику.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .appCard()
    }

    private var invitationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Приглашения в друзья и сессии")
                .font(.headline)
            IncomingInvitationsView()
        }
        .appCard()
    }

    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Все друзья")
                    .font(.headline)
                Spacer()
                NavigationLink {
                    AddFriendView()
                } label: {
                    Label("Добавить", systemImage: "person.badge.plus")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(SecondaryButtonStyle())
            }

            TextField("Поиск по имени, email или нику", text: $friendsViewModel.searchQuery)
                .textFieldStyle(.roundedBorder)

            let allFriends = friendsViewModel.friends(userManager: userManager)
            if allFriends.isEmpty {
                Text("Пока нет друзей. Добавьте кого‑нибудь, чтобы начать совместные сессии.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            } else {
                VStack(spacing: 8) {
                    ForEach(allFriends) { user in
                        FriendRowView(user: user)
                    }
                }
            }
        }
        .appCard()
    }
}

