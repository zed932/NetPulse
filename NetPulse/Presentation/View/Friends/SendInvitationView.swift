//
//  SendInvitationView.swift
//  NetPulse
//

import SwiftUI

struct SendInvitationView: View {
    let friend: User
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: SessionType = .work

    var body: some View {
        NavigationView {
            Form {
                Section {
                    LabeledContent("Кому", value: friend.name)
                    LabeledContent("Статус", value: friend.status.description)
                }
                Section("Тип сессии") {
                    Picker("Тип", selection: $selectedType) {
                        ForEach(SessionType.allCases, id: \.self) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    Button("Отправить приглашение") {
                        send()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(userManager.currentUser == nil)
                }
            }
            .navigationTitle("Пригласить на сессию")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }

    private func send() {
        guard let current = userManager.currentUser else { return }
        if sessionManager.sendInvitation(from: current, to: friend, sessionType: selectedType) {
            dismiss()
        }
    }
}
