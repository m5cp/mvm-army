import SwiftUI
import CoreImage.CIFilterBuiltins

struct UnitPTBuilderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var plan: UnitPTPlan?
    @State private var showQRSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        if plan == nil {
                            generateCard
                        }

                        if let plan {
                            unitPlanCard(plan)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Unit PT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showQRSheet) {
                if let plan {
                    QRDisplaySheet(plan: plan)
                }
            }
        }
    }

    private var generateCard: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "person.3.fill")
                        .foregroundStyle(MVMTheme.accent)
                    Text("Unit PT Builder")
                        .font(.headline)
                        .foregroundStyle(MVMTheme.primaryText)
                }

                Text("Generate a structured PT plan based on your training focus. Share it via QR code.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            Button {
                plan = vm.generateUnitPT()
            } label: {
                Text("Generate Unit PT Plan")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(18)
        .premiumCard()
    }

    private func unitPlanCard(_ plan: UnitPTPlan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(plan.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text(plan.date.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)

            labelValue("Objective", plan.objective)
            labelValue("Formation", plan.formationNotes)
            labelValue("Equipment", plan.equipment)
            labelValue("Warm-Up", plan.warmup)

            VStack(alignment: .leading, spacing: 6) {
                Text("Main Effort")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)

                ForEach(Array(plan.mainEffort.enumerated()), id: \.element.id) { index, block in
                    Text("\(index + 1). \(block.description)")
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(MVMTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            labelValue("Cool-Down", plan.cooldown)
            labelValue("Leader Notes", plan.leaderNotes)

            HStack(spacing: 12) {
                Button {
                    showQRSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "qrcode")
                        Text("Share QR")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())

                ShareLink(item: plan.shareText) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#2563EB"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            Button {
                self.plan = vm.generateUnitPT()
            } label: {
                Text("Regenerate")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(18)
        .premiumCard()
    }

    private func labelValue(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.headline)
                .foregroundStyle(MVMTheme.primaryText)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
        }
    }
}
