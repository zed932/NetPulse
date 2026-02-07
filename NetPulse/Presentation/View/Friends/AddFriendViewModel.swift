//
//  AddFriendViewModel.swift
//  NetPulse
//

import Foundation
import Combine

/// ViewModel экрана «Добавить друга» (MVVM).
final class AddFriendViewModel: ObservableObject {
    @Published var searchQuery = ""
    /// Поиск с задержкой 0.3 с, чтобы не фильтровать список на каждый символ.
    @Published var debouncedSearchQuery = ""
    @Published var usernameQuery = ""
    @Published var foundByUsername: User?

    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .assign(to: &$debouncedSearchQuery)
    }

    /// Пользователи, найденные по поиску (ник/email/имя). Используется debouncedSearchQuery.
    func addableUsers(userManager: UserManager, query: String) -> [User] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }
        let list = userManager.usersNotInFriendsList()
        return list.filter {
            $0.name.localizedCaseInsensitiveContains(q)
            || $0.email.localizedCaseInsensitiveContains(q)
            || $0.username.localizedCaseInsensitiveContains(q)
        }
    }

    func sendFriendRequest(to user: User, userManager: UserManager) -> Bool {
        userManager.sendFriendRequest(to: user)
    }

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
