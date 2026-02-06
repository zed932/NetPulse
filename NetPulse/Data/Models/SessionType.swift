//
//  SessionType.swift
//  NetPulse
//

import Foundation

/// Тип совместной сессии (по ТЗ: работа, учёба, медитация).
enum SessionType: String, Codable, CaseIterable {
    case work = "Работа"
    case study = "Учёба"
    case meditation = "Медитация"

    var description: String { rawValue }
}
