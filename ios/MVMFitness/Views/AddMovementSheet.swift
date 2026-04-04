import SwiftUI

struct AddMovementSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onAdd: (WODMovement) -> Void

    @State private var name: String = ""
    @State private var reps: String = ""
    @State private var duration: String = ""
    @State private var weight: String = ""
    @State private var notes: String = ""

    private let wodAccent = Color(hex: "#F59E0B")

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        ExerciseAutocompleteField(
                            title: "Movement Name",
                            text: $name,
                            accentColor: wodAccent
                        )
                        .zIndex(10)

                        HStack(spacing: 12) {
                            movementField(title: "Reps", text: $reps, placeholder: "e.g. 15")
                            movementField(title: "Duration", text: $duration, placeholder: "e.g. 30 sec")
                        }

                        movementField(title: "Weight / Load", text: $weight, placeholder: "e.g. 135 lbs")
                        movementField(title: "Notes", text: $notes, placeholder: "Optional notes...")

                        Button {
                            let movement = WODMovement(
                                name: name.isEmpty ? "New Movement" : name,
                                reps: reps.isEmpty ? nil : reps,
                                duration: duration.isEmpty ? nil : duration,
                                notes: notes.isEmpty ? nil : notes,
                                weight: weight.isEmpty ? nil : weight
                            )
                            onAdd(movement)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.subheadline.weight(.bold))
                                Text("Add Movement")
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
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1)
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Add Movement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(MVMTheme.background)
    }

    private func movementField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            TextField(placeholder, text: text)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(MVMTheme.cardSoft)
                .foregroundStyle(MVMTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(MVMTheme.border) }
        }
    }
}
