//
//  AddFriendView.swift
//  NetPulse
//

import SwiftUI

struct AddFriendView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = AddFriendViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingScanner = false

    var body: some View {
        List {
            Section("Поиск по нику или QR‑токену") {
                TextField("Никнейм или строка из QR", text: $viewModel.usernameQuery)
                    .appTextField()
                Button("Найти") {
                    viewModel.searchByUsernameOrToken(userManager: userManager)
                }
                 Button {
                     isShowingScanner = true
                 } label: {
                     Label("Сканировать QR", systemImage: "qrcode.viewfinder")
                 }

                if let user = viewModel.foundByUsername {
                    AddFriendRow(user: user, showStatus: false, viewModel: viewModel, userManager: userManager, onSent: { })
                }
            }

            Section("Поиск по имени, email или нику") {
                TextField("Начните вводить имя, email или ник", text: $viewModel.searchQuery)
                    .appTextField()
            }

            Section("Можно добавить из списка") {
                ForEach(viewModel.addableUsers(userManager: userManager)) { user in
                    AddFriendRow(user: user, showStatus: true, viewModel: viewModel, userManager: userManager, onSent: { })
                }
            }
        }
        .navigationTitle("Добавить друга")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { @MainActor in
                await userManager.refreshFromFirebaseAsync()
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            QRScannerView { code in
                isShowingScanner = false
                viewModel.usernameQuery = code
                viewModel.searchByUsernameOrToken(userManager: userManager)
            }
        }
    }
}

// MARK: - Строка с кнопкой «Добавить» / «Заявка отправлена»
private struct AddFriendRow: View {
    let user: User
    var showStatus: Bool = false
    @ObservedObject var viewModel: AddFriendViewModel
    @EnvironmentObject var userManager: UserManager
    var onSent: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name)
                    .font(.headline)
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            if showStatus {
                Text(user.status.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if viewModel.hasPendingRequest(to: user, userManager: userManager) {
                Text("Заявка отправлена")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Button("Добавить") {
                    if viewModel.sendFriendRequest(to: user, userManager: userManager) {
                        onSent()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
