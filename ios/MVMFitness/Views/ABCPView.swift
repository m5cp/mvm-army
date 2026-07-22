import SwiftUI

struct ABCPView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    @State private var store = ABCPStore()
    @State private var waistText: String = ""
    @State private var heightText: String = ""
    @State private var showInfo = false
    @FocusState private var focused: Bool

    private var waist: Double? { Double(waistText) }
    private var height: Double? { Double(heightText) }

    private var previewRatio: Double? {
        guard let w = waist, let h = height, h > 0, w > 0 else { return nil }
        return w / h
    }

    /// AD 2025-17: AFT total of 465+ exempts from body composition standards.
    private var aftExemptionScore: Int? {
        guard let latest = vm.aftScores.first, latest.totalScore >= 465 else { return nil }
        return latest.totalScore
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        if let score = aftExemptionScore {
                            exemptionBanner(score: score)
                        }
                        calculatorCard
                        if let ratio = previewRatio {
                            resultCard(ratio: ratio)
                        }
                        if !store.records.isEmpty {
                            historyCard
                        }
                        disclaimerFooter
                    }
                    .padding(20)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Body Composition (ABCP)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }.foregroundStyle(MVMTheme.accent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showInfo = true } label: {
                        Image(systemName: "info.circle").foregroundStyle(MVMTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showInfo) { ABCPInfoSheet() }
        }
        .preferredColorScheme(.dark)
    }

    private func exemptionBanner(score: Int) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title3)
                .foregroundStyle(MVMTheme.success)
            VStack(alignment: .leading, spacing: 3) {
                Text("Exempt from body composition standards")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                Text("Your latest AFT score (\(score)) is 465 or higher — per Army Directive 2025-17, you are exempt.")
                    .font(.footnote)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.success.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(MVMTheme.success.opacity(0.3), lineWidth: 1))
    }

    private var calculatorCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Waist-to-Height Ratio (WHtR)")
                .font(.headline)
                .foregroundStyle(MVMTheme.primaryText)

            Text("Measure waist at the navel. Enter both values in inches.")
                .font(.footnote)
                .foregroundStyle(MVMTheme.secondaryText)

            HStack(spacing: 12) {
                labeledField(title: "Waist (in)", text: $waistText)
                labeledField(title: "Height (in)", text: $heightText)
            }

            Button {
                if let w = waist, let h = height, h > 0, w > 0 {
                    store.add(waistInches: w, heightInches: h)
                    focused = false
                    AnalyticsService.track(.whtrRecorded)
                }
            } label: {
                Text("Save Screening")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(previewRatio == nil)
            .opacity(previewRatio == nil ? 0.5 : 1)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(MVMTheme.border))
    }

    private func labeledField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)
            TextField("0.0", text: text)
                .keyboardType(.decimalPad)
                .focused($focused)
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.cardSoft))
        }
    }

    private func resultCard(ratio: Double) -> some View {
        let meets = ratio < 0.55
        return VStack(spacing: 8) {
            Text(String(format: "%.2f", ratio))
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundStyle(meets ? MVMTheme.success : MVMTheme.danger)
                .contentTransition(.numericText())
            Text(meets ? "MEETS STANDARD" : "DOES NOT MEET STANDARD")
                .font(.caption.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(meets ? MVMTheme.success : MVMTheme.danger)
            Text("Standard: WHtR less than 0.55")
                .font(.caption2)
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke((meets ? MVMTheme.success : MVMTheme.danger).opacity(0.35)))
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Screening History")
                .font(.headline)
                .foregroundStyle(MVMTheme.primaryText)

            ForEach(store.records) { record in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.displayRatio)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(record.meetsStandard ? MVMTheme.success : MVMTheme.danger)
                        Text(record.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                    Spacer()
                    Text(record.meetsStandard ? "MEETS" : "DOES NOT MEET")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(record.meetsStandard ? MVMTheme.success : MVMTheme.danger)
                }
                .padding(.vertical, 6)
                .swipeActions { Button("Delete", role: .destructive) { store.delete(record) } }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(MVMTheme.border))
    }

    private var disclaimerFooter: some View {
        Text(LegalText.full)
            .font(.caption2)
            .foregroundStyle(MVMTheme.tertiaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }
}

struct ABCPInfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        infoBlock("The Standard", "Per Army Directive 2026-06 (effective July 7, 2026), WHtR is the Army's sole body composition assessment. A WHtR of less than — but not equal to — 0.55 meets the standard. Waist is measured at the navel in inches and divided by height in inches.")
                        infoBlock("Screening", "All Soldiers are screened twice a year. Results are recorded on DA 5500 and in ATIS.")
                        infoBlock("Second Check", "A WHtR of 0.55 or higher requires a second measurement by a different team on the same duty day before any administrative action.")
                        infoBlock("AFT Exemption", "Per Army Directive 2025-17, Soldiers who score 465 or more on the AFT are exempt from body fat standards.")
                        infoBlock("180-Day Review", "The Army is conducting a 180-day review of the WHtR standard. No separations for WHtR failure will occur until the review is complete.")
                        Text(LegalText.full)
                            .font(.caption2)
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("About the ABCP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func infoBlock(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline).foregroundStyle(MVMTheme.primaryText)
            Text(body).font(.subheadline).foregroundStyle(MVMTheme.secondaryText)
        }
    }
}
