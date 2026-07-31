import SwiftUI

struct SquadView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreViewModel.self) private var storeVM

    @State private var store = SquadStore()
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
            .onAppear { if !noticeShown { showFirstUseNotice = true } }
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
            Button("Archive", role: .destructive) { store.archiveMember(member) }
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
