//
//  RegistrationView.swift
//  NetPulse
//

import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack(spacing: 20) {
            Text("NetPulse")
                .font(.largeTitle)
                .padding(.top, 40)

            VStack(alignment: .leading, spacing: 8) {
                Text("Имя:")
                    .font(.headline)
                TextField("Введите ваше имя", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Email:")
                    .font(.headline)
                TextField("Введите email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 15) {
                Button(action: {
                    viewModel.register(userManager: userManager)
                }) {
                    Text("Зарегистрироваться")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isFormValid)

                Button("Войти как тестовый пользователь") {
                    viewModel.loginTestUser(userManager: userManager)
                }
                .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
        .alert("Ошибка", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}
