//
//  Invitation.swift
//  NetPulse
//

import Foundation

/// Статус приглашения на сессию.
enum InvitationStatus: String, Codable {
    case pending = "Ожидает"
    case accepted = "Принято"
    case declined = "Отклонено"
}

/// Приглашение на совместную сессию (по ТЗ).
struct Invitation: Identifiable, Codable {
    let id: UUID
    let fromUserId: UUID
    let toUserId: UUID
    let sessionType: SessionType
    var status: InvitationStatus
    let sentAt: Date

    init(
        id: UUID = UUID(),
        fromUserId: UUID,
        toUserId: UUID,
        sessionType: SessionType,
        status: InvitationStatus = .pending,
        sentAt: Date = Date()
    ) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.sessionType = sessionType
        self.status = status
        self.sentAt = sentAt
    }
}
