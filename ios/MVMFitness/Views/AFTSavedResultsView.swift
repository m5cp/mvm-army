import SwiftUI

struct AFTSavedResultsView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var exportResult: AFTCalculatorResult?
    @State private var showExportSheet = false

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            if vm.aftCalculatorResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 48))
                        .foregroundStyle(MVMTheme.tertiaryText)

                    Text("No Saved Results")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)

                    Text("Calculate an AFT score and save it to see your history here.")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(vm.aftCalculatorResults) { result in
                            resultCard(result)
                                .contextMenu {
                                    Button {
                                        exportResult = result
                                        showExportSheet = true
                                    } label: {
                                        Label("Export DA Form 705", systemImage: "doc.text.fill")
                                    }
                                }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
            }
        }
        .navigationTitle("AFT History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showExportSheet) {
            if let result = exportResult {
                DAForm705ExportView(result: result)
            } else {
                NavigationStack {
                    UnavailableFallbackView(title: "Export Unavailable", message: "Unable to load the selected result for export.", action: "Dismiss") {
                        showExportSheet = false
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showExportSheet = false }
                                .foregroundStyle(MVMTheme.primaryText)
                        }
                    }
                    .toolbarBackground(MVMTheme.background, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                }
            }
        }
    }

    private func resultCard(_ result: AFTCalculatorResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if !result.soldierName.isEmpty {
                        Text(result.soldierName)
                            .font(.headline)
                            .foregroundStyle(MVMTheme.primaryText)
                    }

                    Text(result.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(result.totalScore)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(MVMTheme.primaryText)

                    HStack(spacing: 4) {
                        Image(systemName: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.caption)
                        Text(result.passed ? "PASS" : "NO GO")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(result.passed ? MVMTheme.success : MVMTheme.danger)
                }
            }

            HStack(spacing: 6) {
                infoPill(result.sex.rawValue)
                infoPill("Age \(result.age)")
                infoPill(result.standard.rawValue)
            }

            HStack(spacing: 6) {
                miniPill("MDL", result.deadliftPoints)
                miniPill("HRP", result.pushUpPoints)
                miniPill("SDC", result.sdcPoints)
                miniPill("PLK", result.plankPoints)
                miniPill("2MR", result.runPoints)
            }

            if !result.weakestEvents.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.warning)
                    Text("Focus: \(result.weakestEvents.joined(separator: ", "))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.warning)
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    private func infoPill(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(MVMTheme.secondaryText)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(MVMTheme.cardSoft)
            .clipShape(Capsule())
    }

    private func miniPill(_ label: String, _ value: Int) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.secondaryText)
            Text("\(value)")
                .font(.caption.weight(.bold))
                .foregroundStyle(pillColor(value))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func pillColor(_ value: Int) -> Color {
        if value >= 80 { return MVMTheme.success }
        if value >= 60 { return MVMTheme.accent }
        if value >= 40 { return MVMTheme.warning }
        return MVMTheme.danger
    }
}
