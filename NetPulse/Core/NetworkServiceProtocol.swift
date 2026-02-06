//
//  NetworkServiceProtocol.swift
//  NetPulse
//

import Foundation

/// Протокол сетевого сервиса (по ТЗ: WebSocket + REST).
/// Позволяет подменять реализацию в тестах и при переходе на реальный API.
protocol NetworkServiceProtocol: AnyObject {
    func simulateNetworkRequest(completion: @escaping (Result<String, Error>) -> Void)
}
