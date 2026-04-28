//
//  FHIRNetworkService+Patients.swift
//  FHIRDemo
//
//  Created by Marek Hac on 20/04/2026.
//

import Foundation

extension FHIRNetworkService {

    func getPatients(count: Int = 5) async throws -> [Patient] {
        let request = makeRequest(
            path: "/Patient",
            method: .GET,
            queryItems: ["_count": "\(count)"]
        )

        let bundle: PatientBundle = try await perform(request)

        guard bundle.resourceType == "Bundle" else {
            throw NetworkError.invalidResponse("Expected Bundle, got \(bundle.resourceType)")
        }

        return bundle.entry?.compactMap { $0.resource } ?? []
    }

    func createPatient(_ patient: Patient) async throws -> Patient {
        let request = try makeRequest(
            path: "/Patient",
            method: .POST,
            body: patient
        )

        return try await perform(request)
    }

    func deletePatient(id: String) async throws {
        let request = makeRequest(
            path: "/Patient/\(id)",
            method: .DELETE
        )

        _ = try await performRaw(request)
    }
}
