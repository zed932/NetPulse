//
//  RegistrationViewModel.swift
//  NetPulse
//

import Foundation
import Combine

/// ViewModel экрана входа и регистрации (MVVM).
final class RegistrationViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isSignUp = false
    @Published var showError = false
    @Published var errorMessage = ""

    private static let minPasswordLength = 6

    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        password.count >= Self.minPasswordLength &&
        password == confirmPassword
    }

    var canSignIn: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        return !trimmedEmail.isEmpty && trimmedEmail.contains("@") && !password.isEmpty
    }

    private static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    func signIn(userManager: UserManager) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", Self.emailRegex)
        guard emailPredicate.evaluate(with: trimmedEmail) else {
            errorMessage = "Введите корректный email"
            showError = true
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Введите пароль"
            showError = true
            return
        }

        if userManager.login(email: trimmedEmail, password: password) {
            Task { @MainActor in
                await userManager.refreshFromFirebaseAsync()
                await userManager.refreshFriendRequestsAsync()
            }
        } else {
            errorMessage = "Неверный email или пароль"
            showError = true
        }
    }

    func register(userManager: UserManager) {
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", Self.emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "Введите корректный email"
            showError = true
            return
        }
        guard password.count >= Self.minPasswordLength else {
            errorMessage = "Пароль должен быть не короче \(Self.minPasswordLength) символов"
            showError = true
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Пароли не совпадают"
            showError = true
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        if userManager.registerNewUser(name: trimmedName, email: trimmedEmail, password: password) {
            // Успешная регистрация — переход произойдёт по изменению currentUser
        } else {
            errorMessage = "Пользователь с таким email уже существует"
            showError = true
        }
    }
}
