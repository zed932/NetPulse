//
//  PasswordHasher.swift
//  NetPulse
//

import Foundation
import CryptoKit

/// Хеширование пароля с солью (SHA256) для локального хранения. Не заменяет Firebase Auth в production.
enum PasswordHasher {
    private static let saltLength = 32

    static func generateSalt() -> Data {
        var bytes = [UInt8](repeating: 0, count: saltLength)
        _ = SecRandomCopyBytes(kSecRandomDefault, saltLength, &bytes)
        return Data(bytes)
    }

    static func hash(password: String, salt: Data) -> Data {
        var data = salt
        data.append(Data(password.utf8))
        return Data(SHA256.hash(data: data))
    }

    static func verify(password: String, saltHex: String, hashHex: String) -> Bool {
        guard let salt = Data(hexString: saltHex),
              let storedHash = Data(hexString: hashHex) else { return false }
        let computed = hash(password: password, salt: salt)
        return computed == storedHash
    }

    /// Генерирует соль и хеш для сохранения в профиле пользователя.
    static func hashForStorage(password: String) -> (saltHex: String, hashHex: String) {
        let salt = generateSalt()
        let hashData = hash(password: password, salt: salt)
        return (salt.hexString, hashData.hexString)
    }
}

private extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0..<len {
            let j = hexString.index(i, offsetBy: 2)
            guard let byte = UInt8(hexString[i..<j], radix: 16) else { return nil }
            data.append(byte)
            i = j
        }
        self = data
    }

    var hexString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
