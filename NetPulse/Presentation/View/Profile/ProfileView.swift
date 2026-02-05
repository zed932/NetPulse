//
//  ProfileView.swift
//  NetPulse
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var selectedStatus: UserStatus = .online

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = userManager.currentUser {
                    Text("Привет, \(user.name)!")
                        .font(.title)
                        .padding(.top)

                    VStack(spacing: 15) {
                        VStack {
                            Text("Текущий статус:")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text(user.status.description)
                                .font(.title2)
                                .foregroundColor(statusColor(for: user.status))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Изменить статус:")
                                .font(.headline)
                                .foregroundColor(.gray)

                            Picker("Статус", selection: $selectedStatus) {
                                ForEach(UserStatus.allCases, id: \.self) { status in
                                    Text(status.description)
                                        .tag(status)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onAppear {
                                selectedStatus = user.status
                            }
                        }

                        Button(action: {
                            userManager.updateCurrentUserStatus(selectedStatus)
                        }) {
                            Text("Сохранить статус")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                    .padding(.horizontal)

                    Spacer()

                    Button("Выйти") {
                        userManager.logout()
                    }
                    .foregroundColor(.red)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
        }
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
