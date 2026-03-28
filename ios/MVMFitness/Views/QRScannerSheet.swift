import SwiftUI
import AVFoundation

struct QRScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var scannedPlan: UnitPTPlan?
    @State private var showImportedPlan = false
    @State private var errorMessage: String?
    @State private var manualJSON = ""
    @State private var showManualEntry = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        cameraSection
                        manualEntrySection

                        if let scannedPlan {
                            importedPlanCard(scannedPlan)
                        }

                        if let errorMessage {
                            errorCard(errorMessage)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Scan PT Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var cameraSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 20) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 48))
                    .foregroundStyle(MVMTheme.accent)

                Text("Scan QR Code")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Install this app on your device via the Rork App to use the camera for QR scanning.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(32)
            .premiumCard()
        }
    }

    private var manualEntrySection: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    showManualEntry.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "text.justify.left")
                    Text("Paste PT Plan Data")
                    Spacer()
                    Image(systemName: showManualEntry ? "chevron.up" : "chevron.down")
                }
                .font(.headline)
                .foregroundStyle(MVMTheme.primaryText)
                .padding(18)
                .premiumCardStyle()
            }
            .buttonStyle(.plain)

            if showManualEntry {
                VStack(spacing: 12) {
                    TextField("Paste JSON data here...", text: $manualJSON, axis: .vertical)
                        .font(.caption.monospaced())
                        .lineLimit(6...12)
                        .padding(12)
                        .background(MVMTheme.cardSoft)
                        .foregroundStyle(MVMTheme.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(MVMTheme.border)
                        }

                    Button {
                        parseJSON(manualJSON)
                    } label: {
                        Text("Import Plan")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(MVMTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
                .padding(18)
                .premiumCard()
            }
        }
    }

    private func importedPlanCard(_ plan: UnitPTPlan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(MVMTheme.success)
                Text("Imported PT Plan")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.success)
            }

            Text(plan.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text(plan.objective)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)

            Text("\(plan.mainEffort.count) blocks")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.accent)

            Button {
                vm.unitPTPlans.insert(plan, at: 0)
                vm.persistAll()
                dismiss()
            } label: {
                Text("Save to My Plans")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(18)
        .premiumCard()
    }

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(MVMTheme.warning)
                Text("Import Error")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }
            Text(message)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .padding(18)
        .premiumCard()
    }

    private func parseJSON(_ jsonString: String) {
        errorMessage = nil
        scannedPlan = nil

        guard let data = jsonString.data(using: .utf8) else {
            errorMessage = "Invalid text data."
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let plan = try decoder.decode(UnitPTPlan.self, from: data)
            scannedPlan = plan
        } catch {
            errorMessage = "Could not decode PT plan. Make sure the data is valid."
        }
    }
}
