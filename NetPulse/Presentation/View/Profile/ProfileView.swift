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
                // Плашка профиля во всю ширину
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.name)
                            .font(.title2.bold())
                        Text(user.displayStatus)
                            .font(.subheadline)
                            .foregroundColor(statusColor(for: user))
                    }
                    Spacer()
                    avatarView(for: user)
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
                        .appTextField()

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

                        VStack(spacing: 0) {
                            ForEach(Array(favorites.enumerated()), id: \.element.id) { index, friend in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(friend.name)
                                        Text(friend.displayStatus)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 6)

                                if index != favorites.count - 1 {
                                    Divider()
                                        .padding(.leading, 4)
                                }
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

    private func statusColor(for user: User) -> Color {
        let hasCustom = (user.customStatus ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        if hasCustom { return .pink }
        switch user.status {
        case .online: return .green
        case .offline: return .gray
        case .working: return .orange
        case .studying: return .blue
        }
    }

    private func avatarView(for user: User) -> some View {
        let components = user.name
            .split(separator: " ")
            .prefix(2)
        let initials = components
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()

        return ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primary.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(initials.isEmpty ? "N" : initials)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(width: 44, height: 44)
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}
