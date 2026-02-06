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
            Section {
                TextField("Поиск по имени или email", text: $viewModel.searchQuery)
                    .textFieldStyle(.roundedBorder)
            }

            Section("Можно добавить") {
                ForEach(viewModel.addableUsers(userManager: userManager)) { user in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
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
