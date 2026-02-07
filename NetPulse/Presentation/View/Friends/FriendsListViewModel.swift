//
//  FriendsListViewModel.swift
//  NetPulse
//

import Foundation
import Combine

/// ViewModel списка друзей (MVVM).
final class FriendsListViewModel: ObservableObject {
    @Published var searchQuery = ""
    /// Поиск с задержкой, чтобы не фильтровать список на каждый символ.
    @Published var debouncedSearchQuery = ""

    init() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .assign(to: &$debouncedSearchQuery)
    }

    /// Друзья текущего пользователя с учётом поиска (по debouncedSearchQuery).
    func friends(userManager: UserManager) -> [User] {
        let list = userManager.friends()
        let q = debouncedSearchQuery.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return list }
        return list.filter {
            $0.name.localizedCaseInsensitiveContains(q) || $0.email.localizedCaseInsensitiveContains(q)
        }
    }
}
