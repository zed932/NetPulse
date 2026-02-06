//
//  UserManager.swift
//  NetPulse
//

import Foundation
import SwiftUI
import Combine

/// Менеджер пользователей.
/// Сейчас данные хранятся локально (UserDefaults);
/// далее по ТЗ планируется перенести хранение в Firebase.
final class UserManager: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published private(set) var allUsers: [User] = []
    /// Входящие заявки в друзья (ожидают решения).
    @Published private(set) var incomingFriendRequests: [FriendRequest] = []
    /// Исходящие заявки (отправленные мной, статус pending).
    @Published private(set) var sentFriendRequests: [FriendRequest] = []

    private let firebaseService = FirebaseUserService()

    func login(email: String) -> Bool {
        let lower = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard !lower.isEmpty else { return false }
        if let user = allUsers.first(where: { $0.email.lowercased() == lower }) {
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
        saveUsers()

        Task {
            await firebaseService.updateUserStatus(updated)
        }
    }

    func registerNewUser(name: String, email: String) -> Bool {
        guard !allUsers.contains(where: { $0.email == email}) else {
            return false
        }
        let newUser = User(name: name, email: email)
        allUsers.append(newUser)

        saveUsers()

        currentUser = newUser

        Task {
            await firebaseService.updateUserStatus(newUser)
        }
        return true
    }

    /// Добавить пользователя в друзья текущему (без заявки; используется при принятии заявки).
    private func addFriendImmediate(_ user: User) -> Bool {
        guard var current = currentUser else { return false }
        guard current.id != user.id else { return false }
        guard !current.friendsList.contains(user.id) else { return false }
        guard let idx = allUsers.firstIndex(where: { $0.id == current.id }) else { return false }
        current.addFriend(user.id)
        allUsers[idx] = current
        currentUser = current
        if let otherIdx = allUsers.firstIndex(where: { $0.id == user.id }) {
            var other = allUsers[otherIdx]
            other.addFriend(current.id)
            allUsers[otherIdx] = other
        }
        saveUsers()
        return true
    }

    /// Отправить заявку в друзья. Не создаёт дубликат, если уже есть pending от меня к этому пользователю.
    func sendFriendRequest(to user: User) -> Bool {
        guard let current = currentUser else { return false }
        guard current.id != user.id else { return false }
        guard !current.friendsList.contains(user.id) else { return false }
        if sentFriendRequests.contains(where: { $0.toUserId == user.id && $0.status == .pending }) {
            return false // уже отправил заявку
        }
        let request = FriendRequest(fromUserId: current.id, toUserId: user.id)
        sentFriendRequests.append(request)
        Task {
            await firebaseService.createFriendRequest(request)
            await refreshFriendRequestsAsync()
        }
        return true
    }

    /// Есть ли уже исходящая заявка к этому пользователю (pending).
    func hasPendingSentRequest(to userId: UUID) -> Bool {
        sentFriendRequests.contains { $0.toUserId == userId && $0.status == .pending }
    }

    /// Принять заявку в друзья: добавить друг друга в friendsList, обновить заявку и синхронизировать с Firebase.
    func acceptFriendRequest(_ request: FriendRequest) {
        guard request.toUserId == currentUser?.id, request.status == .pending else { return }
        guard let fromUser = allUsers.first(where: { $0.id == request.fromUserId }) else { return }
        guard let current = currentUser else { return }

        // Локально добавляем друг друга в друзья
        guard let myIdx = allUsers.firstIndex(where: { $0.id == current.id }),
              let otherIdx = allUsers.firstIndex(where: { $0.id == fromUser.id }) else { return }
        var me = allUsers[myIdx]
        var other = allUsers[otherIdx]
        me.addFriend(fromUser.id)
        other.addFriend(current.id)
        allUsers[myIdx] = me
        allUsers[otherIdx] = other
        currentUser = me
        saveUsers()

        Task { @MainActor in
            await firebaseService.updateFriendRequestStatus(id: request.id, status: .accepted)
            await firebaseService.updateUser(me)
            await firebaseService.updateUser(other)
            await refreshFriendRequestsAsync()
        }
        incomingFriendRequests.removeAll { $0.id == request.id }
    }

    /// Отклонить заявку в друзья.
    func declineFriendRequest(_ request: FriendRequest) {
        guard request.toUserId == currentUser?.id, request.status == .pending else { return }
        incomingFriendRequests.removeAll { $0.id == request.id }
        Task {
            await firebaseService.updateFriendRequestStatus(id: request.id, status: .declined)
            await refreshFriendRequestsAsync()
        }
    }

    /// Обновить списки заявок из Firebase.
    @MainActor
    func refreshFriendRequests() {
        Task { await refreshFriendRequestsAsync() }
    }

    @MainActor
    func refreshFriendRequestsAsync() async {
        let requests = (try? await firebaseService.fetchFriendRequests()) ?? []
        guard let currentId = currentUser?.id else {
            incomingFriendRequests = []
            sentFriendRequests = []
            return
        }
        incomingFriendRequests = requests.filter { $0.toUserId == currentId && $0.status == .pending }
        sentFriendRequests = requests.filter { $0.fromUserId == currentId }
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
        let updated = allUsers[index]
        currentUser = updated
        saveUsers()

        Task {
            await firebaseService.updateUserStatus(updated)
        }
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
            await refreshFromFirebaseAsync()
        }
    }

    /// Синхронное ожидание обновления из Firebase (для входа: сначала подтянуть пользователей, потом искать по email).
    @MainActor
    func refreshFromFirebaseAsync() async {
        // Сохраняем локальные данные (в том числе friendsList), чтобы не потерять их при обновлении.
        let localUsers = allUsers

        let remoteUsers = try? await firebaseService.fetchUsers()
        guard var users = remoteUsers, !users.isEmpty else { return }

        // Объединяем списки друзей: локальный + из Firebase (заявки при принятии пишутся в Firebase).
        for index in users.indices {
            let remoteIds = Set(users[index].friendsList)
            let localIds = localUsers.first(where: { $0.id == users[index].id }).map { Set($0.friendsList) } ?? []
            let merged = remoteIds.union(localIds ?? [])
            users[index].friendsList = Array(merged)
        }

        allUsers = users

        if let currentId = currentUser?.id {
            currentUser = users.first(where: { $0.id == currentId }) ?? currentUser
        }

        saveUsers()

        Task { await refreshFriendRequestsAsync() }
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
        if allUsers.isEmpty {
            let testUsers = [
                User(name: "Анна", email: "anna@test.com", username: "anna"),
                User(name: "Иван", email: "ivan@test.com", username: "ivan", status: .offline),
                User(name: "Мария", email: "maria@test.com", username: "maria", status: .studying),
                User(name: "Алексей", email: "alex@test.com", username: "alex", status: .working)
            ]
            allUsers = testUsers
            saveUsers()
        }
        // Подтянуть реальные данные из Firebase в фоне.
        refreshFromFirebase()
    }
}
