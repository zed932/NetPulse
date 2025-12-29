//
//  UserManager.swift
//  NetPulse00
//
//  Created by Сергей Мещеряков on 29.12.2025.
//

import Foundation
import Combine

class UserManager: ObservableObject {
    @Published var currentUser: User?
    
    private let currentUserKey = "currentUser"
    private let usersKey = "users"
    
    init() {
        loadCurrentUser()
    }
    
    // MARK: - Current User Management
    
    func loadCurrentUser() {
        if let data = UserDefaults.standard.data(forKey: currentUserKey) {
            if let user = try? JSONDecoder().decode(User.self, from: data) {
                currentUser = user
            }
        }
    }
    
    func saveCurrentUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: currentUserKey)
            currentUser = user
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: currentUserKey)
        currentUser = nil
    }
    
    // MARK: - All Users Management
    
    func addUser(_ user: User) -> Bool {
        // Проверяем уникальность email
        if userWithEmailExist(email: user.email) {
            return false
        }
        
        // Сохраняем пользователя в список всех пользователей
        var allUsers = getAllUsers()
        allUsers.append(user)
        saveAllUsers(allUsers)
        
        // Делаем его текущим
        saveCurrentUser(user)
        
        return true
    }
    
    func getAllUsers() -> [User] {
        if let data = UserDefaults.standard.data(forKey: usersKey) {
            if let users = try? JSONDecoder().decode([User].self, from: data) {
                return users
            }
        }
        return []
    }
    
    private func saveAllUsers(_ users: [User]) {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: usersKey)
        }
    }
    
    func userWithEmailExist(email: String) -> Bool {
        let allUsers = getAllUsers()
        return allUsers.contains { $0.email == email }
    }
    
    // MARK: - Update User
    
    func updateUserStatus(_ status: UserStatus) {
        guard var user = currentUser else { return }
        user.updateStatus(status)
        saveCurrentUser(user)
        
        // Также обновляем в общем списке
        var allUsers = getAllUsers()
        if let index = allUsers.firstIndex(where: { $0.id == user.id }) {
            allUsers[index].updateStatus(status)
            saveAllUsers(allUsers)
        }
    }
}
