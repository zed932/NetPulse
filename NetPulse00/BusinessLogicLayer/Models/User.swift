//
//  User.swift
//  NetPulse00
//
//  Created by Сергей Мещеряков on 29.12.2025.
//

import Foundation

struct User: Codable, Identifiable {
    var status: UserStatus
    let id: UUID
    let name: String
    let email: String
    var friendsList: [UUID]
    
    // Параметры по умолчанию должны идти ПОСЛЕ обязательных параметров
    init(id: UUID = UUID(), name: String, email: String, status: UserStatus = .online, friendsList: [UUID] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.status = status
        self.friendsList = friendsList
    }
    
    mutating func updateStatus(_ newStatus: UserStatus) {
        self.status = newStatus
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
    }
    
    mutating func addFriend(_ friendId: UUID) {
        guard !friendsList.contains(friendId) else { return }
        friendsList.append(friendId)
    }
}

