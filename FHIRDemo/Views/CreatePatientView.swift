//
//  CreatePatientView.swift
//  FHIRDemo
//
//  Created by Marek Hac on 21/04/2026.
//

import SwiftUI

struct CreatePatientView: View {

    @State var viewModel = CreatePatientViewModel()
    @Environment(\.dismiss) private var dismiss

    var onPatientCreated: (Patient) -> Void

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                demographicsSection
                contactSection
                addressSection
            }
            .navigationTitle("New Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
                ToolbarItem(placement: .confirmationAction) {
                    saveButton
                }
            }
        }
    }

    var nameSection: some View {
        Section("Name") {
            TextField("First name", text: $viewModel.firstName)
                .textContentType(.givenName)
            TextField("Last name", text: $viewModel.lastName)
                .textContentType(.familyName)
        }
    }

    var demographicsSection: some View {
        Section("Demographics") {
            Picker("Gender", selection: $viewModel.gender) {
                ForEach(viewModel.genderOptions, id: \.self) { option in
                    Text(option.capitalized).tag(option)
                }
            }
            TextField("Date of birth (YYYY-MM-DD)", text: $viewModel.birthDate)
                .keyboardType(.numbersAndPunctuation)
        }
    }

    var contactSection: some View {
        Section("Contact") {
            TextField("Phone number", text: $viewModel.phone)
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
        }
    }

    var addressSection: some View {
        Section("Address") {
            TextField("Street", text: $viewModel.street)
                .textContentType(.streetAddressLine1)
            TextField("City", text: $viewModel.city)
                .textContentType(.addressCity)
            TextField("State", text: $viewModel.state)
                .textContentType(.addressState)
            TextField("Postal code", text: $viewModel.postalCode)
                .textContentType(.postalCode)
                .keyboardType(.numbersAndPunctuation)
        }
    }

    var cancelButton: some View {
        Button("Cancel") { dismiss() }
            .disabled(viewModel.isLoading)
    }

    var saveButton: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Button("Save") {
                    Task {
                        if let patient = await viewModel.createPatient() {
                            onPatientCreated(patient)
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.firstName.isEmpty || viewModel.lastName.isEmpty)
            }
        }
    }
}
