//
//  SessionManager.swift
//  NetPulse
//

import Foundation
import SwiftUI
import Combine

/// Менеджер сессий и приглашений (по ТЗ: отправка/приём/принятие/отклонение, синхронизированный таймер).
/// Пока хранение in-memory; далее — синхронизация по WebSocket.
final class SessionManager: ObservableObject {
    @Published private(set) var invitations: [Invitation] = []
    @Published private(set) var activeSession: Session?
    @Published private(set) var sessionRemainingSeconds: Int = 0
    @Published private(set) var completedSessions: [Session] = []

    private var timer: Timer?
    private var timerCancellable: AnyCancellable?

    /// Отправить приглашение на сессию. По ТЗ — только пользователю со статусом «Онлайн».
    func sendInvitation(from currentUser: User, to friend: User, sessionType: SessionType) -> Bool {
        guard friend.status == .online else { return false }
        guard currentUser.friendsList.contains(friend.id) else { return false }
        let inv = Invitation(
            fromUserId: currentUser.id,
            toUserId: friend.id,
            sessionType: sessionType
        )
        invitations.append(inv)
        return true
    }

    /// Входящие приглашения для пользователя (со статусом pending).
    func incomingInvitations(for user: User) -> [Invitation] {
        invitations.filter { $0.toUserId == user.id && $0.status == .pending }
    }

    /// Принять приглашение.
    func accept(_ invitation: Invitation) {
        guard let idx = invitations.firstIndex(where: { $0.id == invitation.id }) else { return }
        invitations[idx].status = .accepted
    }

    /// Отклонить приглашение.
    func decline(_ invitation: Invitation) {
        guard let idx = invitations.firstIndex(where: { $0.id == invitation.id }) else { return }
        invitations[idx].status = .declined
    }

    /// Запустить сессию по приглашению (по ТЗ: синхронизированный таймер).
    /// Принимает приглашение, если ещё не принято, создаёт сессию и запускает таймер.
    func startSession(acceptedInvitation invitation: Invitation, durationMinutes: Int) -> Bool {
        guard activeSession == nil else { return false }
        accept(invitation)
        let durationSeconds = durationMinutes * 60
        let session = Session(
            invitationId: invitation.id,
            sessionType: invitation.sessionType,
            participantIds: [invitation.fromUserId, invitation.toUserId],
            startedAt: Date(),
            durationSeconds: durationSeconds
        )
        activeSession = session
        sessionRemainingSeconds = durationSeconds
        startTimer()
        return true
    }

    /// Завершить активную сессию (вручную или по окончании таймера).
    func endSession() {
        stopTimer()
        if var session = activeSession {
            session.isActive = false
            session.completedAt = Date()
            completedSessions.append(session)
        }
        activeSession = nil
        sessionRemainingSeconds = 0
    }

    /// Найти отправителя приглашения по списку пользователей.
    func sender(of invitation: Invitation, in users: [User]) -> User? {
        users.first { $0.id == invitation.fromUserId }
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard let session = activeSession else { return }
        let remaining = session.remainingSeconds(now: Date())
        DispatchQueue.main.async { [weak self] in
            self?.sessionRemainingSeconds = remaining
            if remaining == 0 {
                self?.endSession()
            }
        }
    }
}
