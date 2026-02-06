//
//  RegistrationViewModel.swift
//  NetPulse
//

import Foundation
import Combine

/// ViewModel экрана регистрации/входа (MVVM).
final class RegistrationViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var showError = false
    @Published var errorMessage = ""

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@")
    }

    private static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    func register(userManager: UserManager) {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", Self.emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "Введите корректный email"
            showError = true
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        if userManager.registerNewUser(name: trimmedName, email: trimmedEmail) {
            // Успешная регистрация — переход произойдёт по изменению currentUser
        } else {
            errorMessage = "Пользователь с таким email уже существует"
            showError = true
        }
    }

    func loginTestUser(userManager: UserManager) {
        _ = userManager.login(email: "anna@test.com")
    }
}
