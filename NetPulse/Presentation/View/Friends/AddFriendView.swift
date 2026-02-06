//
//  AddFriendView.swift
//  NetPulse
//

import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = AddFriendViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("Поиск по нику или QR‑токену") {
                TextField("Никнейм или строка из QR", text: $viewModel.usernameQuery)
                    .textFieldStyle(.roundedBorder)
                Button("Найти") {
                    viewModel.searchByUsernameOrToken(userManager: userManager)
                }

                if let user = viewModel.foundByUsername {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name)
                                .font(.headline)
                            Text("@\(user.username)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button("Добавить") {
                            if viewModel.addFriend(user, userManager: userManager) {
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }

            Section("Поиск по имени, email или нику") {
                TextField("Начните вводить имя, email или ник", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
            }

            Section("Можно добавить из списка") {
                ForEach(viewModel.addableUsers(userManager: userManager)) { user in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name)
                                .font(.headline)
                            Text("@\(user.username) · \(user.email)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(user.status.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Добавить") {
                            if viewModel.addFriend(user, userManager: userManager) {
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .navigationTitle("Добавить друга")
        .navigationBarTitleDisplayMode(.inline)
    }
}
