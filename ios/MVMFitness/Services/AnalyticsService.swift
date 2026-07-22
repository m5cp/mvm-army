import Foundation
import TelemetryDeck

/// Privacy-first analytics. Event names + counts only.
/// NEVER attach PII, fitness values, scores, names, or health data.
enum AnalyticsService {

    /// Call once at app launch. App ID comes from the TelemetryDeck dashboard —
    /// the developer replaces the placeholder with their real App ID.
    static func configure() {
        let config = TelemetryDeck.Config(appID: "TELEMETRYDECK-APP-ID-PLACEHOLDER")
        TelemetryDeck.initialize(config: config)
    }

    static func track(_ event: Event) {
        TelemetryDeck.signal(event.rawValue)
    }

    enum Event: String {
        case onboardingStepCompleted = "onboarding.stepCompleted"
        case onboardingSkipped = "onboarding.skipped"
        case paywallViewed = "paywall.viewed"
        case paywallPurchaseStarted = "paywall.purchaseStarted"
        case paywallContinuedFree = "paywall.continuedFree"
        case notificationPrimerEnabled = "primer.notificationsEnabled"
        case notificationPrimerSkipped = "primer.notificationsSkipped"
        case aftScoreSaved = "aft.scoreSaved"
        case workoutCompleted = "workout.completed"
        case quickStartCompleted = "quickstart.completed"
        case shareCardShared = "share.cardShared"
        case squadTestDayRun = "squad.testDayRun"
        case cftRecorded = "cft.recorded"
        case whtrRecorded = "abcp.whtrRecorded"
    }
}
