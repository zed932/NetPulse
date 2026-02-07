//
//  FriendRequest.swift
//  NetPulse
//

import Foundation

/// Статус заявки в друзья.
enum FriendRequestStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    /// Отменена отправителем.
    case cancelled = "cancelled"

    var displayTitle: String {
        switch self {
        case .pending: return "Ожидает"
        case .accepted: return "Принято"
        case .declined: return "Отклонено"
        case .cancelled: return "Отменено"
        }
    }
}

/// Заявка в друзья (от кого, кому, статус).
struct FriendRequest: Identifiable, Codable, Equatable {
    let id: UUID
    let fromUserId: UUID
    let toUserId: UUID
    var status: FriendRequestStatus
    let createdAt: Date

    init(
        id: UUID = UUID(),
        fromUserId: UUID,
        toUserId: UUID,
        status: FriendRequestStatus = .pending,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.status = status
        self.createdAt = createdAt
    }
}
