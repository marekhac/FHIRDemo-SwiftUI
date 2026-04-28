//
//  PatientListViewModel.swift
//  FHIRDemo
//
//  Created by Marek Hac on 19/04/2026.
//

import Foundation

@Observable
class PatientListViewModel {

    var patients: [Patient] = []
    var isLoading: Bool = false

    private var networkService = FHIRNetworkService()

    @MainActor
    func getPatients() async {
        isLoading = true
        defer { isLoading = false }

        do {
            patients = try await networkService.getPatients()
        } catch {
            print("[ERROR] \(error)")
        }
    }

    @MainActor
    func deletePatient(at offsets: IndexSet) async {
        let ids = offsets.compactMap { patients[$0].id }
        patients.removeAll { patient in ids.contains(patient.id ?? "") }
        for id in ids {
            try? await networkService.deletePatient(id: id)
        }
    }
}
