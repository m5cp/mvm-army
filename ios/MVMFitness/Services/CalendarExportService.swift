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
        notes += "\n\nExported from MVM Fitness"
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
            notes += "\n\nExported from MVM Fitness"
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
            notes += "\n\nExported from MVM Fitness"
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
        notes += "\n\nExported from MVM Fitness"
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

    func resyncWeeklyPlanFromDate(_ plan: WeeklyPlan, from startDate: Date) async -> ExportResult {
        guard await requestAccess() else { return .denied }

        isExporting = true
        defer { isExporting = false }

        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: startDate)
        let affectedDays = plan.days.filter { cal.startOfDay(for: $0.date) >= dayStart }

        for day in affectedDays {
            removeMVMEvents(on: day.date, prefix: "PT:")
        }

        var exported = 0
        var failed = 0

        for day in affectedDays where !day.isRestDay {
            let event = EKEvent(eventStore: store)
            event.title = "PT: \(day.title)"
            event.startDate = cal.date(bySettingHour: 6, minute: 30, second: 0, of: day.date) ?? day.date
            event.endDate = cal.date(byAdding: .minute, value: estimatedMinutes(day), to: event.startDate)

            var notes = day.title
            if !day.tags.isEmpty {
                notes += "\n\(day.tags.joined(separator: " · "))"
            }
            notes += "\n\nExercises:"
            for exercise in day.exercises {
                notes += "\n• \(exercise.name) — \(exercise.displayDetail)"
            }
            notes += "\n\nExported from MVM Fitness"
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

    func resyncWODPlanFromDate(_ plan: WODPlan, from startDate: Date) async -> ExportResult {
        guard await requestAccess() else { return .denied }

        isExporting = true
        defer { isExporting = false }

        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: startDate)
        let affectedDays = plan.days.filter { cal.startOfDay(for: $0.date) >= dayStart }

        for day in affectedDays {
            removeMVMEvents(on: day.date, prefix: "WOD:")
        }

        var exported = 0
        var failed = 0

        for day in affectedDays where !day.isRestDay {
            let event = EKEvent(eventStore: store)
            event.title = "WOD: \(day.template.title)"
            event.startDate = cal.date(bySettingHour: 6, minute: 30, second: 0, of: day.date) ?? day.date
            event.endDate = cal.date(byAdding: .minute, value: max(day.template.durationMinutes, 15), to: event.startDate)

            var notes = day.template.title
            notes += "\n\(day.template.format.rawValue) · ~\(day.template.durationMinutes) min"
            if !day.template.movements.isEmpty {
                notes += "\n\nMovements:"
                for movement in day.template.movements {
                    let detail = movement.reps ?? movement.duration ?? ""
                    notes += "\n• \(movement.name)\(detail.isEmpty ? "" : " — \(detail)")"
                }
            }
            notes += "\n\nExported from MVM Fitness"
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

    func resyncSingleDay(on date: Date, title: String, prefix: String, notes: String, durationMinutes: Int) async -> ExportResult {
        guard await requestAccess() else { return .denied }

        isExporting = true
        defer { isExporting = false }

        removeMVMEvents(on: date, prefix: prefix)

        let cal = Calendar.current
        let event = EKEvent(eventStore: store)
        event.title = "\(prefix) \(title)"
        event.startDate = cal.date(bySettingHour: 6, minute: 30, second: 0, of: date) ?? date
        event.endDate = cal.date(byAdding: .minute, value: max(durationMinutes, 15), to: event.startDate)
        event.notes = notes + "\n\nExported from MVM Fitness"
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

    private func removeMVMEvents(on date: Date, prefix: String) {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: date)
        guard let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart) else { return }

        let predicate = store.predicateForEvents(withStart: dayStart, end: dayEnd, calendars: nil)
        let existing = store.events(matching: predicate)

        for event in existing where event.title?.hasPrefix(prefix) == true {
            if event.notes?.contains("Exported from MVM Fitness") == true {
                try? store.remove(event, span: .thisEvent)
            }
        }
    }

    private func estimatedMinutes(_ day: WorkoutDay) -> Int {
        max(day.exercises.count * 4, 15)
    }
}
