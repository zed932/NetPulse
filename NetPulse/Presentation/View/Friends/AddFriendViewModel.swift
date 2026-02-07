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

    /// Пользователи, найденные по поиску (ник/email/имя). Пустой запрос — пустой список (не показываем всех пользователей).
    func addableUsers(userManager: UserManager) -> [User] {
        let q = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }
        let list = userManager.usersNotInFriendsList()
        return list.filter {
            $0.name.localizedCaseInsensitiveContains(q)
            || $0.email.localizedCaseInsensitiveContains(q)
            || $0.username.localizedCaseInsensitiveContains(q)
        }
    }

    /// Отправить заявку в друзья (вместо мгновенного добавления).
    func sendFriendRequest(to user: User, userManager: UserManager) -> Bool {
        userManager.sendFriendRequest(to: user)
    }

    /// Уже отправлена заявка этому пользователю?
    func hasPendingRequest(to user: User?, userManager: UserManager) -> Bool {
        guard let user else { return false }
        return userManager.hasPendingSentRequest(to: user.id)
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
