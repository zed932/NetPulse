//
//  AddFriendViewModel.swift
//  NetPulse
//

import Foundation
import Combine

/// ViewModel экрана «Добавить друга» (MVVM).
final class AddFriendViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var usernameQuery = ""
    @Published var foundByUsername: User?

    /// Пользователи, не в друзьях, с учётом поиска.
    func addableUsers(userManager: UserManager) -> [User] {
        let list = userManager.usersNotInFriendsList()
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return list }
        let q = searchQuery.trimmingCharacters(in: .whitespaces)
        return list.filter {
            $0.name.localizedCaseInsensitiveContains(q)
            || $0.email.localizedCaseInsensitiveContains(q)
            || $0.username.localizedCaseInsensitiveContains(q)
        }
    }

    func addFriend(_ user: User, userManager: UserManager) -> Bool {
        userManager.addFriend(user)
    }

    func searchByUsernameOrToken(userManager: UserManager) {
        let raw = usernameQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else {
            foundByUsername = nil
            return
        }

        let username: String
        let prefix = "netpulse:user:"
        if raw.lowercased().hasPrefix(prefix) {
            username = String(raw.dropFirst(prefix.count))
        } else {
            username = raw
        }

        foundByUsername = userManager.findUser(byUsernameOrEmail: username)
    }
}
