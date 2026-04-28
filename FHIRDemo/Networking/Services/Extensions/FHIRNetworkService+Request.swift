//
//  FHIRNetworkService+Request.swift.swift
//  FHIRDemo
//
//  Created by Marek Hac on 21/04/2026.
//

import Foundation

extension FHIRNetworkService {

    // MARK: - Request WITHOUT body (GET, DELETE)

    func makeRequest(
        path: String,
        method: HTTPMethod,
        queryItems: [String: String]? = nil
    ) -> URLRequest {

        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )!

        if let queryItems = queryItems {
            components.queryItems = queryItems.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue

        request.setValue("application/fhir+json", forHTTPHeaderField: "Accept")

        return request
    }

    // MARK: - Request WITH body (POST, PUT)

    func makeRequest<T: Encodable>(
        path: String,
        method: HTTPMethod,
        body: T
    ) throws -> URLRequest {

        var request = makeRequest(
            path: path,
            method: method,
            queryItems: nil
        )

        request.setValue("application/fhir+json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        return request
    }
}
