//
//  CreatePatientViewModel.swift
//  FHIRDemo
//
//  Created by Marek Hac on 20/04/2026.
//

import Foundation

@Observable
class CreatePatientViewModel {

    var firstName: String = ""
    var lastName: String = ""
    var gender: String = "unknown"
    var birthDate: String = ""
    var phone: String = ""
    var street: String = ""
    var city: String = ""
    var state: String = ""
    var postalCode: String = ""
    var isLoading: Bool = false

    let genderOptions = ["male", "female", "other", "unknown"]

    private var networkService = FHIRNetworkService()

    @MainActor
    func createPatient() async -> Patient? {
        isLoading = true
        defer { isLoading = false }

        let patient = Patient(
            id: nil,
            resourceType: "Patient",
            name: [HumanName(use: "official", family: lastName, given: [firstName])],
            gender: gender,
            birthDate: birthDate.isEmpty ? nil : birthDate,
            address: buildAddress(),
            telecom: phone.isEmpty ? nil : [ContactPoint(system: "phone", value: phone, use: "home")],
            active: true
        )

        return try? await networkService.createPatient(patient)
    }

    private func buildAddress() -> [Address]? {
        let hasData = [street, city, state, postalCode].contains { !$0.isEmpty }
        guard hasData else { return nil }
        return [Address(use: "home", line: street.isEmpty ? nil : [street],
                        city: city.isEmpty ? nil : city,
                        state: state.isEmpty ? nil : state,
                        postalCode: postalCode.isEmpty ? nil : postalCode,
                        country: "US")]
    }
}
