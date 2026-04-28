//
//  HealthSyncView.swift
//  FHIRDemo
//
//  Created by Marek Hac on 23/04/2026.
//

import SwiftUI

struct HealthSyncView: View {

    @State var viewModel: HealthSyncViewModel

    init(patient: Patient) {
        _viewModel = State(initialValue: HealthSyncViewModel(patient: patient))
    }

    var body: some View {
        List {
            if !viewModel.healthKitAvailable {
                simulatorBanner
            } else {
                healthDataSection
                syncSection
            }
            observationsSection
        }
        .navigationTitle("Health Sync")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.onAppear() }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    var simulatorBanner: some View {
        Section {
            Label("HealthKit is not available on this device or simulator.",
                  systemImage: "exclamationmark.triangle")
                .foregroundStyle(.secondary)
        }
    }

    var healthDataSection: some View {
        Section("Health Data") {
            if viewModel.isLoadingHealth {
                ProgressView("Loading health data…")
            } else {
                heartRateRow
                stepCountRow
            }
        }
    }

    var heartRateRow: some View {
        LabeledContent("Heart Rate") {
            if let bpm = viewModel.heartRate {
                Text("\(Int(bpm)) bpm")
            } else {
                Text("No data").foregroundStyle(.secondary)
            }
        }
    }

    var stepCountRow: some View {
        LabeledContent("Steps Today") {
            if let steps = viewModel.stepCount {
                Text("\(Int(steps))")
            } else {
                Text("No data").foregroundStyle(.secondary)
            }
        }
    }

    var syncSection: some View {
        Section("FHIR Sync") {
            if viewModel.isSyncing {
                syncInProgressRow
            } else {
                syncButton
            }
            if let result = viewModel.syncResult {
                syncResultRow(result)
            }
        }
    }

    var syncInProgressRow: some View {
        HStack {
            ProgressView()
            Text("Posting to FHIR server…")
                .foregroundStyle(.secondary)
        }
    }

    var syncButton: some View {
        Button("Sync to FHIR") {
            Task { await viewModel.syncToFHIR() }
        }
        .disabled(viewModel.heartRate == nil && viewModel.stepCount == nil)
    }

    var observationsSection: some View {
        Section("Synced Observations") {
            if viewModel.isLoadingObservations {
                ProgressView("Loading history…")
            } else if viewModel.observations.isEmpty {
                Text("No observations synced yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.observations) { observation in
                    observationRow(observation)
                }
            }
        }
    }

    func observationRow(_ observation: FHIRObservation) -> some View {
        HStack {
            Image(systemName: observation.icon)
                .foregroundStyle(.pink)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(observation.displayTitle)
                    .font(.subheadline)
                Text(observation.displayDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(observation.displayValue)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    func syncResultRow(_ result: HealthSyncViewModel.SyncResult) -> some View {
        switch result {
        case .success(let count):
            Label("\(count) observation(s) posted successfully",
                  systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .failure(let message):
            Label(message, systemImage: "xmark.circle.fill")
                .foregroundStyle(.red)
        }
    }
}
