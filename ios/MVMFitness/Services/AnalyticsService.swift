import Foundation

/// Analytics is currently disabled (TelemetryDeck was removed).
/// This stub keeps every call site compiling as a harmless no-op — if
/// analytics is wanted again later, swap the no-op bodies below for a
/// real provider without touching any call sites.
enum AnalyticsService {

    static func configure() {}

    static func track(_ event: Event) {}

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
