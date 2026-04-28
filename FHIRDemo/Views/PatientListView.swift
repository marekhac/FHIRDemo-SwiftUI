//
//  PatientListView.swift
//  FHIRDemo
//
//  Created by Marek Hac on 18/04/2026.
//

import SwiftUI

struct PatientListView: View {

    @State var viewModel = PatientListViewModel()
    @State private var showCreateSheet = false
    @State private var selectedPatient: Patient?

    var body: some View {
        NavigationStack {
            patientList
                .navigationTitle("Patients")
                .navigationDestination(item: $selectedPatient) { patient in
                    PatientDetailView(patient: patient)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        addButton
                    }
                }
                .sheet(isPresented: $showCreateSheet) {
                    CreatePatientView { newPatient in
                        viewModel.patients.insert(newPatient, at: 0)
                    }
                }
        }
        .task {
            await viewModel.getPatients()
        }
    }

    var patientList: some View {
        List {
            ForEach(viewModel.patients) { patient in
                PatientItemView(patient: patient, onTap: { selectedPatient = patient })
            }
            .onDelete { indexSet in
                Task { await viewModel.deletePatient(at: indexSet) }
            }
        }
        .refreshable {
            await viewModel.getPatients()
        }
        .overlay {
            if viewModel.isLoading {
                centeredProgressView
            }
        }
    }

    var addButton: some View {
        Button {
            showCreateSheet = true
        } label: {
            Image(systemName: "plus")
        }
    }

    var centeredProgressView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
    }
}

#Preview {
    PatientListView()
}
