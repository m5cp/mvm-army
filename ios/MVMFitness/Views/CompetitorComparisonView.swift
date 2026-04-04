import SwiftUI

struct CompetitorComparisonView: View {
    @State private var animateRows: Bool = false
    @State private var selectedTab: Int = 0

    private let competitors: [Competitor] = [
        Competitor(
            name: "MVM Fitness",
            isMVM: true,
            monthlyPrice: "$3.99",
            yearlyPrice: "$19.99",
            yearlyMonthly: "$1.67",
            features: [true, true, true, true, true, true, true, true, true, true]
        ),
        Competitor(
            name: "Leading Fitness Tracker",
            isMVM: false,
            monthlyPrice: "$15.99",
            yearlyPrice: "$95.99",
            yearlyMonthly: "$8.00",
            features: [false, false, false, true, false, false, false, false, true, false]
        ),
        Competitor(
            name: "Leading Workout Logger",
            isMVM: false,
            monthlyPrice: "$4.99",
            yearlyPrice: "$29.99",
            yearlyMonthly: "$2.50",
            features: [false, false, false, true, false, false, false, false, false, false]
        ),
        Competitor(
            name: "Leading Military App",
            isMVM: false,
            monthlyPrice: "Free*",
            yearlyPrice: "$9.99+",
            yearlyMonthly: "per plan",
            features: [true, false, false, false, false, false, false, true, false, false]
        )
    ]

