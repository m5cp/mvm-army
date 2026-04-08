import SwiftUI
import RevenueCat

struct UpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreViewModel.self) private var store

    @State private var selectedPackageID: String?
    @State private var animateIn: Bool = false
    @State private var pulseGlow: Bool = false

    private let proFeatures: [(icon: String, title: String)] = [
        ("bolt.shield.fill", "Advanced PT Plans"),
        ("chart.line.uptrend.xyaxis", "AI Insights & Analytics"),
        ("person.3.fill", "Unit PT Builder"),
        ("doc.text.fill", "PDF & Calendar Export"),
        ("square.and.arrow.up.fill", "Share Cards & QR"),
        ("star.fill", "Priority Support")
    ]

    private let freeFeatures: [(icon: String, title: String)] = [
        ("figure.run", "AFT Score Calculator"),
        ("bolt.fill", "Quick Start Activities"),
        ("dumbbell.fill", "Basic Workouts"),
        ("chart.bar.fill", "Step Tracking")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        headerSection
                        freeTierSection
                        subscriptionTiersSection
                        lifetimeDealSection
                        ctaButton
                        legalSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 48)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Error", isPresented: .init(
                get: { store.error != nil },
                set: { if !$0 { store.error = nil } }
            )) {
                Button("OK") { store.error = nil }
            } message: {
                Text(store.error ?? "")
            }
            .onChange(of: store.isPremium) { _, isPremium in
                if isPremium { dismiss() }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.1)) {
                    animateIn = true
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.6)) {
                    pulseGlow = true
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [MVMTheme.accent, MVMTheme.accent2],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 68, height: 68)
                    .shadow(color: MVMTheme.accent.opacity(0.35), radius: 16, y: 6)

                Image(systemName: "crown.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(animateIn ? 1 : 0.6)
            .opacity(animateIn ? 1 : 0)

            VStack(spacing: 6) {
                Text("Unlock MVM Pro")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Train smarter. Perform better.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.secondaryText)
            }
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 10)
        }
    }

    // MARK: - Free Tier

    private var freeTierSection: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Free")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Basic features included")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                Text("$0")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(MVMTheme.secondaryText)
            }
            .padding(16)

            Divider().overlay(MVMTheme.border)

            VStack(spacing: 8) {
                ForEach(freeFeatures, id: \.title) { feature in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(MVMTheme.tertiaryText)
                            .frame(width: 18)
                        Text(feature.title)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(MVMTheme.secondaryText)
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(16)
        }
        .background(MVMTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(MVMTheme.border)
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 8)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: animateIn)
    }

    // MARK: - Subscription Tiers

    private var subscriptionTiersSection: some View {
        VStack(spacing: 10) {
            if store.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(MVMTheme.accent)
                    Text("Loading plans...")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .frame(height: 120)
            } else if let current = store.offerings?.current {
                ForEach(sortedPackages(from: current), id: \.identifier) { package in
                    if package.packageType != .lifetime {
                        subscriptionCard(package)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                    Text("Unable to load subscription options")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                    Button("Retry") {
                        Task { await store.fetchOfferings() }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                }
                .frame(height: 120)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 10)
        .animation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.25), value: animateIn)
    }

    private func subscriptionCard(_ package: Package) -> some View {
        let isSelected = selectedPackageID == package.identifier
        let isAnnual = package.packageType == .annual

        return Button {
            selectedPackageID = package.identifier
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? MVMTheme.accent : MVMTheme.tertiaryText.opacity(0.4), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(MVMTheme.accent)
                            .frame(width: 14, height: 14)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(package.storeProduct.localizedTitle)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(MVMTheme.primaryText)

                        if isAnnual {
                            Text("POPULAR")
                                .font(.system(size: 9, weight: .heavy))
                                .tracking(0.5)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(MVMTheme.accent)
                                .clipShape(Capsule())
                        }
                    }

                    if let intro = package.storeProduct.introductoryDiscount {
                        HStack(spacing: 4) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 9))
                            Text("\(intro.subscriptionPeriod.value) \(intro.subscriptionPeriod.unit == .day ? "day" : intro.subscriptionPeriod.unit == .week ? "week" : "month") free trial")
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundStyle(MVMTheme.success)
                    } else if isAnnual {
                        Text("Save 58% vs monthly")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.success)
                    }
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(package.storeProduct.localizedPriceString)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(isSelected ? MVMTheme.accent : MVMTheme.primaryText)

                    Text(package.packageType == .annual ? "per year" : "per month")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
            }
            .padding(16)
            .background(isSelected ? MVMTheme.accent.opacity(0.06) : MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? MVMTheme.accent.opacity(0.5) : MVMTheme.border, lineWidth: isSelected ? 1.5 : 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Lifetime Deal

    private var lifetimeDealSection: some View {
        Group {
            if let current = store.offerings?.current,
               let lifetimePackage = current.availablePackages.first(where: { $0.packageType == .lifetime }) {
                let isSelected = selectedPackageID == lifetimePackage.identifier || (selectedPackageID == nil)

                Button {
                    selectedPackageID = lifetimePackage.identifier
                } label: {
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
                        .padding(.vertical, 9)
                        .frame(maxWidth: .infinity)
                        .background(MVMTheme.heroAmber)

                        VStack(spacing: 16) {
                            VStack(spacing: 5) {
                                Text("Founding Member")
                                    .font(.caption.weight(.bold))
                                    .tracking(1.0)
                                    .foregroundStyle(MVMTheme.heroAmber)

                                Text("Lifetime Access")
                                    .font(.title2.weight(.heavy))
                                    .foregroundStyle(.white)
                            }

                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text(lifetimePackage.storeProduct.localizedPriceString)
                                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.white)
                            }

                            VStack(spacing: 6) {
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

                            VStack(spacing: 9) {
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
                        }
                        .padding(20)
                        .background {
                            ZStack {
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#1A1A2E"),
                                        Color(hex: "#16213E"),
                                        Color(hex: "#0F3460").opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                MVMTheme.subtleGradient
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        MVMTheme.heroAmber.opacity(isSelected ? 0.8 : (pulseGlow ? 0.6 : 0.3)),
                                        MVMTheme.heroAmber.opacity(isSelected ? 0.5 : (pulseGlow ? 0.3 : 0.1)),
                                        MVMTheme.heroAmber.opacity(isSelected ? 0.8 : (pulseGlow ? 0.6 : 0.3))
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2 : 1.5
                            )
                    }
                    .shadow(color: MVMTheme.heroAmber.opacity(pulseGlow ? 0.2 : 0.08), radius: 24, y: 12)
                }
                .buttonStyle(.plain)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 16)
        .animation(.spring(response: 0.7, dampingFraction: 0.78).delay(0.35), value: animateIn)
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

    // MARK: - CTA

    private var ctaButton: some View {
        Group {
            if let current = store.offerings?.current, let selected = selectedPackage(from: current) {
                Button {
                    Task { await store.purchase(package: selected) }
                } label: {
                    HStack(spacing: 10) {
                        if store.isPurchasing {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "lock.open.fill")
                                .font(.subheadline.weight(.bold))
                        }
                        Text(selected.packageType == .lifetime ? "Get Lifetime Access" : "Continue")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: MVMTheme.accent.opacity(0.3), radius: 16, y: 8)
                }
                .disabled(store.isPurchasing)
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .opacity(animateIn ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.45), value: animateIn)
    }

    // MARK: - Helpers

    private func sortedPackages(from offering: Offering) -> [Package] {
        let order: [PackageType] = [.monthly, .annual, .lifetime]
        return offering.availablePackages.sorted { a, b in
            let aIdx = order.firstIndex(of: a.packageType) ?? 99
            let bIdx = order.firstIndex(of: b.packageType) ?? 99
            return aIdx < bIdx
        }
    }

    private func selectedPackage(from offering: Offering) -> Package? {
        if let id = selectedPackageID {
            return offering.availablePackages.first { $0.identifier == id }
        }
        return offering.availablePackages.first { $0.packageType == .lifetime } ?? offering.availablePackages.first
    }

    // MARK: - Legal

    private var legalSection: some View {
        VStack(spacing: 10) {
            Button("Restore Purchases") {
                Task { await store.restore() }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(MVMTheme.accent)

            HStack(spacing: 16) {
                NavigationLink {
                    LegalTextView(title: "Terms of Use", content: LegalContent.termsOfUse)
                } label: {
                    Text("Terms of Use")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .underline()
                }

                NavigationLink {
                    LegalTextView(title: "Privacy Policy", content: LegalContent.privacyPolicy)
                } label: {
                    Text("Privacy Policy")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .underline()
                }
            }

            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Manage subscriptions in Settings > Apple ID > Subscriptions.")
                .font(.system(size: 9))
                .foregroundStyle(MVMTheme.tertiaryText.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .opacity(animateIn ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.5), value: animateIn)
    }
}
