//
//  Patient.swift
//  FHIRDemo
//
//  Created by Marek Hac on 17/03/2026.
//

import Foundation

struct Patient: Codable, Identifiable, Hashable {
    let id: String?
    let resourceType: String
    var name: [HumanName]?
    var gender: String?
    var birthDate: String?
    var address: [Address]?
    var telecom: [ContactPoint]?
    var active: Bool?

    var displayName: String {
        guard let names = name, !names.isEmpty else { return "Unknown" }
        let preferred = names.first(where: { $0.use == "official" }) ?? names[0]
        let given = preferred.given?.joined(separator: " ") ?? ""
        let family = preferred.family ?? ""
        return [given, family].filter { !$0.isEmpty }.joined(separator: " ")
    }
}

struct HumanName: Codable, Hashable {
    var use: String?
    var family: String?
    var given: [String]?
    var prefix: [String]?
    var suffix: [String]?
}

struct Address: Codable, Hashable {
    var use: String?
    var line: [String]?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
}

struct ContactPoint: Codable, Hashable {
    var system: String?
    var value: String?
    var use: String?
}

struct PatientBundle: Codable {
    let resourceType: String
    let entry: [PatientBundleEntry]?
}

struct PatientBundleEntry: Codable {
    let resource: Patient?
}
