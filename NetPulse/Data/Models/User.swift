//
//  User.swift
//  NetPulse
//

import Foundation

struct User: Codable, Identifiable {
    var status: UserStatus
    let id: UUID
    let name: String
    let email: String
    /// Уникальный никнейм пользователя (для поиска и QR).
    let username: String
    /// Кастомный статус, заданный пользователем.
    var customStatus: String?
    var friendsList: [UUID]

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        username: String? = nil,
        status: UserStatus = .online,
        friendsList: [UUID] = [],
        customStatus: String? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.username = username ?? User.makeUsername(name: name, email: email)
        self.status = status
        self.friendsList = friendsList
        self.customStatus = customStatus
    }

    /// Отображаемый статус: сначала кастомный, потом предопределённый.
    var displayStatus: String {
        if let custom = customStatus?.trimmingCharacters(in: .whitespacesAndNewlines),
           !custom.isEmpty {
            return custom
        }
        return status.description
    }

    mutating func updateStatus(_ newStatus: UserStatus) {
        self.status = newStatus
        // При выборе предопределённого статуса сбрасываем кастомный.
        self.customStatus = nil
    }

    mutating func toggleStatus() {
        switch status {
        case .online:
            status = .offline
        case .offline:
            status = .online
        case .working:
            status = .online
        case .studying:
            status = .online
        }
        customStatus = nil
    }

    mutating func addFriend(_ friendId: UUID) {
        guard !friendsList.contains(friendId) else { return }
        friendsList.append(friendId)
    }

    private static func makeUsername(name: String, email: String) -> String {
        if let localPart = email.split(separator: "@").first, !localPart.isEmpty {
            return String(localPart).lowercased()
        }
        return name
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
    }
}
