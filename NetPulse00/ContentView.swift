//
//  ContentView.swift
//  NetPulse00
//
//  Created by Сергей Мещеряков on 29.12.2025.
//

import SwiftUI

struct ContentView: View {
    
    let user: User
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Заголовок с именем
                Text("Привет, \(user.name)!")
                    .font(.title)
                    .padding(.top)
                
                // Информация о пользователе
                VStack(alignment: .leading, spacing: 15) {
                    InfoRow(title: "Имя:", value: user.name)
                    InfoRow(title: "Email:", value: user.email)
                    InfoRow(title: "Текущий статус:", value: statusText)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Кнопка смены статуса
                Button(action: {
                    userManager.updateUserStatus(user.status == .online ? .offline : .online)
                }) {
                    Text(statusButtonText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(statusButtonColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Кнопка выхода
                Button("Выйти") {
                    userManager.logout()
                }
                .foregroundColor(.red)
                .padding(.bottom, 20)
            }
            .navigationTitle("Главный экран")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Вычисляемые свойства для лучшей читаемости
    private var statusText: String {
        switch user.status {
        case .online: return "Онлайн"
        case .offline: return "Оффлайн"
        case .studying: return "Учится"
        case .working: return "Работает"
        }
    }
    
    private var statusButtonText: String {
        user.status == .online ? "Перейти в оффлайн" : "Вернуться онлайн"
    }
    
    private var statusButtonColor: Color {
        user.status == .online ? Color.orange : Color.green
    }
}

// Вспомогательный View для отображения строк информации
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView(user: User(name: "Сергей", email: "mail@mail.ru"))
        .environmentObject(UserManager())
}
