//
//  HomeView.swift
//  NetPulse
//

import SwiftUI

/// Главный экран: приветствие, статус и список друзей.
struct HomeView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var friendsViewModel = FriendsListViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let user = userManager.currentUser {
                    profileSection(user: user)
                }

                invitationsSection
                friendsSection
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("NetPulse")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private func profileSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Привет, \(user.name)!")
                .font(.title2.bold())

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Текущий статус")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(user.displayStatus)
                        .font(.headline)
                }
                Spacer()
                NavigationLink {
                    ProfileView()
                } label: {
                    Text("Изменить")
                }
                .buttonStyle(SecondaryButtonStyle())
                .frame(maxWidth: 140)
            }
        }
        .appCard()
    }

    private var invitationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Приглашения")
                .font(.headline)
            IncomingInvitationsView()
        }
        .appCard()
    }

    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Друзья")
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

            TextField("Поиск по имени или email", text: $friendsViewModel.searchQuery)
                .textFieldStyle(.roundedBorder)

            if friendsViewModel.friends(userManager: userManager).isEmpty {
                Text("Пока нет друзей. Добавьте кого‑нибудь, чтобы начать совместные сессии.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            } else {
                VStack(spacing: 8) {
                    ForEach(friendsViewModel.friends(userManager: userManager)) { user in
                        FriendRowView(user: user)
                    }
                }
            }
        }
        .appCard()
    }
}

private struct FriendRowView: View {
    let user: User
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var userManager: UserManager
    @State private var inviteTarget: User?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                Text(user.displayStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if user.status == .online {
                Button("Пригласить") {
                    inviteTarget = user
                }
                .buttonStyle(.bordered)
            }
        }
        .sheet(item: $inviteTarget) { friend in
            SendInvitationView(friend: friend)
        }
    }
}

