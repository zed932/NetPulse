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
                VStack(alignment: .leading, spacing: 12) {
                    Text(user.name)
                        .font(.title2.bold())

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Текущий статус")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(user.status.description)
                            .font(.headline)
                            .foregroundColor(statusColor(for: user.status))
                    }
                }
                .appCard()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Изменить статус")
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
                    }

                    Button {
                        viewModel.saveStatus(viewModel.selectedStatus, userManager: userManager)
                    } label: {
                        Text("Сохранить статус")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 4)
                }
                .appCard()

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
        .navigationTitle("Профиль")
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
