//
//  FHIRNetworkService+Observations.swift
//  FHIRDemo
//
//  Created by Marek Hac on 23/04/2026.
//

import Foundation

extension FHIRNetworkService {

    func createObservation(_ observation: FHIRObservation) async throws -> FHIRObservation {
        let request = try makeRequest(path: "/Observation", method: .POST, body: observation)
        return try await perform(request)
    }

    func getObservations(for patientId: String) async throws -> [FHIRObservation] {
        let request = makeRequest(
            path: "/Observation",
            method: .GET,
            queryItems: ["patient": patientId, "_count": "50"]
        )

        let bundle: FHIRObservationBundle = try await perform(request)

        guard bundle.resourceType == "Bundle" else {
            throw NetworkError.invalidResponse("Expected Bundle, got \(bundle.resourceType)")
        }

        return bundle.entry?.compactMap { $0.resource } ?? []
    }
}
