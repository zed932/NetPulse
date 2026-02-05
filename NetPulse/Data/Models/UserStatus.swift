//
//  UserStatus.swift
//  NetPulse
//

import Foundation

enum UserStatus: String, Codable, CaseIterable {
    case online = "Онлайн"
    case offline = "Оффлайн"
    case working = "Работаю"
    case studying = "Учусь"
    
    var description: String {
        return self.rawValue
    }
}
