//
//  User.swift
//  NetPulse00
//
//  Created by Сергей Мещеряков on 29.12.2025.
//

import Foundation

enum UserStatus: Codable {
    case online
    case offline
    case working
    case studying
}

struct User: Codable {
    var status: UserStatus
    let id: UUID
    let name: String
    let email: String
    
    // Параметры по умолчанию должны идти ПОСЛЕ обязательных параметров
    init(id: UUID = UUID(), name: String, email: String, status: UserStatus = .online) {
        self.id = id
        self.name = name
        self.email = email
        self.status = status
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
}

