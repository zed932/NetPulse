//
//  IncomingFriendRequestsView.swift
//  NetPulse
//

import SwiftUI

/// Входящие заявки в друзья: полноэкранный список с карточками и кнопками «Принять» / «Отклонить».
struct IncomingFriendRequestsView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var didTriggerRefresh = false

    private var incoming: [FriendRequest] {
        userManager.incomingFriendRequests
    }

    var body: some View {
        Group {
            if incoming.isEmpty {
                emptyState
            } else {
                listContent
            }
        }
        .onAppear {
            if !didTriggerRefresh {
                didTriggerRefresh = true
                Task { @MainActor in
                    await userManager.refreshFromFirebaseAsync()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text("Нет входящих заявок в друзья")
                .font(.headline)
            Text("Когда кто-то отправит вам заявку, она появится здесь.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private var listContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(incoming) { request in
                    IncomingRequestCard(
                        request: request,
                        fromUser: userManager.allUsers.first { $0.id == request.fromUserId },
                        onAccept: { userManager.acceptFriendRequest(request) },
                        onDecline: { userManager.declineFriendRequest(request) }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Карточка одной входящей заявки
private struct IncomingRequestCard: View {
    let request: FriendRequest
    let fromUser: User?
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fromUser?.name ?? "Пользователь")
                        .font(.headline)
                    Text(fromUser.map { "@\($0.username)" } ?? "Загрузка…")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            HStack(spacing: 10) {
                Button(action: onAccept) {
                    Label("Принять", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: onDecline) {
                    Label("Отклонить", systemImage: "xmark.circle")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.destructive)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(AppTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Полноэкранный экран входящих заявок (для навигации)
struct IncomingFriendRequestsScreen: View {
    var body: some View {
        IncomingFriendRequestsView()
            .navigationTitle("Входящие заявки")
            .navigationBarTitleDisplayMode(.inline)
    }
}
