//
//  PatientItemView.swift
//  FHIRDemo
//
//  Created by Marek Hac on 19/04/2026.
//

import SwiftUI

struct PatientItemView: View {

    let patient: Patient
    let onTap: () -> Void

    var body: some View {
        patientRow
            .onTapGesture { onTap() }
    }

    var patientRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            patientName
            patientDetails
        }
        .padding(.vertical, 4)
    }

    var patientName: some View {
        Text(patient.displayName)
            .font(.headline)
    }

    var patientDetails: some View {
        HStack {
            if let gender = patient.gender {
                Text(gender.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let dob = patient.birthDate {
                Text(dob)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
