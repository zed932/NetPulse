//
//  AcceptAndStartSessionSheet.swift
//  NetPulse
//

import SwiftUI

/// Шит после «Принять»: выбор длительности и запуск сессии.
struct AcceptAndStartSessionSheet: View {
    let invitation: Invitation
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss
    @State private var durationMinutes: Int = 25

    private static let durationOptions = [5, 15, 25, 45]

    var body: some View {
        NavigationView {
            Form {
                Section {
                    if let from = sessionManager.sender(of: invitation, in: userManager.allUsers) {
                        LabeledContent("От", value: from.name)
                    }
                    LabeledContent("Тип сессии", value: invitation.sessionType.description)
                }
                Section("Длительность") {
                    Picker("Минут", selection: $durationMinutes) {
                        ForEach(Self.durationOptions, id: \.self) { n in
                            Text("\(n) мин").tag(n)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    Button("Начать сессию") {
                        startSession()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Начать сессию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }

    private func startSession() {
        if sessionManager.startSession(acceptedInvitation: invitation, durationMinutes: durationMinutes) {
            dismiss()
        }
    }
}
