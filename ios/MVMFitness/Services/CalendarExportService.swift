import EventKit
import Foundation

@Observable
final class CalendarExportService {
    var authorizationStatus: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)
    var isExporting: Bool = false
    var lastExportResult: ExportResult?

    private let store = EKEventStore()

    nonisolated enum ExportResult: Sendable {
        case success(count: Int)
        case partial(exported: Int, failed: Int)
        case denied
        case error(String)
    }

    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestFullAccessToEvents()
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            return granted
        } catch {
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            return false
        }
    }

    func exportWorkout(_ day: WorkoutDay) async -> ExportResult {
        guard await requestAccess() else { return .denied }

        isExporting = true
        defer { isExporting = false }

        let event = EKEvent(eventStore: store)
        event.title = "PT: \(day.title)"
        event.startDate = Calendar.current.date(bySettingHour: 6, minute: 30, second: 0, of: day.date) ?? day.date
        event.endDate = Calendar.current.date(byAdding: .minute, value: estimatedMinutes(day), to: event.startDate)

        var notes = day.title
        if !day.tags.isEmpty {
            notes += "\n\(day.tags.joined(separator: " · "))"
        }
        notes += "\n\nExercises:"
        for exercise in day.exercises {
            notes += "\n• \(exercise.name) — \(exercise.displayDetail)"
            if !exercise.notes.isEmpty {
                notes += " (\(exercise.notes))"
            }
        }
        notes += "\n\nExported from MVM Army"
        event.notes = notes
        event.calendar = store.defaultCalendarForNewEvents

        do {
            try store.save(event, span: .thisEvent)
            let result = ExportResult.success(count: 1)
            lastExportResult = result
            return result
        } catch {
            let result = ExportResult.error(error.localizedDescription)
            lastExportResult = result
            return result
        }
    }

    func exportWeeklyPlan(_ plan: WeeklyPlan) async -> ExportResult {
        guard await requestAccess() else { return .denied }

        isExporting = true
        defer { isExporting = false }

        var exported = 0
        var failed = 0

        for day in plan.days where !day.isRestDay {
            let event = EKEvent(eventStore: store)
            event.title = "PT: \(day.title)"
            event.startDate = Calendar.current.date(bySettingHour: 6, minute: 30, second: 0, of: day.date) ?? day.date
            event.endDate = Calendar.current.date(byAdding: .minute, value: estimatedMinutes(day), to: event.startDate)

            var notes = day.title
            if !day.tags.isEmpty {
                notes += "\n\(day.tags.joined(separator: " · "))"
            }
            notes += "\n\nExercises:"
            for exercise in day.exercises {
                notes += "\n• \(exercise.name) — \(exercise.displayDetail)"
            }
            notes += "\n\nExported from MVM Army"
            event.notes = notes
            event.calendar = store.defaultCalendarForNewEvents

            do {
                try store.save(event, span: .thisEvent)
                exported += 1
            } catch {
                failed += 1
            }
        }

        let result: ExportResult
        if failed == 0 {
            result = .success(count: exported)
        } else {
            result = .partial(exported: exported, failed: failed)
        }
        lastExportResult = result
        return result
    }

    func exportWODPlan(_ plan: WODPlan) async -> ExportResult {
        guard await requestAccess() else { return .denied }

        isExporting = true
        defer { isExporting = false }

        var exported = 0
        var failed = 0

        for day in plan.days where !day.isRestDay {
            let event = EKEvent(eventStore: store)
            event.title = "WOD: \(day.template.title)"
            event.startDate = Calendar.current.date(bySettingHour: 6, minute: 30, second: 0, of: day.date) ?? day.date
            event.endDate = Calendar.current.date(byAdding: .minute, value: max(day.template.durationMinutes, 15), to: event.startDate)

            var notes = day.template.title
            notes += "\n\(day.template.format.rawValue) · ~\(day.template.durationMinutes) min"
            if !day.template.movements.isEmpty {
                notes += "\n\nMovements:"
                for movement in day.template.movements {
                    let detail = movement.reps ?? movement.duration ?? ""
                    notes += "\n• \(movement.name)\(detail.isEmpty ? "" : " — \(detail)")"
                }
            }
            notes += "\n\nExported from MVM Army"
            event.notes = notes
            event.calendar = store.defaultCalendarForNewEvents

            do {
                try store.save(event, span: .thisEvent)
                exported += 1
            } catch {
                failed += 1
            }
        }

        let result: ExportResult
        if failed == 0 {
            result = .success(count: exported)
        } else {
            result = .partial(exported: exported, failed: failed)
        }
        lastExportResult = result
        return result
    }

    func exportWODDay(_ day: WODPlanDay) async -> ExportResult {
        guard await requestAccess() else { return .denied }

        isExporting = true
        defer { isExporting = false }

        let event = EKEvent(eventStore: store)
        event.title = "WOD: \(day.template.title)"
        event.startDate = Calendar.current.date(bySettingHour: 6, minute: 30, second: 0, of: day.date) ?? day.date
        event.endDate = Calendar.current.date(byAdding: .minute, value: max(day.template.durationMinutes, 15), to: event.startDate)

        var notes = day.template.title
        notes += "\n\(day.template.format.rawValue) · ~\(day.template.durationMinutes) min"
        if !day.template.movements.isEmpty {
            notes += "\n\nMovements:"
            for movement in day.template.movements {
                let detail = movement.reps ?? movement.duration ?? ""
                notes += "\n• \(movement.name)\(detail.isEmpty ? "" : " — \(detail)")"
            }
        }
        notes += "\n\nExported from MVM Army"
        event.notes = notes
        event.calendar = store.defaultCalendarForNewEvents

        do {
            try store.save(event, span: .thisEvent)
            let result = ExportResult.success(count: 1)
            lastExportResult = result
            return result
        } catch {
            let result = ExportResult.error(error.localizedDescription)
            lastExportResult = result
            return result
        }
    }

    private func estimatedMinutes(_ day: WorkoutDay) -> Int {
        max(day.exercises.count * 4, 15)
    }
}
