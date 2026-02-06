//
//  AddFriendViewModel.swift
//  NetPulse
//

import Foundation
import Combine

/// ViewModel экрана «Добавить друга» (MVVM).
final class AddFriendViewModel: ObservableObject {
    @Published var searchQuery = ""

    /// Пользователи, не в друзьях, с учётом поиска.
    func addableUsers(userManager: UserManager) -> [User] {
        let list = userManager.usersNotInFriendsList()
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return list }
        let q = searchQuery.trimmingCharacters(in: .whitespaces)
        return list.filter {
            $0.name.localizedCaseInsensitiveContains(q) || $0.email.localizedCaseInsensitiveContains(q)
        }
    }

    func addFriend(_ user: User, userManager: UserManager) -> Bool {
        userManager.addFriend(user)
    }
}
