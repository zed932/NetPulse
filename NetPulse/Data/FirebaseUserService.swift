//
//  FirebaseUserService.swift
//  NetPulse
//

import Foundation

/// Сервис работы с пользователями в Firebase Realtime Database.
/// Использует REST API, чтобы не тянуть SDK внутрь демо‑проекта.
final class FirebaseUserService {
    private let baseURL: URL?
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
        if FirebaseConfig.databaseURL.isEmpty {
            baseURL = nil
        } else {
            baseURL = URL(string: FirebaseConfig.databaseURL)
        }
    }

    /// Загрузить всех пользователей из Firebase.
    /// Ожидается структура `/users/{uuid} : User`.
    func fetchUsers() async throws -> [User] {
        guard let baseURL = baseURL else { return [] }
        let url = baseURL.appendingPathComponent("users.json")

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            return []
        }

        // В Realtime DB удобно хранить как словарь [id: User]
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys

        if let dict = try? decoder.decode([String: User].self, from: data) {
            return Array(dict.values)
        } else if let users = try? decoder.decode([User].self, from: data) {
            return users
        } else {
            return []
        }
    }

    /// Обновить статус пользователя в Firebase.
    func updateUserStatus(_ user: User) async {
        guard let baseURL = baseURL else { return }
        let url = baseURL.appendingPathComponent("users/\(user.id.uuidString).json")

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys

        guard let body = try? encoder.encode(user) else { return }
        request.httpBody = body

        _ = try? await session.data(for: request)
    }
}

