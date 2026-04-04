import SwiftUI
import RevenueCat

struct UpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreViewModel.self) private var store

    @State private var selectedPackageID: String?
    @State private var animateIn: Bool = false

    private let features: [(icon: String, title: String, description: String)] = [
        ("bolt.shield.fill", "Advanced PT Plans", "Multi-week periodized training plans"),
        ("chart.line.uptrend.xyaxis", "AI Insights & Analytics", "Performance analysis and smart recommendations"),
        ("person.3.fill", "Unit PT Builder", "Full unit PT plans with TCS and leader notes"),
        ("doc.text.fill", "PDF & Calendar Export", "Export plans as PDFs and sync to calendar"),
        ("square.and.arrow.up.fill", "Share Cards & QR", "Custom share cards with photo overlays"),
        ("star.fill", "Priority Support", "Early access to new features and updates")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        featuresSection
                        packagesSection
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
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [MVMTheme.accent, MVMTheme.accent2],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: MVMTheme.accent.opacity(0.35), radius: 16, y: 6)

                Image(systemName: "crown.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(animateIn ? 1 : 0.6)
            .opacity(animateIn ? 1 : 0)

            VStack(spacing: 6) {
                Text("Unlock MVM Pro")
                    .font(.title.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Train smarter. Perform better.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(MVMTheme.secondaryText)
            }
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 10)

            HStack(spacing: 6) {
                Image(systemName: "tag.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(hex: "#F59E0B"))
                Text("LIMITED TIME LAUNCH PRICE")
                    .font(.caption2.weight(.heavy))
                    .tracking(0.8)
                    .foregroundStyle(Color(hex: "#F59E0B"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Color(hex: "#F59E0B").opacity(0.12))
            .clipShape(Capsule())
            .opacity(animateIn ? 1 : 0)
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: 8) {
            ForEach(Array(features.enumerated()), id: \.element.title) { index, feature in
                HStack(spacing: 14) {
                    Image(systemName: feature.icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                        .frame(width: 36, height: 36)
                        .background(MVMTheme.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text(feature.description)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.accent)
                }
                .padding(12)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 8)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05 + 0.15),
                    value: animateIn
                )
            }
        }
        .padding(4)
        .premiumCard()
    }

    // MARK: - Packages

    private var packagesSection: some View {
        VStack(spacing: 12) {
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
                ForEach(current.availablePackages, id: \.identifier) { package in
                    packageCard(package)
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
                        Text("Continue")
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
        .offset(y: animateIn ? 0 : 12)
        .animation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.4), value: animateIn)
    }

    private func packageCard(_ package: Package) -> some View {
        let isSelected = selectedPackageID == package.identifier || (selectedPackageID == nil && package.packageType == .lifetime)
        let isLifetime = package.packageType == .lifetime

        return Button {
            selectedPackageID = package.identifier
        } label: {
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(package.storeProduct.localizedTitle)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(MVMTheme.primaryText)

                            if isLifetime {
                                Text("BEST VALUE")
                                    .font(.system(size: 9, weight: .heavy))
                                    .tracking(0.5)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(Capsule())
                            }
                        }

                        if !package.storeProduct.localizedDescription.isEmpty {
                            Text(package.storeProduct.localizedDescription)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                                .lineLimit(2)
                        }
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(package.storeProduct.localizedPriceString)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(isSelected ? MVMTheme.accent : MVMTheme.primaryText)

                        if isLifetime {
                            Text("one time")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                        } else if package.packageType == .annual {
                            Text("per year")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                        } else if package.packageType == .monthly {
                            Text("per month")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }
                    }
                }

                if let intro = package.storeProduct.introductoryDiscount {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.caption2)
                        Text("Free trial: \(intro.subscriptionPeriod.value) \(intro.subscriptionPeriod.unit == .day ? "days" : intro.subscriptionPeriod.unit == .week ? "weeks" : "months")")
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                }
            }
            .padding(16)
            .background(isSelected ? MVMTheme.accent.opacity(0.08) : MVMTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? MVMTheme.accent.opacity(0.5) : MVMTheme.border, lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
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

            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Manage subscriptions in Settings.")
                .font(.system(size: 9))
                .foregroundStyle(MVMTheme.tertiaryText.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .opacity(animateIn ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.5), value: animateIn)
    }
}
