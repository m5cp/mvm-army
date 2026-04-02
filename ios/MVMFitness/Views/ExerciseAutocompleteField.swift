import SwiftUI

struct ExerciseAutocompleteField: View {
    let title: String
    @Binding var text: String
    var accentColor: Color = MVMTheme.accent
    var onChanged: (() -> Void)? = nil

    @State private var isEditing: Bool = false
    @State private var suggestions: [String] = []
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(MVMTheme.secondaryText)

            TextField("Search exercise...", text: $text)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(MVMTheme.cardSoft)
                .foregroundStyle(MVMTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isFocused ? accentColor.opacity(0.5) : MVMTheme.border)
                }
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    if isFocused {
                        suggestions = ExerciseLibrary.search(newValue).prefix(6).map { $0 }
                    }
                    onChanged?()
                }
                .onChange(of: isFocused) { _, focused in
                    if focused {
                        isEditing = true
                        suggestions = ExerciseLibrary.search(text).prefix(6).map { $0 }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            isEditing = false
                            suggestions = []
                        }
                    }
                }

            if isEditing && !suggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button {
                            text = suggestion
                            suggestions = []
                            isEditing = false
                            isFocused = false
                            onChanged?()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.caption)
                                    .foregroundStyle(accentColor.opacity(0.7))

                                Text(highlightedText(suggestion, query: text))

                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if suggestion != suggestions.last {
                            Divider().overlay(MVMTheme.border)
                        }
                    }
                }
                .background(MVMTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(MVMTheme.border)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .zIndex(10)
            }
        }
        .animation(.easeOut(duration: 0.2), value: suggestions.count)
    }

    private func highlightedText(_ text: String, query: String) -> AttributedString {
        var attributed = AttributedString(text)
        attributed.foregroundColor = MVMTheme.primaryText
        attributed.font = .subheadline

        guard !query.isEmpty,
              let range = attributed.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) else {
            return attributed
        }

        attributed[range].foregroundColor = accentColor
        attributed[range].font = .subheadline.weight(.bold)
        return attributed
    }
}
