//
//  SessionManager.swift
//  NetPulse
//

import Foundation
import SwiftUI
import Combine

/// Менеджер сессий и приглашений (по ТЗ: отправка/приём/принятие/отклонение).
/// Пока хранение in-memory; далее — синхронизация по WebSocket.
final class SessionManager: ObservableObject {
    @Published private(set) var invitations: [Invitation] = []

    /// Отправить приглашение на сессию. По ТЗ — только пользователю со статусом «Онлайн».
    func sendInvitation(from currentUser: User, to friend: User, sessionType: SessionType) -> Bool {
        guard friend.status == .online else { return false }
        guard currentUser.friendsList.contains(friend.id) else { return false }
        let inv = Invitation(
            fromUserId: currentUser.id,
            toUserId: friend.id,
            sessionType: sessionType
        )
        invitations.append(inv)
        return true
    }

    /// Входящие приглашения для пользователя (со статусом pending).
    func incomingInvitations(for user: User) -> [Invitation] {
        invitations.filter { $0.toUserId == user.id && $0.status == .pending }
    }

    /// Принять приглашение.
    func accept(_ invitation: Invitation) {
        guard let idx = invitations.firstIndex(where: { $0.id == invitation.id }) else { return }
        invitations[idx].status = .accepted
    }

    /// Отклонить приглашение.
    func decline(_ invitation: Invitation) {
        guard let idx = invitations.firstIndex(where: { $0.id == invitation.id }) else { return }
        invitations[idx].status = .declined
    }

    /// Найти отправителя приглашения по списку пользователей.
    func sender(of invitation: Invitation, in users: [User]) -> User? {
        users.first { $0.id == invitation.fromUserId }
    }
}
