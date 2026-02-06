//
//  FriendsListView.swift
//  NetPulse
//

import SwiftUI

struct FriendsListView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var viewModel = FriendsListViewModel()
    @State private var inviteTarget: User?

    var body: some View {
        NavigationView {
            List {
                Section("Входящие приглашения") {
                    IncomingInvitationsView()
                }

                Section {
                    ForEach(viewModel.friends(userManager: userManager)) { user in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.name)
                                Text(user.status.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if user.status == .online {
                                Button("Пригласить") {
                                    inviteTarget = user
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                } header: {
                    TextField("Поиск по имени или email", text: $viewModel.searchQuery)
                        .appTextField()
                }

                Section {
                    NavigationLink("Добавить друга") {
                        AddFriendView()
                    }
                }
            }
            .navigationTitle("Друзья")
            .sheet(item: $inviteTarget) { user in
                SendInvitationView(friend: user)
            }
        }
    }
}
