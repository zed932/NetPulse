//
//  NetworkManager.swift
//  NetPulse
//

import Foundation

final class NetworkManager: NetworkServiceProtocol {
    static let shared = NetworkManager()
    private init() {}
    
    // Заглушка для имитации сетевого запроса
    func simulateNetworkRequest(completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let randomSuccess = Bool.random()
            
            DispatchQueue.main.async {
                if randomSuccess {
                    completion(.success("Запрос выполнен успешно"))
                } else {
                    completion(.failure(NSError(domain: "NetworkError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Ошибка сети"])))
                }
            }
        }
    }
}
