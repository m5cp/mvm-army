import SwiftUI

struct CardioAddOnSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var cardioAddOn: CardioAddOn?

    @State private var selectedType: SessionCardioType = .run
    @State private var durationMinutes: Int = 20
    @State private var hapticTrigger: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection

                        cardioTypeGrid

                        durationSection

                        if cardioAddOn != nil {
                            removeButton
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                    .adaptiveContainer()
                }
            }
            .navigationTitle("Add Cardio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        hapticTrigger.toggle()
                        cardioAddOn = CardioAddOn(
                            type: selectedType,
                            durationMinutes: durationMinutes,
                            isCompleted: cardioAddOn?.isCompleted ?? false
                        )
                        dismiss()
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
        }
        .onAppear {
            if let existing = cardioAddOn {
                selectedType = existing.type
                durationMinutes = existing.durationMinutes
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "figure.run.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(MVMTheme.accent)

            Text("Optional Cardio")
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("Add a cardio warm-up or finisher to this session.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var cardioTypeGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTIVITY")
                .font(.caption.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(SessionCardioType.allCases) { type in
                    let isSelected = selectedType == type
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedType = type
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.title2)
                                .foregroundStyle(isSelected ? .white : MVMTheme.secondaryText)

                            Text(type.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(isSelected ? .white : MVMTheme.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(
                            isSelected ?
                            AnyShapeStyle(MVMTheme.heroGradient) :
                            AnyShapeStyle(MVMTheme.card)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? MVMTheme.accent.opacity(0.4) : MVMTheme.border)
                        }
                        .shadow(color: isSelected ? MVMTheme.accent.opacity(0.2) : .clear, radius: 8, y: 4)
                    }
                    .buttonStyle(PressScaleButtonStyle())
                    .sensoryFeedback(.selection, trigger: selectedType)
                }
            }
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DURATION")
                .font(.caption.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.leading, 4)

            VStack(spacing: 16) {
                Text("\(durationMinutes) min")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(MVMTheme.primaryText)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: durationMinutes)

                HStack(spacing: 12) {
                    ForEach([10, 15, 20, 30, 45], id: \.self) { mins in
                        let isSelected = durationMinutes == mins
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                durationMinutes = mins
                            }
                        } label: {
                            Text("\(mins)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(isSelected ? .white : MVMTheme.secondaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(isSelected ? MVMTheme.accent : MVMTheme.cardSoft)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    if isSelected {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(MVMTheme.accent.opacity(0.4))
                                    }
                                }
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }
                }

                HStack(spacing: 0) {
                    Button {
                        if durationMinutes > 5 { durationMinutes -= 5 }
                    } label: {
                        Image(systemName: "minus")
                            .font(.headline)
                            .foregroundStyle(MVMTheme.primaryText)
                            .frame(width: 50, height: 44)
                    }

                    Spacer()

                    Slider(
                        value: Binding(
                            get: { Double(durationMinutes) },
                            set: { durationMinutes = Int($0) }
                        ),
                        in: 5...90,
                        step: 5
                    )
                    .tint(MVMTheme.accent)

                    Spacer()

                    Button {
                        if durationMinutes < 90 { durationMinutes += 5 }
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(MVMTheme.primaryText)
                            .frame(width: 50, height: 44)
                    }
                }
            }
            .padding(18)
            .premiumCard()
        }
    }

    private var removeButton: some View {
        Button(role: .destructive) {
            cardioAddOn = nil
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                    .font(.subheadline.weight(.semibold))
                Text("Remove Cardio")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(MVMTheme.danger)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(MVMTheme.danger.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PressScaleButtonStyle())
    }
}
