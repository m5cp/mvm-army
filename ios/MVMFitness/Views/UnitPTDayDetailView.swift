import SwiftUI

struct UnitPTDayDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var dayPlan: UnitPTDayPlan
    @State private var isEditing: Bool = false
    @State private var hapticTrigger: Bool = false

    let onSave: (UnitPTDayPlan) -> Void
    let onRegenerate: () -> Void

    init(dayPlan: UnitPTDayPlan, onSave: @escaping (UnitPTDayPlan) -> Void, onRegenerate: @escaping () -> Void) {
        self._dayPlan = State(initialValue: dayPlan)
        self.onSave = onSave
        self.onRegenerate = onRegenerate
    }

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    dayHeader
                    objectiveSection
                    formationSection
                    equipmentSection
                    warmupSection
                    mainEffortSection
                    cooldownSection
                    leaderNotesSection
                    tcsSection
                    actionButtons
                }
                .padding(20)
                .padding(.bottom, 48)
            }
        }
        .navigationTitle(dayPlan.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        onSave(dayPlan)
                        hapticTrigger.toggle()
                    }
                    withAnimation(.spring(response: 0.3)) {
                        isEditing.toggle()
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.accent)
            }
        }
        .sensoryFeedback(.success, trigger: hapticTrigger)
    }

    // MARK: - Header

    private var dayHeader: some View {
        HStack(spacing: 14) {
            VStack(spacing: 4) {
                Text(dayPlan.date.formatted(.dateTime.weekday(.abbreviated)).uppercased())
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(MVMTheme.accent)
                Text(dayPlan.date.formatted(.dateTime.day()))
                    .font(.title2.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
            }
            .frame(width: 56, height: 56)
            .background(MVMTheme.accent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 3) {
                if isEditing {
                    TextField("Session Title", text: $dayPlan.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                        .textFieldStyle(.plain)
                } else {
                    Text(dayPlan.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                }

                Text("Week \(dayPlan.weekIndex + 1) · Day \(dayPlan.dayIndex + 1) · \(dayPlan.mainEffort.count) exercises")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            Spacer(minLength: 0)

            if dayPlan.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(MVMTheme.success)
            }
        }
        .padding(18)
        .premiumCard()
    }

    // MARK: - Sections

    private var objectiveSection: some View {
        editableSection(
            title: "Objective",
            icon: "target",
            text: $dayPlan.objective
        )
    }

    private var formationSection: some View {
        editableSection(
            title: "Formation",
            icon: "person.3.sequence.fill",
            text: $dayPlan.formationNotes
        )
    }

    private var equipmentSection: some View {
        editableSection(
            title: "Equipment",
            icon: "wrench.and.screwdriver.fill",
            text: $dayPlan.equipment
        )
    }

    private var warmupSection: some View {
        editableSection(
            title: "Warm-Up",
            icon: "flame.fill",
            text: $dayPlan.warmup
        )
    }

    private var cooldownSection: some View {
        editableSection(
            title: "Cool-Down",
            icon: "wind",
            text: $dayPlan.cooldown
        )
    }

    private var leaderNotesSection: some View {
        editableSection(
            title: "Leader Notes",
            icon: "note.text",
            text: $dayPlan.leaderNotes
        )
    }

    // MARK: - Main Effort

    private var mainEffortSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "figure.mixed.cardio")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                Text("Main Effort")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Spacer(minLength: 0)

                if isEditing {
                    Button {
                        dayPlan.mainEffort.append(UnitPTBlock("New Exercise"))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.body)
                            .foregroundStyle(MVMTheme.accent)
                    }
                }
            }

            ForEach(Array(dayPlan.mainEffort.enumerated()), id: \.element.id) { index, block in
                HStack(spacing: 10) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.accent)
                        .frame(width: 24, height: 24)
                        .background(MVMTheme.accent.opacity(0.12))
                        .clipShape(Circle())

                    if isEditing {
                        TextField("Exercise", text: Binding(
                            get: { dayPlan.mainEffort[index].description },
                            set: { dayPlan.mainEffort[index].description = $0 }
                        ))
                        .font(.subheadline)
                        .foregroundStyle(MVMTheme.primaryText)
                        .textFieldStyle(.plain)

                        Button {
                            dayPlan.mainEffort.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.7))
                        }
                    } else {
                        Text(block.description)
                            .font(.subheadline)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                }
                .padding(12)
                .background(MVMTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .premiumCard()
    }

    // MARK: - TCS Section

    private var tcsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(hex: "#F59E0B"))
                Text("Task, Condition, Standard")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
            }

            tcsField(label: "TASK", text: $dayPlan.task, icon: "checkmark.square")
            tcsField(label: "CONDITION", text: $dayPlan.condition, icon: "mappin.and.ellipse")
            tcsField(label: "STANDARD", text: $dayPlan.standard, icon: "gauge.with.dots.needle.67percent")
        }
        .padding(16)
        .premiumCard()
    }

    private func tcsField(label: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(hex: "#F59E0B").opacity(0.7))
                Text(label)
                    .font(.caption2.weight(.heavy))
                    .tracking(0.6)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            if isEditing {
                TextEditor(text: text)
                    .font(.caption)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 60)
                    .padding(8)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.border)
                    }
            } else {
                Text(text.wrappedValue.isEmpty ? "Not specified" : text.wrappedValue)
                    .font(.caption)
                    .foregroundStyle(text.wrappedValue.isEmpty ? MVMTheme.tertiaryText : MVMTheme.secondaryText)
                    .lineSpacing(3)
            }
        }
        .padding(12)
        .background(MVMTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ShareLink(item: dayPlan.shareText) {
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
                onRegenerate()
                if let updatedPlan = vm.unitPTFullPlan,
                   dayPlan.weekIndex < updatedPlan.weeks.count,
                   dayPlan.dayIndex < updatedPlan.weeks[dayPlan.weekIndex].days.count {
                    dayPlan = updatedPlan.weeks[dayPlan.weekIndex].days[dayPlan.dayIndex]
                }
                hapticTrigger.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Regenerate This Day")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.accent)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(MVMTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(16)
        .premiumCard()
    }

    // MARK: - Editable Section Helper

    private func editableSection(title: String, icon: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
            }

            if isEditing {
                TextEditor(text: text)
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 60)
                    .padding(8)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(MVMTheme.border)
                    }
            } else {
                Text(text.wrappedValue)
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .premiumCard()
    }
}
