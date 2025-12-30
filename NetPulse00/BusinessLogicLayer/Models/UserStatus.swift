//
//  UserStatus.swift
//  NetPulse00
//
//  Created by Сергей Мещеряков on 30.12.2025.
//

import Foundation

enum UserStatus: String, Codable {
    case online = "Онлайн"
    case offline = "Оффлайн"
    case working = "Работает"
    case studying = "Учится"
    
    var description: String {
        return self.rawValue
    }
}
