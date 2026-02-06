//
//  FriendsListView.swift
//  NetPulse
//

import SwiftUI

struct FriendsListView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = FriendsListViewModel()

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(viewModel.friends(userManager: userManager)) { user in
                        HStack {
                            Text(user.name)
                            Spacer()
                            Text(user.status.description)
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    TextField("Поиск по имени или email", text: $viewModel.searchQuery)
                        .textFieldStyle(.roundedBorder)
                }

                Section {
                    NavigationLink("Добавить друга") {
                        AddFriendView()
                    }
                }
            }
            .navigationTitle("Друзья")
        }
    }
}
