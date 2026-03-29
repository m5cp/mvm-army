import SwiftUI
import CoreImage.CIFilterBuiltins

struct UnitPTBuilderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var plan: UnitPTPlan?
    @State private var showQRSheet: Bool = false
    @State private var showDatePicker: Bool = false
    @State private var scheduledDate: Date = Calendar.current.startOfDay(for: .now)
    @State private var scheduledStartTime: Date = {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        comps.hour = 6
        comps.minute = 30
        return Calendar.current.date(from: comps) ?? .now
    }()
    @State private var scheduledEndTime: Date = {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        comps.hour = 7
        comps.minute = 30
        return Calendar.current.date(from: comps) ?? .now
    }()
    @State private var addedToCalendar: Bool = false

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

                            if !addedToCalendar {
                                addToCalendarCard(plan)
                            } else {
                                addedConfirmation
                            }
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
                addedToCalendar = false
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

    private func addToCalendarCard(_ unitPlan: UnitPTPlan) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .foregroundStyle(Color(hex: "#2563EB"))
                Text("Add to Your Calendar")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }

            Text("Schedule this Unit PT so it appears alongside your individual plan.")
                .font(.caption)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                DatePicker("Date", selection: $scheduledDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .foregroundStyle(MVMTheme.primaryText)
                    .tint(MVMTheme.accent)

                DatePicker("Start", selection: $scheduledStartTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .foregroundStyle(MVMTheme.primaryText)
                    .tint(MVMTheme.accent)

                DatePicker("End", selection: $scheduledEndTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .foregroundStyle(MVMTheme.primaryText)
                    .tint(MVMTheme.accent)
            }
            .padding(12)
            .background(MVMTheme.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                vm.addUnitPTToCalendar(
                    unitPlan,
                    on: scheduledDate,
                    startTime: scheduledStartTime,
                    endTime: scheduledEndTime
                )
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    addedToCalendar = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add to Calendar")
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(height: 52)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#2563EB"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(18)
        .premiumCard()
    }

    private var addedConfirmation: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(MVMTheme.success)

            VStack(alignment: .leading, spacing: 2) {
                Text("Added to Calendar")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("This Unit PT will show on your home calendar.")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
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
