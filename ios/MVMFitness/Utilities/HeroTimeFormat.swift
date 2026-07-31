import Foundation

/// User-configurable preference for how the hero date-line's time segment renders.
/// Persisted via `@AppStorage("timeFormatPreference")` — a simple display setting,
/// not user data, so UserDefaults is appropriate.
enum TimeFormatPreference: String, CaseIterable, Identifiable, Sendable {
    case system
    case military
    case standard

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "Match iPhone"
        case .military: return "Military"
        case .standard: return "Standard"
        }
    }

    var example: String {
        switch self {
        case .system: return "Uses your iOS clock setting"
        case .military: return "1905 HRS"
        case .standard: return "7:05 PM"
        }
    }
}

/// Shared formatter for the "hero date line" style used on Home (and any future
/// share card / session header that adopts the same spec-sheet date+time stamp),
/// so the time-format preference is applied consistently in exactly one place.
enum HeroTimeFormat {
    /// Formats just the time segment (e.g. "1905 HRS" or "7:05 PM") per the given preference.
    /// Always resolves against `TimeZone.current` so travel/PCS moves never show a stale zone.
    static func timeString(from date: Date, preference: TimeFormatPreference) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = .current

        switch preference {
        case .military:
            formatter.dateFormat = "HHmm"
            return "\(formatter.string(from: date)) HRS"
        case .standard:
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date).uppercased()
        case .system:
            formatter.setLocalizedDateFormatFromTemplate("j")
            return formatter.string(from: date).uppercased()
        }
    }

    /// Full hero date line: "THU 30 JUL · 1905 HRS" (date portion, separator, casing all fixed —
    /// only the time segment varies with `preference`).
    static func dateLine(from date: Date, preference: TimeFormatPreference, separator: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "EEE d MMM"
        let datePart = dateFormatter.string(from: date).uppercased()
        let timePart = timeString(from: date, preference: preference)
        return "\(datePart) \(separator) \(timePart)"
    }
}
