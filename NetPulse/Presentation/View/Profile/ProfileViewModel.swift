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

    func syncSelectedStatus(from user: User?) {
        if let status = user?.status {
            selectedStatus = status
        }
    }

    func saveStatus(_ status: UserStatus, userManager: UserManager) {
        userManager.updateCurrentUserStatus(status)
    }

    func logout(userManager: UserManager) {
        userManager.logout()
    }
}
