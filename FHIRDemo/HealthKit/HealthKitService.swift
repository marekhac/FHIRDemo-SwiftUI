//
//  HealthKitService.swift
//  FHIRDemo
//
//  Created by Marek Hac on 23/04/2026.
//

import HealthKit

final class HealthKitService {

    private let store = HKHealthStore()

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async throws {
        guard isAvailable else { return }

        let types: Set<HKSampleType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.stepCount)
        ]

        try await store.requestAuthorization(toShare: [], read: types)
    }

    func latestHeartRate() async throws -> Double? {
        guard isAvailable else { return nil }

        let type = HKQuantityType(.heartRate)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: type)],
            sortDescriptors: [SortDescriptor(\.startDate, order: .reverse)],
            limit: 1
        )

        let samples = try await descriptor.result(for: store)
        return samples.first?.quantity.doubleValue(for: HKUnit(from: "count/min"))
    }

    func todayStepCount() async throws -> Double? {
        guard isAvailable else { return nil }

        let type = HKQuantityType(.stepCount)
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: type, predicate: predicate),
            options: .cumulativeSum
        )

        let statistics = try await descriptor.result(for: store)
        return statistics?.sumQuantity()?.doubleValue(for: .count())
    }
}
