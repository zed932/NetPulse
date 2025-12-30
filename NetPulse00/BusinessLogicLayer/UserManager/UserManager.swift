import Foundation
import SwiftUI
import Combine


// Все через текущего пользователя

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var allUsers: [User] = [] // Изначально нет юзеров

    
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
    
    private func saveUsers() {
        if let encoded = try? JSONEncoder().encode(allUsers) {
            UserDefaults.standard.set(encoded, forKey: "savedUsers")
        }
    }
    
    // Загрузка из UserDefaults
    private func loadUsers() {
        if let savedUsers = UserDefaults.standard.data(forKey: "savedUsers"),
           let decoded = try? JSONDecoder().decode([User].self, from: savedUsers) {
            allUsers = decoded
        }
    }
    
    // Инициализатор
    init() {
        
        loadUsers() // Загружаем пользователей
        
        
        let testUsers = [ // Добавляем тестовых мок-юзеров
            User(name: "Анна", email: "anna@test.com"),
            User(name: "Иван", email: "ivan@test.com", status: .offline),
            User(name: "Мария", email: "maria@test.com", status: .studying),
            User(name: "Алексей", email: "alex@test.com", status: .working)
        ]
        
        allUsers = testUsers // В массив всех юзеров
        saveUsers()
    }
}
