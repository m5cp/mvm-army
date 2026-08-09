import Foundation

/// Central feature gate. The ONLY place gating rules live.
///
/// Free forever: the whole calculator — every branch, every score, and every
/// export of your OWN result, including the DA Form 705. Scoring a test is the
/// reason a soldier installs this; paywalling the paperwork for a score they
/// already earned is not a business model. Also free: Quick Start, step
/// tracking, basic workouts, badges, the watch app and AI Insights.
///
/// Pro is about managing OTHER people and multi-week programming.
@MainActor
enum ProGate {

    enum Feature {
        case multiWeekPlans     // free: shortest duration option only
        case unitPTBuilder      // free: 1 saved plan
        case da705Export        // FREE — your own score sheet
        case planPDFExport      // pro only
        case shareCardTemplates // free: default template only
        case squadMembers       // free: up to 4 members
    }

    /// Free tier limits
    static let freeUnitPTPlanLimit = 1
    static let freeSquadMemberLimit = 4

    static func isUnlocked(_ feature: Feature, isPremium: Bool, savedUnitPTPlanCount: Int = 0, squadMemberCount: Int = 0) -> Bool {
        if isPremium { return true }
        switch feature {
        case .multiWeekPlans: return false
        case .unitPTBuilder: return savedUnitPTPlanCount < freeUnitPTPlanLimit
        case .da705Export: return true // the calculator is free, paperwork included
        case .planPDFExport: return false
        case .shareCardTemplates: return false
        case .squadMembers: return squadMemberCount < freeSquadMemberLimit
        }
    }
}
