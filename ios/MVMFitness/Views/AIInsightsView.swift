import SwiftUI

struct AIInsightsCard: View {
    @Environment(AppViewModel.self) private var vm

    @State private var progressInsight: String = ""
    @State private var weeklySummary: String = ""
    @State private var coachingTip: String = ""
    @State private var isLoadingInsight: Bool = false
    @State private var isLoadingSummary: Bool = false
    @State private var isLoadingTip: Bool = false
    @State private var selectedTab: AIInsightTab = .insight
    @State private var hasGenerated: Bool = false

    enum AIInsightTab: String, CaseIterable {
        case insight = "Insight"
        case summary = "Weekly"
        case tip = "Coaching"
    }

    var body: some View {
        if #available(iOS 26.0, *) {
            AIInsightsCardContent(
                vm: vm,
                progressInsight: $progressInsight,
                weeklySummary: $weeklySummary,
                coachingTip: $coachingTip,
                isLoadingInsight: $isLoadingInsight,
                isLoadingSummary: $isLoadingSummary,
                isLoadingTip: $isLoadingTip,
                selectedTab: $selectedTab,
                hasGenerated: $hasGenerated
            )
        } else {
            aiUnavailableCard
        }
    }

    private var aiUnavailableCard: some View {
        VStack(spacing: 16) {
            headerRow

            VStack(spacing: 12) {
                Image(systemName: "apple.intelligence")
                    .font(.system(size: 28))
                    .foregroundStyle(MVMTheme.tertiaryText)

                Text("Requires iOS 26")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.secondaryText)

                Text(AIFeatureCheck.requirementsDescription)
                    .font(.caption)
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(MVMTheme.card)
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#6366F1").opacity(0.04), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(hex: "#6366F1").opacity(0.12))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var headerRow: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#6366F1").opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: "apple.intelligence")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(hex: "#6366F1"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("AI Insights")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Powered by Apple Intelligence")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            Spacer()
        }
    }
}

@available(iOS 26.0, *)
struct AIInsightsCardContent: View {
    let vm: AppViewModel
    @Binding var progressInsight: String
    @Binding var weeklySummary: String
    @Binding var coachingTip: String
    @Binding var isLoadingInsight: Bool
    @Binding var isLoadingSummary: Bool
    @Binding var isLoadingTip: Bool
    @Binding var selectedTab: AIInsightsCard.AIInsightTab
    @Binding var hasGenerated: Bool

    @State private var aiService = AppleIntelligenceService()

    var body: some View {
        VStack(spacing: 16) {
            headerRow

            if !aiService.isAvailable {
                unavailableStatusView
            } else if !hasGenerated {
                generatePrompt
            } else {
                tabSelector
                contentArea
            }
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(MVMTheme.card)
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#6366F1").opacity(0.04), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color(hex: "#6366F1").opacity(0.12))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
    }

    private var headerRow: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#6366F1").opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: "apple.intelligence")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(hex: "#6366F1"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("AI Insights")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Powered by Apple Intelligence")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            Spacer()

            if hasGenerated {
                Button {
                    Task { await generateAll() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(hex: "#6366F1"))
                        .frame(width: 30, height: 30)
                        .background(Color(hex: "#6366F1").opacity(0.12))
                        .clipShape(Circle())
                }
                .disabled(aiService.isGenerating)
            }
        }
    }

    private var unavailableStatusView: some View {
        VStack(spacing: 12) {
            let status = aiService.availabilityStatus
            let (icon, message) = statusInfo(status)

            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(MVMTheme.tertiaryText)

            Text(message)
                .font(.caption)
                .foregroundStyle(MVMTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func statusInfo(_ status: AIAvailabilityStatus) -> (String, String) {
        switch status {
        case .notEnabled:
            return ("gearshape", "Enable Apple Intelligence in Settings > Apple Intelligence & Siri to use AI insights.")
        case .notReady:
            return ("arrow.down.circle", "Apple Intelligence model is downloading. This may take a few minutes.")
        case .deviceNotEligible:
            return ("iphone.slash", "This device doesn't support Apple Intelligence. Requires iPhone 15 Pro or later.")
        default:
            return ("exclamationmark.triangle", AIFeatureCheck.requirementsDescription)
        }
    }

    private var generatePrompt: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundStyle(Color(hex: "#6366F1"))
                .symbolEffect(.pulse, options: .repeating.speed(0.5))

            Text("Analyze your training data with on-device AI")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                Task { await generateAll() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "apple.intelligence")
                        .font(.subheadline.weight(.bold))
                    Text("Generate Insights")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(.rect(cornerRadius: 12))
            }
            .buttonStyle(PressScaleButtonStyle())

            Text("All processing happens on-device. Your data never leaves your phone.")
                .font(.system(size: 10))
                .foregroundStyle(MVMTheme.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 4)
    }

    private var tabSelector: some View {
        HStack(spacing: 4) {
            ForEach(AIInsightsCard.AIInsightTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(selectedTab == tab ? .white : MVMTheme.secondaryText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(selectedTab == tab ? Color(hex: "#6366F1") : MVMTheme.cardSoft)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var contentArea: some View {
        let isLoading: Bool
        let text: String
        let icon: String
        let label: String

        switch selectedTab {
        case .insight:
            let _ = (isLoading = isLoadingInsight, text = progressInsight, icon = "chart.line.uptrend.xyaxis", label = "Progress Analysis")
        case .summary:
            let _ = (isLoading = isLoadingSummary, text = weeklySummary, icon = "doc.text", label = "Weekly After-Action")
        case .tip:
            let _ = (isLoading = isLoadingTip, text = coachingTip, icon = "lightbulb.fill", label = "Coaching Tip")
        }

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(hex: "#6366F1"))
                Text(label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            if isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(Color(hex: "#6366F1"))
                    Text("Analyzing...")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
            } else if text.isEmpty {
                Text("Tap Generate Insights to start.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .padding(.vertical, 8)
            } else {
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MVMTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 14))
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }

    private func generateAll() async {
        hasGenerated = true

        isLoadingInsight = true
        isLoadingSummary = true
        isLoadingTip = true

        async let insight = aiService.generateProgressInsight(
            aftScores: vm.aftScores,
            completedRecords: vm.completedRecords,
            streak: vm.streak,
            weeklyStepAverage: vm.weeklyStepAverage,
            currentPlan: vm.currentPlan
        )

        progressInsight = await insight
        isLoadingInsight = false

        weeklySummary = await aiService.generateWeeklySummary(
            completedRecords: vm.completedRecords,
            aftScores: vm.aftScores,
            streak: vm.streak,
            stepsThisWeek: vm.weeklyStepAverage * 7
        )
        isLoadingSummary = false

        coachingTip = await aiService.generateAdaptiveCoachingTip(
            recentWorkouts: Array(vm.completedRecords.prefix(5)),
            weakEvents: vm.aftWeakestEvents,
            currentFocus: vm.currentFocus.rawValue
        )
        isLoadingTip = false
    }
}
