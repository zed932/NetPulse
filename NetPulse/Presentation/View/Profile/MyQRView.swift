//
//  MyQRView.swift
//  NetPulse
//

import SwiftUI
import CoreImage.CIFilterBuiltins

/// Экран с QR для приглашения по никнейму.
struct MyQRView: View {
    @EnvironmentObject var userManager: UserManager
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    private var payload: String {
        guard let user = userManager.currentUser else { return "" }
        return "netpulse:user:\(user.username)"
    }

    var body: some View {
        VStack(spacing: 24) {
            if let user = userManager.currentUser,
               let image = generateQRCode(from: payload) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)

                VStack(spacing: 8) {
                    Text(user.name)
                        .font(.headline)
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text("Друзья могут отсканировать этот QR или ввести строку `\(payload)` в поиске по нику.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            } else {
                Text("Нет данных пользователя.")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Мой QR")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        if let cgimg = context.createCGImage(scaled, from: scaled.extent) {
            return UIImage(cgImage: cgimg)
        }
        return nil
    }
}

