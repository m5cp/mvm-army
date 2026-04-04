import SwiftUI

struct CompetitorComparisonView: View {
    @State private var animateRows: Bool = false
    @State private var animateLifetime: Bool = false
    @State private var pulseGlow: Bool = false

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
                VStack(spacing: 28) {
                    headerSection
                    lifetimeDealCard
                    allPlansSection
                    longTermSavingsTable
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
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4)) {
                animateLifetime = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.6)) {
                pulseGlow = true
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

    // MARK: - Lifetime Deal Card

    private var lifetimeDealCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.caption2.weight(.bold))
                Text("LIMITED TIME LAUNCH OFFER")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.2)
            }
            .foregroundStyle(Color(hex: "#0C0F0E"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(MVMTheme.heroAmber)

            VStack(spacing: 18) {
                VStack(spacing: 6) {
                    Text("Founding Member")
                        .font(.caption.weight(.bold))
                        .tracking(1.0)
                        .foregroundStyle(MVMTheme.heroAmber)

                    Text("Lifetime Access")
                        .font(.title.weight(.heavy))
                        .foregroundStyle(.white)
                }

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("$49")
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text(".99")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }

                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Text("$99.99")
                            .font(.subheadline.weight(.bold))
                            .strikethrough(color: .white.opacity(0.5))
                            .foregroundStyle(.white.opacity(0.4))

                        Text("50% OFF")
                            .font(.caption2.weight(.heavy))
                            .tracking(0.5)
                            .foregroundStyle(Color(hex: "#0C0F0E"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(MVMTheme.heroAmber)
                            .clipShape(Capsule())
                    }

                    Text("One payment. Yours forever.")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Divider().overlay(.white.opacity(0.1))
                    .padding(.horizontal, 8)

                VStack(spacing: 10) {
                    lifetimePerk(icon: "infinity", text: "Every feature, every update — forever")
                    lifetimePerk(icon: "lock.open.fill", text: "No recurring charges, no surprises")
                    lifetimePerk(icon: "chart.line.uptrend.xyaxis", text: "Pays for itself in under 13 months vs annual")
                    lifetimePerk(icon: "shield.checkered", text: "Lock in before price goes to $99.99")
                }

                VStack(spacing: 4) {
                    Text("Half the cost of one year at the leading fitness tracker")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(MVMTheme.success)

                    Text("Career soldiers save hundreds over a 20-year service")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .multilineTextAlignment(.center)
                .padding(.top, 2)
            }
            .padding(22)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#1A1A2E"),
                                    Color(hex: "#16213E"),
                                    Color(hex: "#0F3460").opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 0)
                        .fill(MVMTheme.subtleGradient)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    LinearGradient(
                        colors: [
                            MVMTheme.heroAmber.opacity(pulseGlow ? 0.6 : 0.3),
                            MVMTheme.heroAmber.opacity(pulseGlow ? 0.3 : 0.1),
                            MVMTheme.heroAmber.opacity(pulseGlow ? 0.6 : 0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
        .shadow(color: MVMTheme.heroAmber.opacity(pulseGlow ? 0.2 : 0.08), radius: 24, y: 12)
        .opacity(animateLifetime ? 1 : 0)
        .offset(y: animateLifetime ? 0 : 16)
    }

    private func lifetimePerk(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.heroAmber)
                .frame(width: 20)

            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.75))

            Spacer(minLength: 0)
        }
    }

    // MARK: - All Plans

    private var allPlansSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "creditcard")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Text("ALL PLANS")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)

            HStack(spacing: 10) {
                planTile(
                    label: "Monthly",
                    price: "$3.99",
                    period: "/mo",
                    detail: "Cancel anytime",
                    highlight: false
                )

                planTile(
                    label: "Annual",
                    price: "$19.99",
                    period: "/yr",
                    detail: "$1.67/mo · Save 65%",
                    highlight: false
                )

                planTile(
                    label: "Lifetime",
                    price: "$49.99",
                    period: "",
                    detail: "Launch price",
                    highlight: true
                )
            }
        }
    }

    private func planTile(label: String, price: String, period: String, detail: String, highlight: Bool) -> some View {
        VStack(spacing: 8) {
            if highlight {
                Text("BEST VALUE")
                    .font(.system(size: 8, weight: .heavy))
                    .tracking(0.5)
                    .foregroundStyle(Color(hex: "#0C0F0E"))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(MVMTheme.heroAmber)
                    .clipShape(Capsule())
            } else {
                Color.clear.frame(height: 14)
            }

            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(highlight ? MVMTheme.heroAmber : MVMTheme.secondaryText)

            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(price)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                if !period.isEmpty {
                    Text(period)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            Text(detail)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(highlight ? MVMTheme.success : MVMTheme.tertiaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 4)
        .background(
            highlight ?
            Color(hex: "#1A1A2E") :
            MVMTheme.card
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    highlight ? MVMTheme.heroAmber.opacity(0.4) : MVMTheme.border,
                    lineWidth: highlight ? 1.5 : 1
                )
        }
    }

    // MARK: - Long Term Savings

    private var longTermSavingsTable: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Text("LONG-TERM VALUE")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("Plan")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Year 1")
                        .frame(width: 60, alignment: .trailing)
                    Text("Year 3")
                        .frame(width: 60, alignment: .trailing)
                    Text("Year 5")
                        .frame(width: 60, alignment: .trailing)
                }
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

                Divider().overlay(MVMTheme.border)

                savingsTableRow(
                    label: "Monthly",
                    values: ["$47.88", "$143.64", "$239.40"],
                    isHighlight: false,
                    index: 0
                )

                Divider().overlay(MVMTheme.border)

                savingsTableRow(
                    label: "Annual",
                    values: ["$19.99", "$59.97", "$99.95"],
                    isHighlight: false,
                    index: 1
                )

                Divider().overlay(MVMTheme.border)

                savingsTableRow(
                    label: "Lifetime",
                    values: ["$49.99", "$49.99", "$49.99"],
                    isHighlight: true,
                    index: 2
                )
            }
            .background(MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(MVMTheme.border)
            }

            HStack(spacing: 16) {
                savingsBadge(label: "Year 3", saved: "$10", vs: "vs Annual")
                savingsBadge(label: "Year 5", saved: "$50", vs: "vs Annual")
                savingsBadge(label: "Year 5", saved: "$189", vs: "vs Monthly")
            }
        }
    }

    private func savingsTableRow(label: String, values: [String], isHighlight: Bool, index: Int) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 6) {
                if isHighlight {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(MVMTheme.heroAmber)
                }
                Text(label)
                    .font(.caption.weight(isHighlight ? .bold : .semibold))
                    .foregroundStyle(isHighlight ? MVMTheme.heroAmber : MVMTheme.primaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                Text(value)
                    .font(.system(size: 12, weight: isHighlight ? .heavy : .semibold, design: .rounded))
                    .foregroundStyle(isHighlight ? MVMTheme.success : MVMTheme.secondaryText)
                    .frame(width: 60, alignment: .trailing)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(isHighlight ? MVMTheme.success.opacity(0.04) : Color.clear)
        .opacity(animateRows ? 1 : 0)
        .offset(y: animateRows ? 0 : 6)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.06 + 0.3),
            value: animateRows
        )
    }

    private func savingsBadge(label: String, saved: String, vs: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(MVMTheme.tertiaryText)

            Text("Save \(saved)")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(MVMTheme.success)

            Text(vs)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(MVMTheme.success.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(MVMTheme.success.opacity(0.12))
        }
    }

    // MARK: - Competitor Pricing Cards

    private var pricingCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "dollarsign.circle")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Text("VS THE COMPETITION")
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
                    multiplier: "4\u{00D7}"
                )
                competitorPriceCard(
                    name: "Leading\nWorkout Logger",
                    monthly: "$4.99",
                    yearly: "$29.99/yr",
                    multiplier: "1.3\u{00D7}"
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
        VStack(spacing: 14) {
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

            Divider().overlay(.white.opacity(0.1))

            HStack(spacing: 10) {
                Image(systemName: "crown.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.heroAmber)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Lifetime: $49.99")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)

                        Text("$99.99")
                            .font(.caption2.weight(.medium))
                            .strikethrough(color: .white.opacity(0.4))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    Text("Launch price · One-time payment")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer(minLength: 0)

                Text("50% OFF")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(Color(hex: "#0C0F0E"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(MVMTheme.heroAmber)
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

            Divider().overlay(MVMTheme.border)

            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.heroAmber)
                    Text("LIFETIME DEAL")
                        .font(.caption.weight(.heavy))
                        .tracking(1.0)
                        .foregroundStyle(MVMTheme.heroAmber)
                }

                Text("Get lifetime access at the launch price of $49.99 — that's less than one year of the leading fitness tracker. Future price: $99.99.")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

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
