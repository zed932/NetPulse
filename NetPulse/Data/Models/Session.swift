//
//  Session.swift
//  NetPulse
//

import Foundation

/// Активная или завершённая совместная сессия (по ТЗ: синхронизированный таймер).
struct Session: Identifiable, Codable {
    let id: UUID
    let invitationId: UUID
    let sessionType: SessionType
    let participantIds: [UUID]
    let startedAt: Date
    let durationSeconds: Int
    var isActive: Bool
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        invitationId: UUID,
        sessionType: SessionType,
        participantIds: [UUID],
        startedAt: Date = Date(),
        durationSeconds: Int,
        isActive: Bool = true,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.invitationId = invitationId
        self.sessionType = sessionType
        self.participantIds = participantIds
        self.startedAt = startedAt
        self.durationSeconds = durationSeconds
        self.isActive = isActive
        self.completedAt = completedAt
    }

    var endTime: Date {
        startedAt.addingTimeInterval(TimeInterval(durationSeconds))
    }

    /// Оставшиеся секунды (0 если время вышло или сессия не активна).
    func remainingSeconds(now: Date = Date()) -> Int {
        guard isActive else { return 0 }
        return max(0, Int(endTime.timeIntervalSince(now)))
    }
}
