//
//  RegistrationView.swift
//  NetPulse
//

import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("NetPulse")
                    .font(.largeTitle.bold())
                    .padding(.top, 40)

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Имя")
                            .font(.headline)
                        TextField("Введите ваше имя", text: $viewModel.name)
                            .appTextField()
                            .autocapitalization(.words)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                        TextField("Введите email", text: $viewModel.email)
                            .appTextField()
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                }
                .appCard()

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        viewModel.register(userManager: userManager)
                    } label: {
                        Text("Зарегистрироваться")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!viewModel.isFormValid)
                    .opacity(viewModel.isFormValid ? 1 : 0.5)

                    Button {
                        viewModel.loginExisting(userManager: userManager)
                    } label: {
                        Text("Войти в существующий аккаунт")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(!viewModel.canLoginWithEmail)

                    Button {
                        viewModel.loginTestUser(userManager: userManager)
                    } label: {
                        Text("Войти как тестовый пользователь")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal)
            .background(AppTheme.background.ignoresSafeArea())
            .alert("Ошибка", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}
