//
//  HealthSyncViewModel.swift
//  FHIRDemo
//
//  Created by Marek Hac on 23/04/2026.
//

import Foundation

@Observable
class HealthSyncViewModel {

    let patient: Patient

    var heartRate: Double? = nil
    var stepCount: Double? = nil
    var observations: [FHIRObservation] = []
    var isLoadingHealth: Bool = false
    var isLoadingObservations: Bool = false
    var isSyncing: Bool = false
    var syncResult: SyncResult? = nil
    var healthKitAvailable: Bool = false
    var errorMessage: String? = nil

    enum SyncResult {
        case success(Int)
        case failure(String)
    }

    private let healthKitService = HealthKitService()
    private let networkService = FHIRNetworkService()

    init(patient: Patient) {
        self.patient = patient
    }

    @MainActor
    func onAppear() async {
        healthKitAvailable = healthKitService.isAvailable

        async let healthLoad: () = loadHealthKitData()
        async let observationsLoad: () = loadObservations()
        _ = await (healthLoad, observationsLoad)
    }

    @MainActor
    private func loadHealthKitData() async {
        guard healthKitAvailable else { return }

        do {
            try await healthKitService.requestAuthorization()
            await loadHealthData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadHealthData() async {
        isLoadingHealth = true
        defer { isLoadingHealth = false }

        do {
            async let hr = healthKitService.latestHeartRate()
            async let steps = healthKitService.todayStepCount()
            heartRate = try await hr
            stepCount = try await steps
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadObservations() async {
        guard let patientId = patient.id else { return }

        isLoadingObservations = true
        defer { isLoadingObservations = false }

        do {
            let all = try await networkService.getObservations(for: patientId)
            observations = all.filter { obs in
                guard let loincCode = obs.code.coding.first?.code,
                      loincCode == "8867-4" || loincCode == "55423-8",
                      let dateStr = obs.effectiveDateTime,
                      let date = ISO8601DateFormatter().date(from: dateStr) else { return false }
                return Calendar.current.isDateInToday(date)
            }
        } catch {
            print("[NETWORK] \(error)")
        }
    }

    @MainActor
    func syncToFHIR() async {
        guard let patientId = patient.id else {
            errorMessage = "Patient has no FHIR ID"
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        var newObservations: [FHIRObservation] = []
        var errors: [String] = []
        let now = Date()

        if let bpm = heartRate {
            do {
                let obs = try await networkService.createObservation(.heartRate(bpm, patientId: patientId, date: now))
                newObservations.append(obs)
            } catch {
                errors.append("Heart rate: \(error.localizedDescription)")
            }
        }

        if let steps = stepCount {
            do {
                let obs = try await networkService.createObservation(.stepCount(steps, patientId: patientId, date: now))
                newObservations.append(obs)
            } catch {
                errors.append("Steps: \(error.localizedDescription)")
            }
        }

        syncResult = errors.isEmpty
            ? .success(newObservations.count)
            : .failure(errors.joined(separator: "\n"))

        if !newObservations.isEmpty {
            observations = newObservations + observations
        }
    }
}