    private let featureNames: [(String, String)] = [
        ("shield.checkered", "AFT Score Calculator"),
        ("figure.strengthtraining.traditional", "Military-Specific Workouts"),
        ("person.3.fill", "Unit PT Builder"),
        ("list.clipboard", "Full Workout Logging"),
        ("waveform.badge.mic", "Siri Voice Logging"),
        ("brain.head.profile", "Apple Intelligence Insights"),
        ("flame.fill", "Functional Fitness Library"),
        ("doc.text.fill", "DA Form 705 Export"),
        ("chart.xyaxis.line", "Progress Analytics"),
        ("calendar.badge.clock", "Weekly Plan Generator")
    ]

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    pricingCards
                    featureMatrix
                    bottomLine
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
                animateRows = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "medal.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(MVMTheme.heroAmber)
                Text("WHY MVM?")
                    .font(.caption.weight(.heavy))
                    .tracking(2.0)
                    .foregroundStyle(MVMTheme.heroAmber)
            }

            Text("Built for Soldiers.\nPriced for Soldiers.")
                .font(.title2.weight(.heavy))
                .foregroundStyle(MVMTheme.primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Text("See how MVM Fitness stacks up against the leading fitness apps.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 12)
    }

    // MARK: - Pricing Cards

    private var pricingCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "dollarsign.circle")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Text("MONTHLY COST")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)

            mvmPriceCard

            HStack(spacing: 10) {
                competitorPriceCard(
                    name: "Leading\nFitness Tracker",
                    monthly: "$15.99",
                    yearly: "$95.99/yr",
                    multiplier: "4×"
                )
                competitorPriceCard(
                    name: "Leading\nWorkout Logger",
                    monthly: "$4.99",
                    yearly: "$29.99/yr",
                    multiplier: "1.3×"
                )
                competitorPriceCard(
                    name: "Leading\nMilitary App",
                    monthly: "Free*",
                    yearly: "$9.99+/plan",
                    multiplier: nil
                )
            }

            Text("*Free base with individual paid workout plans")
                .font(.system(size: 10))
                .foregroundStyle(MVMTheme.tertiaryText)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 4)
        }
    }

    private var mvmPriceCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.fill")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text("MVM FITNESS")
                        .font(.caption.weight(.heavy))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.9))
                }

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$3.99")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("/mo")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 4) {
                Text("or")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$19.99")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Text("/yr")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Text("$1.67/mo")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MVMTheme.success)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(MVMTheme.success.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(18)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#1B5E3B"), Color(hex: "#2E7D52").opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 20)
                    .fill(MVMTheme.subtleGradient)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: MVMTheme.accent.opacity(0.25), radius: 16, y: 8)
    }

    private func competitorPriceCard(name: String, monthly: String, yearly: String, multiplier: String?) -> some View {
        VStack(spacing: 8) {
            Text(name)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 28)

            Text(monthly)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(MVMTheme.primaryText)

            Text(yearly)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(MVMTheme.tertiaryText)

            if let mult = multiplier {
                Text("\(mult) more")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(MVMTheme.danger.opacity(0.9))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(MVMTheme.danger.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(MVMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(MVMTheme.border)
        }
    }

    // MARK: - Feature Matrix

    private var featureMatrix: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Text("FEATURE BREAKDOWN")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)

            VStack(spacing: 0) {
                matrixHeader
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)

                ForEach(Array(featureNames.enumerated()), id: \.offset) { index, feature in
                    if index > 0 {
                        Divider().overlay(MVMTheme.border)
                    }
                    featureRow(
                        icon: feature.0,
                        name: feature.1,
                        values: competitors.map { $0.features[index] },
                        index: index
                    )
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
            }
            .background(MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(MVMTheme.border)
            }
        }
    }

    private var matrixHeader: some View {
        HStack(spacing: 0) {
            Text("Feature")
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.tertiaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                columnLabel("MVM", highlight: true)
                columnLabel("Tracker", highlight: false)
                columnLabel("Logger", highlight: false)
                columnLabel("Military", highlight: false)
            }
            .frame(width: 160)
        }
    }

    private func columnLabel(_ text: String, highlight: Bool) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(highlight ? MVMTheme.accent : MVMTheme.tertiaryText)
            .frame(width: 40)
    }

    private func featureRow(icon: String, name: String, values: [Bool], index: Int) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 16)

                Text(name)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                ForEach(Array(values.enumerated()), id: \.offset) { colIdx, hasFeature in
                    ZStack {
                        if hasFeature {
                            if colIdx == 0 {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(MVMTheme.success)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(MVMTheme.secondaryText)
                            }
                        } else {
                            Image(systemName: "minus")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(MVMTheme.tertiaryText.opacity(0.4))
                        }
                    }
                    .frame(width: 40)
                }
            }
            .frame(width: 160)
        }
        .opacity(animateRows ? 1 : 0)
        .offset(y: animateRows ? 0 : 8)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.04),
            value: animateRows
        )
    }

    // MARK: - Bottom Line

    private var bottomLine: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.shield.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.accent)
                    Text("THE BOTTOM LINE")
                        .font(.caption.weight(.heavy))
                        .tracking(1.2)
                        .foregroundStyle(MVMTheme.accent)
                }

                Text("Save up to $76/year while getting the only app purpose-built for Army fitness — AFT calculator, unit PT planner, Siri logging, and more.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            savingsRow("vs Leading Fitness Tracker", saved: "$76/yr", icon: "arrow.down.circle.fill")
            savingsRow("vs Leading Workout Logger", saved: "$10/yr", icon: "arrow.down.circle.fill")

            Text("Plus features no competitor offers — Unit PT Builder, DA Form 705 export, Siri integration, and Apple Intelligence insights.")
                .font(.caption)
                .foregroundStyle(MVMTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.top, 4)
        }
        .padding(20)
        .background(MVMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(MVMTheme.border)
        }
    }

    private func savingsRow(_ label: String, saved: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(MVMTheme.success)

            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(MVMTheme.secondaryText)

            Spacer(minLength: 0)

            Text("Save \(saved)")
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.success)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(MVMTheme.success.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

nonisolated struct Competitor: Sendable {
    let name: String
    let isMVM: Bool
    let monthlyPrice: String
    let yearlyPrice: String
    let yearlyMonthly: String
    let features: [Bool]
}
