//
//  User.swift
//  NetPulse
//

import Foundation

struct User: Codable, Identifiable {
    /// Статус по умолчанию — онлайн.
    var status: UserStatus = .online
    let id: UUID
    let name: String
    let email: String
    /// Уникальный никнейм пользователя (для поиска и QR).
    let username: String
    /// Кастомный статус, заданный пользователем.
    var customStatus: String?
    /// Список друзей — по умолчанию пустой (важно для декодирования из Firebase).
    var friendsList: [UUID] = []
    /// Хеш пароля (hex), для входа по паролю.
    var passwordHash: String?
    /// Соль для проверки пароля (hex).
    var passwordSalt: String?

    private enum CodingKeys: String, CodingKey {
        case id, name, email, username, status, customStatus, friendsList, passwordHash, passwordSalt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        email = try c.decode(String.self, forKey: .email)
        let decodedUsername = try c.decodeIfPresent(String.self, forKey: .username)
        username = decodedUsername ?? User.makeUsername(name: name, email: email)
        status = (try c.decodeIfPresent(UserStatus.self, forKey: .status)) ?? .online
        customStatus = try c.decodeIfPresent(String.self, forKey: .customStatus)
        friendsList = (try c.decodeIfPresent([UUID].self, forKey: .friendsList)) ?? []
        passwordHash = try c.decodeIfPresent(String.self, forKey: .passwordHash)
        passwordSalt = try c.decodeIfPresent(String.self, forKey: .passwordSalt)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(email, forKey: .email)
        try c.encode(username, forKey: .username)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(customStatus, forKey: .customStatus)
        try c.encode(friendsList, forKey: .friendsList)
        try c.encodeIfPresent(passwordHash, forKey: .passwordHash)
        try c.encodeIfPresent(passwordSalt, forKey: .passwordSalt)
    }

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        username: String? = nil,
        status: UserStatus = .online,
        friendsList: [UUID] = [],
        customStatus: String? = nil,
        password: String? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.username = username ?? User.makeUsername(name: name, email: email)
        self.status = status
        self.friendsList = friendsList
        self.customStatus = customStatus
        if let password = password, !password.isEmpty {
            let (saltHex, hashHex) = PasswordHasher.hashForStorage(password: password)
            self.passwordSalt = saltHex
            self.passwordHash = hashHex
        } else {
            self.passwordHash = nil
            self.passwordSalt = nil
        }
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
