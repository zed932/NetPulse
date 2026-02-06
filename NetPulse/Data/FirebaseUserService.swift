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

    /// Обновить пользователя в Firebase (профиль, статус, список друзей).
    func updateUser(_ user: User) async {
        guard let baseURL = baseURL else { return }
        let url = baseURL.appendingPathComponent("users/\(user.id.uuidString).json")

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.dateEncodingStrategy = .secondsSince1970

        guard let body = try? encoder.encode(user) else { return }
        request.httpBody = body

        _ = try? await session.data(for: request)
    }

    /// Обновить статус пользователя в Firebase (удобный алиас).
    func updateUserStatus(_ user: User) async {
        await updateUser(user)
    }

    // MARK: - Заявки в друзья

    private static var dateDecoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .useDefaultKeys
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            if let secs = try? container.decode(Double.self) {
                return Date(timeIntervalSince1970: secs)
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected date as Double")
        }
        return d
    }

    private static var dateEncoder: JSONEncoder {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .useDefaultKeys
        e.dateEncodingStrategy = .secondsSince1970
        return e
    }

    /// Загрузить все заявки в друзья из Firebase.
    func fetchFriendRequests() async throws -> [FriendRequest] {
        guard let baseURL = baseURL else { return [] }
        let url = baseURL.appendingPathComponent("friendRequests.json")

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            return []
        }

        // Пустой ответ или null
        if data.isEmpty || data.count <= 4 && String(data: data, encoding: .utf8) == "null" {
            return []
        }

        if let dict = try? Self.dateDecoder.decode([String: FriendRequest].self, from: data) {
            return Array(dict.values)
        }
        if let arr = try? Self.dateDecoder.decode([FriendRequest].self, from: data) {
            return arr
        }
        return []
    }

    /// Создать заявку в друзья в Firebase.
    func createFriendRequest(_ request: FriendRequest) async {
        guard let baseURL = baseURL else { return }
        let url = baseURL.appendingPathComponent("friendRequests/\(request.id.uuidString).json")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? Self.dateEncoder.encode(request)

        _ = try? await session.data(for: urlRequest)
    }

    /// Обновить статус заявки в друзья (PATCH, чтобы не затирать остальные поля).
    func updateFriendRequestStatus(id: UUID, status: FriendRequestStatus) async {
        guard let baseURL = baseURL else { return }
        let url = baseURL.appendingPathComponent("friendRequests/\(id.uuidString).json")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["status": status.rawValue]
        urlRequest.httpBody = try? JSONEncoder().encode(body)

        _ = try? await session.data(for: urlRequest)
    }
}

