import SwiftUI

struct ArmyPTExercisePickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSelect: (String) -> Void

    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool

    private var filteredExercises: [String] {
        ArmyPTExerciseLibrary.search(searchText)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.subheadline)
                            .foregroundStyle(MVMTheme.tertiaryText)
                        TextField("Search Army PT exercises...", text: $searchText)
                            .font(.subheadline)
                            .foregroundStyle(MVMTheme.primaryText)
                            .focused($isSearchFocused)
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(MVMTheme.tertiaryText)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(MVMTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSearchFocused ? MVMTheme.accent.opacity(0.5) : MVMTheme.border)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    HStack(spacing: 6) {
                        Image(systemName: "shield.fill")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(MVMTheme.accent)
                        Text("ARMY PRT EXERCISES ONLY")
                            .font(.caption2.weight(.heavy))
                            .tracking(0.6)
                            .foregroundStyle(MVMTheme.tertiaryText)
                        Spacer()
                        Text("\(filteredExercises.count) exercises")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 4) {
                            ForEach(filteredExercises, id: \.self) { exercise in
                                Button {
                                    onSelect(exercise)
                                    dismiss()
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "figure.strengthtraining.traditional")
                                            .font(.caption)
                                            .foregroundStyle(MVMTheme.accent.opacity(0.7))
                                            .frame(width: 24)

                                        Text(exercise)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(MVMTheme.primaryText)

                                        Spacer()

                                        Image(systemName: "plus.circle")
                                            .font(.body)
                                            .foregroundStyle(MVMTheme.accent)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 36)
                    }
                }
            }
            .navigationTitle("Add Army PT Exercise")
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
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(MVMTheme.background)
        .onAppear { isSearchFocused = true }
    }
}
