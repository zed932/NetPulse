//
//  ProfileViewModel.swift
//  NetPulse
//

import Foundation
import SwiftUI
import Combine

/// ViewModel экрана профиля (MVVM).
final class ProfileViewModel: ObservableObject {
    @Published var selectedStatus: UserStatus = .online
    @Published var customStatusText: String = ""

    func syncSelectedStatus(from user: User?) {
        if let status = user?.status {
            selectedStatus = status
        }
    }

    /// Применить выбранный статус.
    /// Если задан кастомный текст — сохраняем его,
    /// иначе применяем выбранный предопределённый статус.
    func applyStatus(userManager: UserManager) {
        let trimmed = customStatusText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            userManager.updateCurrentUserCustomStatus(trimmed)
        } else {
            userManager.updateCurrentUserStatus(selectedStatus)
        }
    }

    func logout(userManager: UserManager) {
        userManager.logout()
    }
}
