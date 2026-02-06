//
//  ActiveSessionView.swift
//  NetPulse
//

import SwiftUI

/// Экран активной сессии с таймером (по ТЗ: синхронизированный таймер).
struct ActiveSessionView: View {
    @EnvironmentObject var sessionManager: SessionManager

    private var session: Session? { sessionManager.activeSession }

    var body: some View {
        Group {
            if let session = session {
                VStack(spacing: 24) {
                    Text(session.sessionType.description)
                        .font(.title2)
                        .foregroundColor(.secondary)

                    Text(formattedRemaining)
                        .font(.system(size: 56, weight: .light, design: .monospaced))
                        .contentTransition(.numericText())

                    Text("осталось")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button("Завершить сессию") {
                        sessionManager.endSession()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ContentUnavailableView(
                    "Нет активной сессии",
                    systemImage: "timer",
                    description: Text("Примите приглашение в разделе «Друзья» и начните сессию.")
                )
            }
        }
        .navigationTitle("Сессия")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formattedRemaining: String {
        let total = sessionManager.sessionRemainingSeconds
        let min = total / 60
        let sec = total % 60
        return String(format: "%d:%02d", min, sec)
    }
}
