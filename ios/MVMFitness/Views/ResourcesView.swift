import SwiftUI

struct ResourcesView: View {
    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    testOverviewSection
                    scoringReferenceSection
                    officialGuidanceSection
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
                    Text("Minimum 60 points per event, 300 points total to pass.")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }

                Divider().overlay(MVMTheme.border)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Combat Standard")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text("Minimum 70 points per event, 350 points total to pass.")
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

                scoringQuickRef
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

    private var scoringQuickRef: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Reference — 100-Point Benchmarks")
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.accent)

            VStack(spacing: 6) {
                quickRefRow(event: "MDL", benchmark: "340 lbs (M, 17–21)")
                quickRefRow(event: "HRP", benchmark: "57 reps (M, 17–21)")
                quickRefRow(event: "SDC", benchmark: "1:33 (M, 17–21)")
                quickRefRow(event: "PLK", benchmark: "3:30+ (M, 17–21)")
                quickRefRow(event: "2MR", benchmark: "13:30 (M, 17–21)")
            }

            Text("Benchmarks vary by age group and sex. Use the AFT Calculator for personalized scoring.")
                .font(.caption2)
                .foregroundStyle(MVMTheme.tertiaryText)
        }
    }

    private func quickRefRow(event: String, benchmark: String) -> some View {
        HStack {
            Text(event)
                .font(.caption.weight(.bold))
                .foregroundStyle(MVMTheme.accent)
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

    private var officialGuidanceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "link", title: "OFFICIAL GUIDANCE")

            Link(destination: URL(string: "https://www.army.mil/acft/")!) {
                HStack(spacing: 14) {
                    Image(systemName: "globe")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(MVMTheme.accent)
                        .frame(width: 40, height: 40)
                        .background(MVMTheme.accent.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("View Official Guidance")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("Opens the official U.S. Army fitness test page")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "arrow.up.right.square")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(MVMTheme.accent)
                }
                .padding(14)
                .background(MVMTheme.card)
                .clipShape(.rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(MVMTheme.border)
                }
            }
        }
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

            Text("This information is based on publicly available military fitness standards and is provided for general reference only. This app is not affiliated with the U.S. Department of Defense.")
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
