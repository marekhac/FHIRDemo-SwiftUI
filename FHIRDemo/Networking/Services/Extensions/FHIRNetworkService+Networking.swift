//
//  FHIRNetworkService+Networking.swift
//  FHIRDemo
//
//  Created by Marek Hac on 20/04/2026.
//

import Foundation

extension FHIRNetworkService {

    func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data = try await performRaw(request)
        
        print("[NETWORK] Request to URL: \(String(describing: request.url))")
        
        return try decoder.decode(T.self, from: data)
    }

    func performRaw(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidStatusCode
        }

        return data
    }
}
