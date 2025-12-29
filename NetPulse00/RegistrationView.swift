//
//  RegistrationView.swift
//  NetPulse00
//
//  Created by Сергей Мещеряков on 29.12.2025.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var newUserName: String = ""
    @State private var newUserEmail: String = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Регистрация")
                .font(.largeTitle)
                .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Имя:")
                    .font(.headline)
                TextField("Введите ваше имя", text: $newUserName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Email:")
                    .font(.headline)
                TextField("Введите вашу почту", text: $newUserEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding(.horizontal)
            
            Spacer()
            
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
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
        .alert("Ошибка", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var isFormValid: Bool {
        return !newUserName.trimmingCharacters(in: .whitespaces).isEmpty &&
               !newUserEmail.trimmingCharacters(in: .whitespaces).isEmpty &&
               newUserEmail.contains("@")
    }
    
    private func registerUser() {
        // Валидация email
        guard isValidEmail(newUserEmail) else {
            errorMessage = "Введите корректный email адрес"
            showingError = true
            return
        }
        
        // Создаем нового пользователя
        let newUser = User(
            name: newUserName.trimmingCharacters(in: .whitespaces),
            email: newUserEmail.trimmingCharacters(in: .whitespaces)
        )
        
        // Добавляем через UserManager
        if userManager.addUser(newUser) {
            // Успешная регистрация - переход произойдет автоматически
        } else {
            errorMessage = "Пользователь с таким email уже существует"
            showingError = true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

#Preview {
    RegistrationView()
        .environmentObject(UserManager())
}
