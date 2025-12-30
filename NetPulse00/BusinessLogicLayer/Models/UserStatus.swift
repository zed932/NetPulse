//
//  UserStatus.swift
//  NetPulse00
//
//  Created by Сергей Мещеряков on 30.12.2025.
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
