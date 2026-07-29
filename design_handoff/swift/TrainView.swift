import SwiftUI

/// 14a — active plan card, premade plans, build-your-own entry.
/// Every plan/movement carries event tags: they connect training to the score
/// ("targets your weakest event" on Home depends on them).
struct TrainView: View {
    @State private var tab = 0
    var body: some View {
        ZStack {
            MVMTheme.screen.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text("Train").font(.system(size: 32, weight: .bold)).tracking(-1)
                    .foregroundStyle(MVMTheme.text)
                segmented
                ScrollView {
                    VStack(spacing: 12) {
                        activePlan
                        Text("PREMADE PLANS").font(MVMTheme.mono(11)).kerning(1.6)
                            .foregroundStyle(MVMTheme.textFaint)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        planRow(photo: "photo-run-silhouette-sunrise", name: "Sub-14 two-mile", meta: "TARGETS 2MR \(MVMTheme.dot) 8 WEEKS")
                        planRow(photo: "ex-hex-deadlift", name: "Deadlift base", meta: "TARGETS MDL \(MVMTheme.dot) 6 WEEKS")
                        planRow(photo: "kettlebell-swing", name: "Full test prep", meta: "ALL 5 EVENTS \(MVMTheme.dot) 12 WEEKS")
                        buildYourOwn
                    }
                }
            }
            .padding(.horizontal, 22).padding(.top, 14)
        }
    }

    private var segmented: some View {
        InsetWell {
            HStack(spacing: 3) {
                ForEach(["Plans", "My workouts"].indices, id: \.self) { i in
                    Text(["Plans", "My workouts"][i])
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(tab == i ? MVMTheme.onAmber : MVMTheme.textMuted)
                        .frame(maxWidth: .infinity).frame(height: 40)
                        .background(tab == i ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(.clear))
                        .clipShape(RoundedRectangle(cornerRadius: 11))
                        .onTapGesture { tab = i }
                }
            }
            .padding(3)
        }
    }

    private var activePlan: some View {
        RaisedCard(radius: 22) {
            ZStack(alignment: .topLeading) {
                GradedPhoto(name: "photo-ruck-wide-landscape", grade: .lowKeyGym)
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ACTIVE PLAN \(MVMTheme.dot) WEEK 3 OF 6")
                            .font(MVMTheme.mono(10.5)).kerning(1.4)
                            .foregroundStyle(MVMTheme.amber)
                            .lineLimit(1).fixedSize()
                        Text("Close the plank gap")
                            .font(.system(size: 21, weight: .bold)).tracking(-0.4)
                            .foregroundStyle(MVMTheme.text)
                        Text("TARGETS PLK \(MVMTheme.dot) 4 SESSIONS / WEEK")
                            .font(MVMTheme.mono(11.5))
                            .foregroundStyle(MVMTheme.textMuted)
                            .lineLimit(1).fixedSize()
                        progressPips(done: 3, total: 6).padding(.top, 7)
                    }
                    .padding(.init(top: 14, leading: 18, bottom: 15, trailing: 18))
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("UP NEXT").font(MVMTheme.mono(10)).kerning(1.2)
                                .foregroundStyle(MVMTheme.textMuted)
                            Text("Anti-extension \(MVMTheme.dot) 28 min")
                                .font(.system(size: 13.5, weight: .semibold))
                                .foregroundStyle(MVMTheme.text)
                                .lineLimit(1).fixedSize()   // regression: this wrapped once
                        }
                        Spacer()
                        Text("Start")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(MVMTheme.onAmber)
                            .padding(.horizontal, 18).frame(minHeight: 44)
                            .background(MVMTheme.amberButtonGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 18).padding(.vertical, 13)
                    .background(Color(hex: 0x0C0908).opacity(0.4))
                    .overlay(alignment: .top) { MVMTheme.hairline.frame(height: 1) }
                }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(MVMTheme.amber.opacity(0.34), lineWidth: 1))
    }

    private func progressPips(done: Int, total: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                Capsule().fill(i < done ? MVMTheme.amber : MVMTheme.text.opacity(0.16))
                    .frame(height: 5).frame(maxWidth: .infinity)
            }
        }
    }

    private func planRow(photo: String, name: String, meta: String) -> some View {
        RaisedCard {
            HStack(spacing: 12) {
                GradedPhoto(name: photo, grade: .lowKeyGym)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                VStack(alignment: .leading, spacing: 4) {
                    Text(name).font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(MVMTheme.text)
                    Text(meta).font(MVMTheme.mono(10.5))
                        .foregroundStyle(MVMTheme.textMuted)
                        .lineLimit(1).fixedSize()
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MVMTheme.text.opacity(0.45))
            }
            .padding(.init(top: 9, leading: 12, bottom: 9, trailing: 12))
        }
    }

    private var buildYourOwn: some View {
        HStack(spacing: 12) {
            Image(systemName: "plus")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(MVMTheme.amber)
                .frame(width: 36, height: 36)
                .background(MVMTheme.amber.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 3) {
                Text("Build your own workout")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MVMTheme.amber)
                Text("PICK MOVEMENTS \(MVMTheme.dot) SETS \(MVMTheme.dot) REPS")
                    .font(MVMTheme.mono(10.5))
                    .foregroundStyle(MVMTheme.textFaint)
                    .lineLimit(1).fixedSize()
            }
            Spacer()
        }
        .padding(.horizontal, 16).frame(minHeight: 56)
        .overlay(RoundedRectangle(cornerRadius: 20)
            .strokeBorder(MVMTheme.amber.opacity(0.42), style: .init(lineWidth: 1.5, dash: [6, 5])))
    }
}
