//
//  ProfileView.swift
//  NetPulse
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        VStack(spacing: 16) {
            if let user = userManager.currentUser {
                // Текущий статус
                VStack(alignment: .leading, spacing: 12) {
                    Text(user.name)
                        .font(.title2.bold())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Текущий статус")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(user.displayStatus)
                            .font(.headline)
                            .foregroundColor(statusColor(for: user.status))
                    }
                }
                .appCard()

                // Выбор статуса (пресеты + кастомный) с одной кнопкой применения
                VStack(alignment: .leading, spacing: 12) {
                    Text("Статус")
                        .font(.headline)

                    Picker("Статус", selection: $viewModel.selectedStatus) {
                        ForEach(UserStatus.allCases, id: \.self) { status in
                            Text(status.description)
                                .tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onAppear {
                        viewModel.syncSelectedStatus(from: user)
                        viewModel.customStatusText = user.customStatus ?? ""
                    }

                    TextField("Или напишите свой статус…", text: $viewModel.customStatusText)
                        .textFieldStyle(.roundedBorder)

                    Text("Если поле выше не пустое, будет использован ваш текстовый статус.")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Button {
                        viewModel.applyStatus(userManager: userManager)
                    } label: {
                        Text("Применить статус")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 4)
                }
                .appCard()

                // Избранные друзья (первые несколько)
                let favorites = Array(userManager.friends().prefix(3))
                if !favorites.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Избранные друзья")
                            .font(.headline)

                        ForEach(favorites) { friend in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(friend.name)
                                    Text(friend.displayStatus)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                    .appCard()
                }

                Spacer()

                Button(role: .destructive) {
                    viewModel.logout(userManager: userManager)
                } label: {
                    Text("Выйти из аккаунта")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.bottom, 20)
            }
        }
        .padding()
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Статус")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statusColor(for status: UserStatus) -> Color {
        switch status {
        case .online: return .green
        case .offline: return .gray
        case .working: return .orange
        case .studying: return .blue
        }
    }
}
