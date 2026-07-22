import Foundation

/// Central feature gate. The ONLY place gating rules live.
/// Free forever: AFT Calculator, Quick Start, step tracking, basic workouts, AI Insights.
@MainActor
enum ProGate {

    enum Feature {
        case multiWeekPlans     // free: shortest duration option only
        case unitPTBuilder      // free: 1 saved plan
        case da705Export        // pro only
        case planPDFExport      // pro only
        case shareCardTemplates // free: default template only
    }

    /// Free tier limits
    static let freeUnitPTPlanLimit = 1

    static func isUnlocked(_ feature: Feature, isPremium: Bool, savedUnitPTPlanCount: Int = 0) -> Bool {
        if isPremium { return true }
        switch feature {
        case .multiWeekPlans: return false
        case .unitPTBuilder: return savedUnitPTPlanCount < freeUnitPTPlanLimit
        case .da705Export: return false
        case .planPDFExport: return false
        case .shareCardTemplates: return false
        }
    }
}
