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

    private var pendingSent: [FriendRequest] {
        userManager.sentFriendRequests.filter { $0.status == .pending }
    }

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
                    AddFriendRow(user: user, showStatus: false)
                }
            }

            Section("Исходящие заявки") {
                if pendingSent.isEmpty {
                    Text("Нет отправленных заявок")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(pendingSent) { request in
                        if let toUser = userManager.allUsers.first(where: { $0.id == request.toUserId }) {
                            SentRequestRow(request: request, toUser: toUser)
                        }
                    }
                }
            }

            Section("Поиск по имени, email или нику") {
                TextField("Введите имя, email или ник", text: $viewModel.searchQuery)
                    .appTextField()
                let results = viewModel.addableUsers(userManager: userManager)
                if !viewModel.searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
                    if results.isEmpty {
                        Text("Никого не найдено")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(results) { user in
                            AddFriendRow(user: user, showStatus: true)
                        }
                    }
                }
            }
        }
        .navigationTitle("Добавить друга")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { @MainActor in
                await userManager.refreshFromFirebaseAsync()
                await userManager.refreshFriendRequestsAsync()
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            ZStack(alignment: .topTrailing) {
                QRScannerView { code in
                    isShowingScanner = false
                    viewModel.usernameQuery = code
                    viewModel.searchByUsernameOrToken(userManager: userManager)
                }
                .ignoresSafeArea()
                Button {
                    isShowingScanner = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white)
                }
                .padding(16)
            }
        }
    }
}

// MARK: - Строка пользователя: Добавить / Заявка отправлена / Входящая заявка (Принять | Отклонить)
private struct AddFriendRow: View {
    let user: User
    var showStatus: Bool = false
    @EnvironmentObject var userManager: UserManager

    private var incomingRequest: FriendRequest? {
        userManager.incomingRequest(from: user.id)
    }

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

            if let request = incomingRequest {
                HStack(spacing: 8) {
                    Button("Принять") {
                        userManager.acceptFriendRequest(request)
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Отклонить") {
                        userManager.declineFriendRequest(request)
                    }
                    .buttonStyle(.bordered)
                }
            } else if userManager.hasPendingSentRequest(to: user.id) {
                Text("Заявка отправлена")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Button("Добавить") {
                    _ = userManager.sendFriendRequest(to: user)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - Строка исходящей заявки (ожидает ответа) с кнопкой «Отменить»
private struct SentRequestRow: View {
    let request: FriendRequest
    let toUser: User
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(toUser.name)
                    .font(.headline)
                Text("@\(toUser.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("Ожидает")
                .font(.caption)
                .foregroundColor(.secondary)
            Button("Отменить") {
                userManager.cancelSentRequest(request)
            }
            .buttonStyle(.bordered)
        }
    }
}
