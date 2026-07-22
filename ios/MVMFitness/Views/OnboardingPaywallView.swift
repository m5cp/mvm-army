import SwiftUI
import RevenueCat

/// Onboarding step 5 — soft paywall shown after the plan is generated.
/// "Continue with Free" is always visible. No hardcoded prices/trials —
/// everything is sourced from StoreKit/RevenueCat at runtime.
struct OnboardingPaywallView: View {
    @Environment(StoreViewModel.self) private var store
    let onContinue: () -> Void

    @State private var selectedPackageID: String?

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(MVMTheme.success)
                Text("Your Week 1 Plan Is Ready")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                Text("Unlock the full multi-week program, Unit PT Builder, and PDF exports with MVM Pro.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            if store.isLoading {
                ProgressView().tint(MVMTheme.accent).frame(height: 100)
            } else if let current = store.offerings?.current {
                VStack(spacing: 10) {
                    ForEach(current.availablePackages.filter { $0.packageType == .annual || $0.packageType == .monthly }, id: \.identifier) { package in
                        packageRow(package)
                    }
                }
            }

            if let current = store.offerings?.current, let selected = selectedPackage(from: current) {
                Button {
                    AnalyticsService.track(.paywallPurchaseStarted)
                    Task { await store.purchase(package: selected) }
                } label: {
                    HStack {
                        if store.isPurchasing { ProgressView().tint(.white) }
                        Text(trialCTA(for: selected))
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(store.isPurchasing)
            }

            Button("Continue with Free") {
                AnalyticsService.track(.paywallContinuedFree)
                onContinue()
            }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)
                .padding(.top, 2)
        }
        .padding(.horizontal, 4)
        .onChange(of: store.isPremium) { _, isPremium in
            if isPremium { onContinue() }
        }
        .task {
            if store.offerings == nil { await store.fetchOfferings() }
            AnalyticsService.track(.paywallViewed)
        }
    }

    /// Trial wording is derived ONLY from the StoreKit intro offer (configured in App Store Connect).
    private func trialCTA(for package: Package) -> String {
        if let intro = package.storeProduct.introductoryDiscount, intro.price == 0 {
            let unit = intro.subscriptionPeriod.unit
            let unitName = unit == .day ? "Day" : unit == .week ? "Week" : "Month"
            let value = intro.subscriptionPeriod.value
            return "Start \(value)-\(unitName) Free Trial"
        }
        return "Continue"
    }

    private func packageRow(_ package: Package) -> some View {
        let isSelected = selectedPackageID == package.identifier
            || (selectedPackageID == nil && package.packageType == .annual)
        return Button {
            selectedPackageID = package.identifier
        } label: {
            HStack {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(isSelected ? MVMTheme.accent : MVMTheme.tertiaryText)
                VStack(alignment: .leading, spacing: 2) {
                    Text(package.storeProduct.localizedTitle)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    if let intro = package.storeProduct.introductoryDiscount, intro.price == 0 {
                        Text("\(intro.subscriptionPeriod.value) \(intro.subscriptionPeriod.unit == .day ? "day" : intro.subscriptionPeriod.unit == .week ? "week" : "month") free trial")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(MVMTheme.success)
                    }
                }
                Spacer()
                Text(package.storeProduct.localizedPriceString)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(isSelected ? MVMTheme.accent : MVMTheme.primaryText)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(isSelected ? MVMTheme.accent.opacity(0.08) : MVMTheme.card))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(isSelected ? MVMTheme.accent.opacity(0.5) : MVMTheme.border))
        }
        .buttonStyle(.plain)
    }

    private func selectedPackage(from offering: Offering) -> Package? {
        if let id = selectedPackageID {
            return offering.availablePackages.first { $0.identifier == id }
        }
        return offering.availablePackages.first { $0.packageType == .annual }
            ?? offering.availablePackages.first
    }
}
