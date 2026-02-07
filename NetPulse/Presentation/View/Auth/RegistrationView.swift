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
            VStack(spacing: 0) {
                Text("NetPulse")
                    .font(.largeTitle.bold())
                    .padding(.top, 48)
                    .padding(.bottom, 32)

                Picker("Режим", selection: $viewModel.isSignUp) {
                    Text("Вход").tag(false)
                    Text("Регистрация").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 24)

                if viewModel.isSignUp {
                    signUpForm
                } else {
                    signInForm
                }

                Spacer()
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

    private var signInForm: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                TextField("Введите email", text: $viewModel.email)
                    .appTextField()
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .appCard()

            Button {
                viewModel.signIn(userManager: userManager)
            } label: {
                Text("Войти")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.canLoginWithEmail)
            .opacity(viewModel.canLoginWithEmail ? 1 : 0.5)
        }
        .padding(.horizontal)
    }

    private var signUpForm: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
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

            Button {
                viewModel.register(userManager: userManager)
            } label: {
                Text("Зарегистрироваться")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isFormValid)
            .opacity(viewModel.isFormValid ? 1 : 0.5)
        }
        .padding(.horizontal)
    }
}
