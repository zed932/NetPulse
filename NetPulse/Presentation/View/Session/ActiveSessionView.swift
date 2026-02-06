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
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if let session = session {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(session.sessionType.description)
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.secondary)

                        Text(formattedRemaining)
                            .font(.system(size: 56, weight: .light, design: .monospaced))
                            .contentTransition(.numericText())
                            .monospacedDigit()
                            .animation(.easeInOut(duration: 0.25), value: sessionManager.sessionRemainingSeconds)

                        Text("осталось")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .appCard()

                    Spacer()

                    Button("Завершить сессию") {
                        sessionManager.endSession()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .tint(AppTheme.destructive)
                    .padding(.bottom, 32)
                }
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
