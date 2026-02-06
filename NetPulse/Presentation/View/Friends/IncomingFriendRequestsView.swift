//
//  IncomingFriendRequestsView.swift
//  NetPulse
//

import SwiftUI

/// Входящие заявки в друзья: список с кнопками «Принять» / «Отклонить».
struct IncomingFriendRequestsView: View {
    @EnvironmentObject var userManager: UserManager

    private var incoming: [FriendRequest] {
        userManager.incomingFriendRequests
    }

    var body: some View {
        Group {
            if incoming.isEmpty {
                Text("Нет входящих заявок в друзья")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(incoming) { request in
                        if let fromUser = userManager.allUsers.first(where: { $0.id == request.fromUserId }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(fromUser.name)
                                        .font(.headline)
                                    Text("@\(fromUser.username)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button("Принять") {
                                    userManager.acceptFriendRequest(request)
                                }
                                .buttonStyle(.borderedProminent)
                                Button("Отклонить") {
                                    userManager.declineFriendRequest(request)
                                }
                                .buttonStyle(.bordered)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }
}
