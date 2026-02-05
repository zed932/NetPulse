//
//  RegistrationView.swift
//  NetPulse
//

import SwiftUI

struct RegistrationView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var isRegistering = false
    @State private var showError = false
    @State private var errorMessage = ""

    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack(spacing: 20) {
            Text("NetPulse")
                .font(.largeTitle)
                .padding(.top, 40)

            VStack(alignment: .leading, spacing: 8) {
                Text("Имя:")
                    .font(.headline)
                TextField("Введите ваше имя", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Email:")
                    .font(.headline)
                TextField("Введите email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 15) {
                Button(action: {
                    registerUser()
                }) {
                    Text("Зарегистрироваться")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid)

                Button("Войти как тестовый пользователь") {
                    if userManager.login(email: "anna@test.com") {
                        // Успешный вход
                    }
                }
                .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
        .alert("Ошибка", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@")
    }

    private func registerUser() {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "Введите корректный email"
            showError = true
            return
        }

        if userManager.registerNewUser(name: name.trimmingCharacters(in: .whitespaces),
                                      email: email.trimmingCharacters(in: .whitespaces)) {
            // Успешная регистрация и вход
        } else {
            errorMessage = "Пользователь с таким email уже существует"
            showError = true
        }
    }
}
