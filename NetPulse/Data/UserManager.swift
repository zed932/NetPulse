//
//  UserManager.swift
//  NetPulse
//

import Foundation
import SwiftUI

/// Менеджер пользователей.
/// Сейчас данные хранятся локально (UserDefaults);
/// далее по ТЗ планируется перенести хранение в Firebase.
final class UserManager: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published private(set) var allUsers: [User] = []

    func login(email: String) -> Bool {
        if let user = allUsers.first(where: { $0.email == email }) {
            currentUser = user
            return true
        }
        return false
    }

    func logout() {
        currentUser = nil
    }

    func updateCurrentUserStatus(_ newStatus: UserStatus) {
        guard let index = allUsers.firstIndex(where: { $0.id == currentUser?.id }) else { return }
        allUsers[index].status = newStatus
        currentUser?.status = newStatus
    }

    func registerNewUser(name: String, email: String) -> Bool {
        guard !allUsers.contains(where: { $0.email == email}) else {
            return false
        }
        let newUser = User(name: name, email: email)
        allUsers.append(newUser)

        saveUsers()

        currentUser = newUser
        return true
    }

    /// Добавить пользователя в друзья текущему пользователю.
    func addFriend(_ user: User) -> Bool {
        guard var current = currentUser else { return false }
        guard current.id != user.id else { return false }
        guard !current.friendsList.contains(user.id) else { return false }
        guard let idx = allUsers.firstIndex(where: { $0.id == current.id }) else { return false }
        current.addFriend(user.id)
        allUsers[idx] = current
        currentUser = current
        saveUsers()
        return true
    }

    /// Список друзей текущего пользователя (по ТЗ: просмотр друзей и их статусов).
    func friends() -> [User] {
        guard let current = currentUser else { return [] }
        return allUsers.filter { current.friendsList.contains($0.id) }
    }

    /// Пользователи, которых ещё нет в друзьях у текущего.
    func usersNotInFriendsList() -> [User] {
        guard let current = currentUser else { return [] }
        return allUsers.filter { user in
            user.id != current.id && !current.friendsList.contains(user.id)
        }
    }

    private func saveUsers() {
        if let encoded = try? JSONEncoder().encode(allUsers) {
            UserDefaults.standard.set(encoded, forKey: "savedUsers")
        }
    }

    private func loadUsers() {
        if let savedUsers = UserDefaults.standard.data(forKey: "savedUsers"),
           let decoded = try? JSONDecoder().decode([User].self, from: savedUsers) {
            allUsers = decoded
        }
    }

    init() {
        loadUsers()

        let testUsers = [
            User(name: "Анна", email: "anna@test.com"),
            User(name: "Иван", email: "ivan@test.com", status: .offline),
            User(name: "Мария", email: "maria@test.com", status: .studying),
            User(name: "Алексей", email: "alex@test.com", status: .working)
        ]

        allUsers = testUsers
        saveUsers()
    }
}
