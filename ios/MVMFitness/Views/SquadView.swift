import SwiftUI

struct SquadView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreViewModel.self) private var storeVM

    @State private var store = SquadStore()
    @State private var showAppInvite = false
    @State private var showAddMember = false
    @State private var showTestDay = false
    @State private var selectedMember: SquadMember?
    @State private var showInvite = false
    @State private var showScan = false
    @State private var showMyStats = false
    @State private var showUpgrade = false
    @State private var showFirstUseNotice = false
    @AppStorage("squadNoticeShown") private var noticeShown = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        readinessHeader
                        standingsSection
                        rosterSection
                        actionsSection
                        Text(LegalText.full)
                            .font(.caption2)
                            .foregroundStyle(MVMTheme.tertiaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(store.data.squadName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }.foregroundStyle(MVMTheme.accent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { addMemberTapped() } label: {
                        Image(systemName: "person.badge.plus").foregroundStyle(MVMTheme.accent)
                    }
                    .accessibilityLabel("Add squad member")
                }
            }
            .sheet(isPresented: $showAddMember) { AddSquadMemberSheet(store: store) }
            .sheet(item: $selectedMember) { member in
                SquadMemberDetailSheet(store: store, memberID: member.id)
            }
            .sheet(isPresented: $showInvite) { SquadInviteSheet(store: store) }
            .sheet(isPresented: $showScan) { SquadScanSheet(store: store) }
            .sheet(isPresented: $showMyStats) { SquadMyStatsSheet() }
            .sheet(isPresented: $showTestDay) { SquadAFTTestDayView(store: store) }
            .sheet(isPresented: $showUpgrade) { UpgradeView() }
            .alert("Your Squad, Your Responsibility", isPresented: $showFirstUseNotice) {
                Button("I Understand") { noticeShown = true }
            } message: {
                Text("Squad data stays on this device. You are responsible for it. Consider using initials or roster numbers instead of full names. Records here are unofficial training aids — official results live on DA Form 705/DA 5500 and in ATIS.")
            }
            .sheet(isPresented: $showAppInvite) { appInviteSheet }
            .onAppear {
                store.reload()
                if !noticeShown { showFirstUseNotice = true }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func addMemberTapped() {
        if ProGate.isUnlocked(.squadMembers, isPremium: storeVM.isPremium, squadMemberCount: store.activeMembers.count) {
            showAddMember = true
        } else {
            showUpgrade = true
        }
    }

    private var readinessHeader: some View {
        let r = store.readiness
        return HStack(spacing: 12) {
            readinessPill("AFT", "\(r.aftGreen)/\(r.aftTotal)", r.aftGreen == r.aftTotal && r.aftTotal > 0)
            readinessPill("CFT", r.cftTotal == 0 ? "—" : "\(r.cftGo)/\(r.cftTotal)", r.cftGo == r.cftTotal && r.cftTotal > 0)
            readinessPill("WHtR", "\(r.whtrMet)/\(r.whtrTotal)", r.whtrMet == r.whtrTotal && r.whtrTotal > 0)
        }
    }

    private func readinessPill(_ label: String, _ value: String, _ allGreen: Bool) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.weight(.heavy)).monospacedDigit()
                .foregroundStyle(allGreen ? MVMTheme.success : MVMTheme.primaryText)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(MVMTheme.card))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(MVMTheme.border))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    /// Squad standings. Verified by the leader, kept inside the unit.
    @ViewBuilder
    private var standingsSection: some View {
        let rows = store.standings()
        let scored = rows.filter { $0.total != nil }
        if !scored.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text("STANDINGS")
                        .font(.caption.weight(.heavy)).tracking(1.2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                    Spacer()
                    if let average = store.averageAFTTotal {
                        Text("SQUAD AVG \(average)")
                            .font(MVMTheme.mono(10))
                            .foregroundStyle(MVMTheme.tertiaryText)
                            .lineLimit(1)
                            .fixedSize()
                    }
                }

                VStack(spacing: 0) {
                    ForEach(Array(scored.enumerated()), id: \.element.id) { index, row in
                        standingRow(rank: index + 1, row: row)
                        if index < scored.count - 1 {
                            Rectangle()
                                .fill(MVMTheme.border.opacity(0.5))
                                .frame(height: 1)
                        }
                    }
                }
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))

                let overdue = store.overdueMembers()
                if !overdue.isEmpty {
                    Text("\(overdue.count) \(overdue.count == 1 ? "member needs" : "members need") a test on record: \(overdue.map(\.name).joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.warning)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func standingRow(rank: Int, row: SquadStore.StandingRow) -> some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(MVMTheme.mono(12, weight: .bold))
                .foregroundStyle(rank == 1 ? MVMTheme.accent : MVMTheme.tertiaryText)
                .frame(width: 22, alignment: .leading)
                .lineLimit(1)
                .fixedSize()

            VStack(alignment: .leading, spacing: 2) {
                Text(row.member.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if let rank = row.member.rankTitle, !rank.isEmpty {
                    Text(rank)
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            if let delta = row.delta, delta != 0 {
                Text(delta > 0 ? "+\(delta)" : "\(delta)")
                    .font(MVMTheme.mono(10, weight: .bold))
                    .foregroundStyle(delta > 0 ? MVMTheme.success : MVMTheme.warning)
                    .lineLimit(1)
                    .fixedSize()
            }

            VStack(alignment: .trailing, spacing: 2) {
                Text(row.total.map(String.init) ?? "—")
                    .font(MVMTheme.mono(15, weight: .bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .lineLimit(1)
                    .fixedSize()
                Text(row.passed == true ? "GO" : "NO GO")
                    .font(MVMTheme.mono(9, weight: .bold))
                    .foregroundStyle(row.passed == true ? MVMTheme.success : MVMTheme.danger)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rank \(rank), \(row.member.name), \(row.total.map { "\($0) points" } ?? "no score"), \(row.passed == true ? "go" : "no go")")
    }

    private var rosterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ROSTER")
                .font(.caption.weight(.heavy)).tracking(1.2)
                .foregroundStyle(MVMTheme.tertiaryText)

            if store.activeMembers.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "person.3").font(.title2).foregroundStyle(MVMTheme.tertiaryText)
                    Text("No members yet").font(.subheadline).foregroundStyle(MVMTheme.secondaryText)
                    Button("Add your first member") { addMemberTapped() }
                        .font(.subheadline.weight(.semibold)).foregroundStyle(MVMTheme.accent)
                }
                .frame(maxWidth: .infinity).padding(24)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))
            } else {
                ForEach(store.activeMembers) { member in
                    memberRow(member)
                }
            }
        }
    }

    private func memberRow(_ member: SquadMember) -> some View {
        let aft = store.latestAFT(for: member)
        let subtitleParts = [member.rankTitle, "\(member.standard.rawValue) · Age \(member.age())", member.email].compactMap { $0 }.filter { !$0.isEmpty }
        return Button {
            selectedMember = member
        } label: {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(member.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                Text(subtitleParts.joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(MVMTheme.tertiaryText)
                    .lineLimit(1)
            }
            Spacer()
            if let aft {
                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(aft.total)")
                        .font(.subheadline.weight(.heavy)).monospacedDigit()
                        .foregroundStyle(aft.passed ? MVMTheme.success : MVMTheme.danger)
                    Text(aft.passed ? "PASS" : "FAIL")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(aft.passed ? MVMTheme.success : MVMTheme.danger)
                }
            } else {
                Text("No AFT")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(MVMTheme.tertiaryText)
            }
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(MVMTheme.card))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(MVMTheme.border))
        .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PressScaleButtonStyle())
        .contextMenu {
            Button("Archive") { store.archiveMember(member) }
            Button("Remove", role: .destructive) { store.deleteMember(member) }
        }
    }

    /// An invite to the app itself. No roster, no scores, no personal data —
    /// just a pointer to the App Store, so it is safe to hand to anyone.
    private var appInviteSheet: some View {
        NavigationStack {
            VStack(spacing: 18) {
                if let image = MVMQRService.appInvite() {
                    Image(uiImage: image)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 240)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 18).fill(.white))
                }
                Text("Invite to MVM Fitness")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                Text("Have them scan this to get the app. It carries no personal data — no roster, no scores, no unit.")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(MVMTheme.background.ignoresSafeArea())
            .navigationTitle("Invite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showAppInvite = false }
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 10) {
            Button {
                showTestDay = true
            } label: {
                HStack {
                    Image(systemName: "stopwatch.fill")
                    Text("AFT Test Day").font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(MVMTheme.heroGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(store.activeMembers.isEmpty)
            .opacity(store.activeMembers.isEmpty ? 0.5 : 1)

            HStack(spacing: 10) {
                Button {
                    showInvite = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "qrcode")
                        Text("Invite").font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .frame(maxWidth: .infinity).frame(height: 46)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.card))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(MVMTheme.border))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    showAppInvite = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "app.badge")
                        Text("Invite to App").font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .frame(maxWidth: .infinity).frame(height: 46)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.card))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(MVMTheme.border))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    showScan = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Scan").font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .frame(maxWidth: .infinity).frame(height: 46)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.card))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(MVMTheme.border))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    showMyStats = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.text.rectangle")
                        Text("My Stats").font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(MVMTheme.accent)
                    .frame(maxWidth: .infinity).frame(height: 46)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.card))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(MVMTheme.border))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            ShareLink(item: store.exportCSV(), preview: SharePreview("Squad Results CSV")) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Squad CSV").font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(MVMTheme.accent)
                .frame(maxWidth: .infinity).frame(height: 46)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.card))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(MVMTheme.border))
            }
            .disabled(store.activeMembers.isEmpty)
        }
    }
}

