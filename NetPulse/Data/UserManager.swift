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

    private let firebaseService = FirebaseUserService()

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
        guard let id = currentUser?.id,
              let index = allUsers.firstIndex(where: { $0.id == id }) else { return }

        allUsers[index].status = newStatus
        allUsers[index].customStatus = nil

        var updated = allUsers[index]
        updated.customStatus = nil
        currentUser = updated
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

    /// Обновить кастомный статус текущего пользователя.
    func updateCurrentUserCustomStatus(_ newStatus: String?) {
        guard let id = currentUser?.id,
              let index = allUsers.firstIndex(where: { $0.id == id }) else { return }

        let trimmed = newStatus?.trimmingCharacters(in: .whitespacesAndNewlines)
        allUsers[index].customStatus = trimmed?.isEmpty == true ? nil : trimmed
        currentUser = allUsers[index]
        saveUsers()
    }

    /// Найти пользователя по никнейму или email.
    func findUser(byUsernameOrEmail query: String) -> User? {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return nil }
        return allUsers.first {
            $0.username.lowercased() == q || $0.email.lowercased() == q
        }
    }

    /// Обновить список пользователей из Firebase.
    /// Используется кнопкой «Обновить» на экранах Статус/Друзья.
    @MainActor
    func refreshFromFirebase() {
        Task {
            let remoteUsers = try? await firebaseService.fetchUsers()
            guard let users = remoteUsers, !users.isEmpty else { return }

            await MainActor.run {
                self.allUsers = users
                if let currentId = self.currentUser?.id {
                    self.currentUser = users.first(where: { $0.id == currentId })
                }
                self.saveUsers()
            }
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
            User(name: "Анна", email: "anna@test.com", username: "anna"),
            User(name: "Иван", email: "ivan@test.com", username: "ivan", status: .offline),
            User(name: "Мария", email: "maria@test.com", username: "maria", status: .studying),
            User(name: "Алексей", email: "alex@test.com", username: "alex", status: .working)
        ]

        allUsers = testUsers
        saveUsers()
    }
}
