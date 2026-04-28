//
//  PatientDetailView.swift
//  FHIRDemo
//
//  Created by Marek Hac on 21/04/2026.
//

import SwiftUI

struct PatientDetailView: View {

    let patient: Patient
    @State private var showHealthSync = false

    var body: some View {
        List {
            identitySection
            if let names = patient.name, !names.isEmpty {
                namesSection(names)
            }
            if let telecoms = patient.telecom, !telecoms.isEmpty {
                contactSection(telecoms)
            }
            if let addresses = patient.address, !addresses.isEmpty {
                addressSection(addresses)
            }
        }
        .navigationTitle(patient.displayName)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $showHealthSync) {
            HealthSyncView(patient: patient)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHealthSync = true
                } label: {
                    Image(systemName: "heart.text.clipboard")
                }
            }
        }
    }

    var identitySection: some View {
        Section("Identity") {
            if let id = patient.id {
                LabeledContent("FHIR ID", value: id)
                    .font(.caption)
            }
            LabeledContent("Active", value: patient.active == true ? "Yes" : "No")
            if let gender = patient.gender {
                LabeledContent("Gender", value: gender.capitalized)
            }
            if let dob = patient.birthDate {
                LabeledContent("Date of Birth", value: dob)
            }
        }
    }

    func namesSection(_ names: [HumanName]) -> some View {
        Section("Names") {
            ForEach(names, id: \.self) { nameRow($0) }
        }
    }

    func nameRow(_ name: HumanName) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let use = name.use {
                Text(use.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            let parts = [name.given?.joined(separator: " "), name.family].compactMap { $0 }
            Text(parts.joined(separator: " "))
        }
        .padding(.vertical, 2)
    }

    func contactSection(_ telecoms: [ContactPoint]) -> some View {
        Section("Contact") {
            ForEach(telecoms, id: \.self) { telecom in
                if let value = telecom.value {
                    LabeledContent(telecom.system?.capitalized ?? "Contact", value: value)
                }
            }
        }
    }

    func addressSection(_ addresses: [Address]) -> some View {
        Section("Addresses") {
            ForEach(addresses, id: \.self) { addressRow($0) }
        }
    }

    func addressRow(_ address: Address) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let use = address.use {
                Text(use.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let lines = address.line {
                ForEach(lines, id: \.self) { Text($0) }
            }
            let cityLine = [address.city, address.state, address.postalCode]
                .compactMap { $0 }
                .joined(separator: ", ")
            if !cityLine.isEmpty { Text(cityLine) }
        }
        .padding(.vertical, 2)
    }
}
