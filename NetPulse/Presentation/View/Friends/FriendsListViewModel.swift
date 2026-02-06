//
//  FriendsListViewModel.swift
//  NetPulse
//

import Foundation
import Combine

/// ViewModel списка друзей (MVVM).
final class FriendsListViewModel: ObservableObject {
    @Published var searchQuery = ""

    /// Друзья текущего пользователя, с учётом поиска.
    func friends(userManager: UserManager) -> [User] {
        let list = userManager.friends()
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return list }
        let q = searchQuery.trimmingCharacters(in: .whitespaces)
        return list.filter {
            $0.name.localizedCaseInsensitiveContains(q) || $0.email.localizedCaseInsensitiveContains(q)
        }
    }
}
