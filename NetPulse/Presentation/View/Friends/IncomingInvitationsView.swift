//
//  IncomingInvitationsView.swift
//  NetPulse
//

import SwiftUI

struct IncomingInvitationsView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var sessionManager: SessionManager
    @State private var invitationToStart: Invitation?

    private var incoming: [Invitation] {
        guard let user = userManager.currentUser else { return [] }
        return sessionManager.incomingInvitations(for: user)
    }

    var body: some View {
        Group {
            if incoming.isEmpty {
                Text("Нет входящих приглашений")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(incoming) { inv in
                    if let from = sessionManager.sender(of: inv, in: userManager.allUsers) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(from.name)
                                    .font(.headline)
                                Text(inv.sessionType.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Принять") {
                                invitationToStart = inv
                            }
                            .buttonStyle(.borderedProminent)
                            Button("Отклонить") {
                                sessionManager.decline(inv)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .sheet(item: $invitationToStart) { inv in
            AcceptAndStartSessionSheet(invitation: inv)
        }
    }
}
