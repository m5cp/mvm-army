import SwiftUI

struct WODPlanDayDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    let day: WODPlanDay

    @State private var movements: [WODMovement] = []
    @State private var expandedID: UUID?
    @State private var hasChanges: Bool = false
    @State private var editTrigger: Bool = false
    @State private var calendarService = CalendarExportService()

    init(day: WODPlanDay) {
        self.day = day
    }

    private let wodAccent = Color(hex: "#F59E0B")

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                if day.isRestDay {
                    restDayContent
                } else {
                    workoutContent
                }
            }
            .navigationTitle(day.isRestDay ? "Rest & Recovery" : day.template.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if hasChanges {
                        Button("Save") {
                            vm.updateWODDayMovements(dayId: day.id, movements: movements)
                            if vm.isCalendarSyncEnabled, let plan = vm.wodPlan {
                                Task {
                                    _ = await calendarService.resyncWODPlanFromDate(plan, from: day.date)
                                }
                            }
                            dismiss()
                        }
                        .foregroundStyle(wodAccent)
                        .fontWeight(.semibold)
                    } else {
                        Button("Done") { dismiss() }
                            .foregroundStyle(MVMTheme.primaryText)
                    }
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            movements = day.template.movements
        }
    }

    private var restDayContent: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(wodAccent.opacity(0.5))

                Text("Rest & Recovery")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)

                Text("Active rest day. Light movement, stretching, or mobility work.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button {
                vm.convertWODRestToWorkout(dayId: day.id)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.subheadline.weight(.bold))
                    Text("Replace with Workout")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [wodAccent, Color(hex: "#D97706")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())
            .padding(.horizontal, 20)

            Spacer()
            Spacer()
        }
    }

    private var workoutContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                headerCard
                detailsBar

                movementsSection
                actionsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.heart.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("FUNCTIONFITNESS")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                Text(day.template.format.rawValue)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text(day.template.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text(day.template.workoutDescription)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#D97706"), Color(hex: "#B45309").opacity(0.95)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var detailsBar: some View {
        HStack(spacing: 0) {
            detailPill(icon: "clock", value: "~\(day.template.durationMinutes) min", label: "Duration")
            detailDivider
            detailPill(icon: "tag", value: day.template.category.rawValue, label: "Type")
            detailDivider
            detailPill(icon: "wrench.and.screwdriver", value: day.template.equipment.rawValue, label: "Equipment")
        }
        .padding(.vertical, 14)
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(MVMTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var detailDivider: some View {
        Rectangle()
            .fill(MVMTheme.border)
            .frame(width: 1, height: 28)
    }

    private func detailPill(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(wodAccent)
                Text(value)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }


    @State private var reorderMode: Bool = false
    @State private var showAddMovement: Bool = false

    private var movementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("MOVEMENTS")
                    .font(.caption.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(MVMTheme.tertiaryText)

                Spacer()

                Button {
                    withAnimation {
                        reorderMode.toggle()
                    }
                } label: {
                    Text(reorderMode ? "Done" : "Reorder")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(wodAccent)
                }
            }
            .padding(.leading, 4)

            if reorderMode {
                List {
                    ForEach(Array(movements.enumerated()), id: \.element.id) { index, movement in
                        HStack(spacing: 12) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(wodAccent)
                                .frame(width: 24, height: 24)
                                .background(wodAccent.opacity(0.12))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(movement.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(MVMTheme.primaryText)
                                HStack(spacing: 6) {
                                    if let reps = movement.reps {
                                        Text(reps)
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(wodAccent)
                                    }
                                    if let dur = movement.duration {
                                        Text(dur)
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(wodAccent)
                                    }
                                }
                            }
                        }
                        .listRowBackground(MVMTheme.card)
                    }
                    .onMove { from, to in
                        movements.move(fromOffsets: from, toOffset: to)
                        hasChanges = true
                    }
                    .onDelete { indexSet in
                        movements.remove(atOffsets: indexSet)
                        hasChanges = true
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, .constant(.active))
                .frame(height: CGFloat(movements.count * 60 + 10))
            } else {
                ForEach(Array(movements.enumerated()), id: \.element.id) { index, movement in
                    movementRow(index: index, movement: movement)
                }
            }

            Button {
                showAddMovement = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.body)
                    Text("Add Movement")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(wodAccent)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(wodAccent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(wodAccent.opacity(0.2))
                }
            }
            .buttonStyle(PressScaleButtonStyle())

            if let notes = day.template.notes, !notes.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(wodAccent)
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                .padding(12)
                .background(wodAccent.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .sheet(isPresented: $showAddMovement) {
            AddMovementSheet { newMovement in
                movements.append(newMovement)
                hasChanges = true
            }
        }
    }

    private func movementRow(index: Int, movement: WODMovement) -> some View {
        let isExpanded = expandedID == movement.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    expandedID = isExpanded ? nil : movement.id
                }
            } label: {
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(wodAccent)
                        .frame(width: 24, height: 24)
                        .background(wodAccent.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text(movement.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)

                        HStack(spacing: 8) {
                            if let reps = movement.reps {
                                Text(reps)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(wodAccent)
                            }
                            if let dur = movement.duration {
                                Text(dur)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(wodAccent)
                            }
                            if let w = movement.weight, !w.isEmpty {
                                Text("@ \(w)")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(MVMTheme.secondaryText)
                            }
                            if let notes = movement.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(MVMTheme.tertiaryText)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "pencil")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(wodAccent.opacity(0.6))
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().overlay(MVMTheme.border)

                VStack(alignment: .leading, spacing: 12) {
                    ExerciseAutocompleteField(
                        title: "Name",
                        text: Binding(
                            get: { movements[index].name },
                            set: { movements[index].name = $0; hasChanges = true }
                        ),
                        accentColor: wodAccent,
                        onChanged: { hasChanges = true }
                    )
                    .zIndex(10)

                    HStack(spacing: 12) {
                        movementField(title: "Reps", text: Binding(
                            get: { movements[index].reps ?? "" },
                            set: { movements[index].reps = $0.isEmpty ? nil : $0; hasChanges = true }
                        ))
                        movementField(title: "Duration", text: Binding(
                            get: { movements[index].duration ?? "" },
                            set: { movements[index].duration = $0.isEmpty ? nil : $0; hasChanges = true }
                        ))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "scalemass.fill")
                                .font(.caption2)
                                .foregroundStyle(wodAccent)
                            Text("Weight / Load")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MVMTheme.secondaryText)
                            if ExerciseLibrary.isWeightedExercise(movements[index].name) {
                                Text("(recommended)")
                                    .font(.caption2)
                                    .foregroundStyle(MVMTheme.tertiaryText)
                            }
                        }

                        TextField("e.g. 135 lbs, 20 lb vest", text: Binding(
                            get: { movements[index].weight ?? "" },
                            set: { movements[index].weight = $0.isEmpty ? nil : $0; hasChanges = true }
                        ))
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(MVMTheme.cardSoft)
                        .foregroundStyle(MVMTheme.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay { RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border) }
                    }

                    movementField(title: "Notes", text: Binding(
                        get: { movements[index].notes ?? "" },
                        set: { movements[index].notes = $0.isEmpty ? nil : $0; hasChanges = true }
                    ))
                }
                .padding(14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(MVMTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(MVMTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func movementField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            TextField(title, text: text)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(MVMTheme.cardSoft)
                .foregroundStyle(MVMTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border) }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 10) {
            Button {
                vm.convertWODDayToRest(dayId: day.id)
                if vm.isCalendarSyncEnabled, let plan = vm.wodPlan {
                    Task {
                        _ = await calendarService.resyncWODPlanFromDate(plan, from: day.date)
                    }
                }
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.caption.weight(.bold))
                    Text("Convert to Rest Day")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(MVMTheme.secondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(MVMTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(MVMTheme.border)
                }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                vm.regenerateWODDay(dayId: day.id)
                if vm.isCalendarSyncEnabled, let plan = vm.wodPlan {
                    Task {
                        _ = await calendarService.resyncWODPlanFromDate(plan, from: day.date)
                    }
                }
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption.weight(.bold))
                    Text("Replace with Different Workout")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(wodAccent)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(wodAccent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }
}
