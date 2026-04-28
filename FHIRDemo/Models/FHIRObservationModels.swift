//
//  FHIRObservationModels.swift
//  FHIRDemo
//
//  Created by Marek Hac on 23/04/2026.
//

import Foundation

struct FHIRObservation: Codable, Identifiable {
    let id: String?
    let resourceType: String
    let status: String
    let category: [ObservationCategory]?
    let code: ObservationCode
    let subject: ObservationSubject?
    let effectiveDateTime: String?
    let valueQuantity: ObservationQuantity?

    var displayTitle: String { code.text ?? code.coding.first?.display ?? "Observation" }

    var displayValue: String {
        guard let q = valueQuantity else { return "—" }
        return "\(formatValue(q.value)) \(q.unit)"
    }

    var displayDate: String {
        guard let raw = effectiveDateTime,
              let date = ISO8601DateFormatter().date(from: raw) else { return "—" }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }

    var icon: String {
        switch code.coding.first?.code {
        case "8867-4":  return "heart.fill"
        case "55423-8": return "figure.walk"
        default:        return "waveform.path.ecg"
        }
    }

    init(
        id: String? = nil,
        resourceType: String = "Observation",
        status: String = "final",
        category: [ObservationCategory]? = nil,
        code: ObservationCode,
        subject: ObservationSubject? = nil,
        effectiveDateTime: String? = nil,
        valueQuantity: ObservationQuantity? = nil
    ) {
        self.id = id
        self.resourceType = resourceType
        self.status = status
        self.category = category
        self.code = code
        self.subject = subject
        self.effectiveDateTime = effectiveDateTime
        self.valueQuantity = valueQuantity
    }

    private func formatValue(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}

struct FHIRObservationBundle: Codable {
    let resourceType: String
    let entry: [FHIRObservationBundleEntry]?
}

struct FHIRObservationBundleEntry: Codable {
    let resource: FHIRObservation?
}

struct ObservationCategory: Codable {
    let coding: [ObservationCoding]
}

struct ObservationCode: Codable {
    let coding: [ObservationCoding]
    let text: String?
}

struct ObservationCoding: Codable {
    let system: String
    let code: String
    let display: String?
}

struct ObservationSubject: Codable {
    let reference: String
}

struct ObservationQuantity: Codable {
    let value: Double
    let unit: String
    let system: String
    let code: String
}


extension FHIRObservation {

    private static let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static let loincSystem    = "http://loinc.org"
    private static let ucumSystem     = "http://unitsofmeasure.org"
    private static let categorySystem = "http://terminology.hl7.org/CodeSystem/observation-category"

    static func heartRate(_ bpm: Double, patientId: String, date: Date) -> FHIRObservation {
        FHIRObservation(
            category: [ObservationCategory(coding: [
                ObservationCoding(system: categorySystem, code: "vital-signs", display: "Vital Signs")
            ])],
            code: ObservationCode(
                coding: [ObservationCoding(system: loincSystem, code: "8867-4", display: "Heart rate")],
                text: "Heart rate"
            ),
            subject: ObservationSubject(reference: "Patient/\(patientId)"),
            effectiveDateTime: dateFormatter.string(from: date),
            valueQuantity: ObservationQuantity(value: bpm, unit: "beats/minute", system: ucumSystem, code: "/min")
        )
    }

    static func stepCount(_ steps: Double, patientId: String, date: Date) -> FHIRObservation {
        FHIRObservation(
            category: [ObservationCategory(coding: [
                ObservationCoding(system: categorySystem, code: "activity", display: "Activity")
            ])],
            code: ObservationCode(
                coding: [ObservationCoding(system: loincSystem, code: "55423-8", display: "Number of steps in unspecified time Pedometer")],
                text: "Step count"
            ),
            subject: ObservationSubject(reference: "Patient/\(patientId)"),
            effectiveDateTime: dateFormatter.string(from: date),
            valueQuantity: ObservationQuantity(value: steps, unit: "steps", system: ucumSystem, code: "{steps}")
        )
    }
}