// MARK: - Add member sheet

struct AddSquadMemberSheet: View {
    @Environment(\.dismiss) private var dismiss
    let store: SquadStore

    @State private var name = ""
    @State private var birthYearText = ""
    @State private var sex: SoldierSex = .male
    @State private var standard: AFTStandard = .general

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    TextField("Name / initials / roster #", text: $name)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.cardSoft))
                        .foregroundStyle(MVMTheme.primaryText)

                    TextField("Birth year (e.g. 1998)", text: $birthYearText)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.cardSoft))
                        .foregroundStyle(MVMTheme.primaryText)

                    Picker("Sex", selection: $sex) {
                        Text("Male").tag(SoldierSex.male)
                        Text("Female").tag(SoldierSex.female)
                    }.pickerStyle(.segmented)

                    Picker("Standard", selection: $standard) {
                        Text("General").tag(AFTStandard.general)
                        Text("Combat").tag(AFTStandard.combat)
                    }.pickerStyle(.segmented)

                    Button {
                        if let year = Int(birthYearText), !name.isEmpty {
                            store.addMember(SquadMember(name: name, birthYear: year, sex: sex, standard: standard))
                            dismiss()
                        }
                    } label: {
                        Text("Add Member")
                            .font(.headline.weight(.bold)).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(MVMTheme.heroGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(name.isEmpty || Int(birthYearText) == nil)
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }
}
