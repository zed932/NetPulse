//
//  AppTheme.swift
//  NetPulse
//

import SwiftUI

/// Общие стили и тема приложения.
enum AppTheme {
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let primary = Color.accentColor
    static let destructive = Color.red
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.primary)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(AppTheme.primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

private struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(16)
    }
}

extension View {
    /// Карточка для основных блоков интерфейса.
    func appCard() -> some View {
        modifier(CardModifier())
    }
}

