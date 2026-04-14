import SwiftUI

struct ResourcesView: View {
    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    testOverviewSection
                    scoringReferenceSection
                    scoringTablesSection
                    disclaimerSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .adaptiveContainer()
            }
        }
        .navigationTitle("Scoring Reference")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var testOverviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "list.clipboard", title: "TEST OVERVIEW")

            VStack(alignment: .leading, spacing: 12) {
                overviewRow(
                    event: "3 Repetition Maximum Deadlift (MDL)",
                    description: "Measures lower-body and grip strength. Perform three continuous repetitions of a hex-bar deadlift at your maximum manageable weight."
                )
                Divider().overlay(MVMTheme.border)
                overviewRow(
                    event: "Hand-Release Push-Up (HRP)",
                    description: "Tests upper-body muscular endurance. Complete as many hand-release push-ups as possible within two minutes."
                )
                Divider().overlay(MVMTheme.border)
                overviewRow(
                    event: "Sprint-Drag-Carry (SDC)",
                    description: "Assesses anaerobic power, agility, and work capacity. Complete five 50-meter shuttles: sprint, sled drag, lateral shuffle, carry, and sprint."
                )
                Divider().overlay(MVMTheme.border)
                overviewRow(
                    event: "Plank (PLK)",
                    description: "Measures core muscular endurance. Hold a proper plank position for as long as possible."
                )
                Divider().overlay(MVMTheme.border)
                overviewRow(
                    event: "Two-Mile Run (2MR)",
                    description: "Tests aerobic endurance. Complete a two-mile run on a measured, level course in the shortest time possible."
                )
            }
            .padding(16)
            .background(MVMTheme.card)
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(MVMTheme.border)
            }
        }
    }

    private var scoringReferenceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "tablecells", title: "SCORING STANDARDS")

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("General Standard")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Minimum 60 points per event, 300 points total to pass. Scoring is age- and sex-normed.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                Divider().overlay(MVMTheme.border)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Combat Standard")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Minimum 60 points per event, 350 points total to pass. Sex-neutral scoring — all soldiers use the same table.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                Divider().overlay(MVMTheme.border)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Score Range")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Each event is scored 0–100 points based on age- and sex-normed performance tables. Maximum total score is 500 points across all five events.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                Divider().overlay(MVMTheme.border)

                scoringQuickRefMale
                Divider().overlay(MVMTheme.border)
                scoringQuickRefFemale
            }
            .padding(16)
            .background(MVMTheme.card)
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(MVMTheme.border)
            }
        }
    }

    private var scoringTablesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "tablecells.badge.ellipsis", title: "FULL SCORING TABLES")

            NavigationLink(destination: AFTScoringTableView()) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(MVMTheme.accent.opacity(0.15))
                            .frame(width: 42, height: 42)
                        Image(systemName: "tablecells")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(MVMTheme.accent)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("View Scoring Tables")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("All events, age bands & standards")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                .padding(14)
                .background(MVMTheme.card)
                .clipShape(.rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(MVMTheme.border)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var scoringQuickRefMale: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("100-Point Benchmarks — Male / Combat (17–21)")
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.accent)

            VStack(spacing: 6) {
                quickRefRow(event: "MDL", benchmark: "340 lbs")
                quickRefRow(event: "HRP", benchmark: "58 reps")
                quickRefRow(event: "SDC", benchmark: "1:30")
                quickRefRow(event: "PLK", benchmark: "3:40")
                quickRefRow(event: "2MR", benchmark: "13:22")
            }
        }
    }

    private var scoringQuickRefFemale: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("100-Point Benchmarks — Female / General (17–21)")
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.accent2)

            VStack(spacing: 6) {
                quickRefRow(event: "MDL", benchmark: "220 lbs", tint: MVMTheme.accent2)
                quickRefRow(event: "HRP", benchmark: "53 reps", tint: MVMTheme.accent2)
                quickRefRow(event: "SDC", benchmark: "1:55", tint: MVMTheme.accent2)
                quickRefRow(event: "PLK", benchmark: "3:40", tint: MVMTheme.accent2)
                quickRefRow(event: "2MR", benchmark: "15:36", tint: MVMTheme.accent2)
            }

            Text("Benchmarks vary by age group and sex. Use the AFT Calculator for personalized scoring.")
                .font(.caption2)
                .foregroundStyle(MVMTheme.tertiaryText)
        }
    }

    private func quickRefRow(event: String, benchmark: String, tint: Color = MVMTheme.accent) -> some View {
        HStack {
            Text(event)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 36, alignment: .leading)
            Text(benchmark)
                .font(.caption)
                .foregroundStyle(MVMTheme.secondaryText)
            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .background(MVMTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 8))
    }

    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.tertiaryText)
                Text("Disclaimer")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            Text("This information is based on publicly available military fitness standards and is provided for general reference only. This app is not affiliated with, endorsed by, or sponsored by the U.S. Department of War or the Department of the Army.")
                .font(.caption2)
                .foregroundStyle(MVMTheme.tertiaryText)
                .lineSpacing(3)
        }
        .padding(14)
        .background(MVMTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 12))
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.tertiaryText)
            Text(title)
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(.horizontal, 4)
    }

    private func overviewRow(event: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.primaryText)
            Text(description)
                .font(.caption)
                .foregroundStyle(MVMTheme.secondaryText)
                .lineSpacing(2)
        }
    }
}
