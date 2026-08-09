import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins

// Squad sharing: invite QR (owner) → join by scan (member) → member stats QR
// (member) → import by scan (owner). Everything travels inside the QR codes —
// no server, nothing leaves the devices.

private func squadQRImage(_ string: String) -> UIImage? {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(string.utf8)
    filter.correctionLevel = "M"
    guard let output = filter.outputImage else { return nil }
    let scaled = output.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
    guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
    return UIImage(cgImage: cgImage)
}

// MARK: - Invite QR (squad owner)

struct SquadInviteSheet: View {
    @Environment(\.dismiss) private var dismiss
    let store: SquadStore

    @State private var qrImage: UIImage?
    @State private var code: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        VStack(spacing: 16) {
                            if let qrImage {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 240, height: 240)
                                    .padding(18)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            } else {
                                ProgressView().frame(width: 240, height: 240)
                            }

                            Text(code)
                                .font(.system(size: 34, weight: .heavy, design: .monospaced))
                                .kerning(6)
                                .foregroundStyle(MVMTheme.amber)
                                .lineLimit(1)
                                .fixedSize()

                            Text("INVITE CODE")
                                .font(MVMTheme.mono(10)).kerning(1.6)
                                .foregroundStyle(MVMTheme.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .premiumCard()

                        VStack(alignment: .leading, spacing: 8) {
                            howToRow(number: "1", text: "Squad member opens MVM Fitness → My Squad → Join & Share")
                            howToRow(number: "2", text: "They scan this code (or enter it) to join \(store.data.squadName)")
                            howToRow(number: "3", text: "They generate their Stats QR and you scan it to pull their results in")
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))

                        if let qrImage {
                            ShareLink(
                                item: Image(uiImage: qrImage),
                                preview: SharePreview("Join \(store.data.squadName)", image: Image(uiImage: qrImage))
                            ) {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Invite")
                                }
                                .font(.headline)
                                .foregroundStyle(MVMTheme.onAmber)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(MVMTheme.amberButtonGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .contentShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Invite to Squad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Done") { dismiss() }.foregroundStyle(MVMTheme.accent) } }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                code = store.ensureInviteCode()
                let payload = SquadInvitePayload(squadName: store.data.squadName, code: code)
                if let data = try? JSONEncoder().encode(payload), let json = String(data: data, encoding: .utf8) {
                    qrImage = squadQRImage(json)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func howToRow(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(MVMTheme.mono(11, weight: .bold))
                .foregroundStyle(MVMTheme.onAmber)
                .frame(width: 22, height: 22)
                .background(MVMTheme.amber)
                .clipShape(Circle())
            Text(text)
                .font(.caption)
                .foregroundStyle(MVMTheme.secondaryText)
        }
    }
}

// MARK: - My Stats QR (squad member)

struct SquadMyStatsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @AppStorage("profileDisplayName") private var profileDisplayName = ""
    @AppStorage("joinedSquadName") private var joinedSquadName = ""
    @AppStorage("joinedSquadCode") private var joinedSquadCode = ""
    @AppStorage("myRankTitle") private var myRankTitle = ""
    @AppStorage("myShareEmail") private var myShareEmail = ""
    @AppStorage("mySharePhone") private var mySharePhone = ""
    @AppStorage("myUnitName") private var myUnitName = ""
    /// A stable identity for this device's soldier, so a rename on the leader's
    /// roster does not create a duplicate member on the next scan.
    @AppStorage("myShareMemberID") private var myShareMemberIDRaw = ""

    @State private var name = ""
    @State private var qrImage: UIImage?

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if !joinedSquadName.isEmpty {
                            Text("Sharing to \(joinedSquadName)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MVMTheme.amber)
                        }

                        Group {
                            TextField("Name", text: $name)
                            TextField("Rank / Title (optional)", text: $myRankTitle)
                            TextField("Unit (optional)", text: $myUnitName)
                            TextField("Email (optional)", text: $myShareEmail)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                            TextField("Phone (optional)", text: $mySharePhone)
                                .keyboardType(.phonePad)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.cardSoft))
                        .foregroundStyle(MVMTheme.primaryText)
                        .autocorrectionDisabled()
                        .onChange(of: name) { _, _ in regenerate() }
                        .onChange(of: myRankTitle) { _, _ in regenerate() }
                        .onChange(of: myShareEmail) { _, _ in regenerate() }
                        .onChange(of: mySharePhone) { _, _ in regenerate() }
            .onChange(of: myUnitName) { _, _ in regenerate() }

                        if let qrImage {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 240, height: 240)
                                .padding(18)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }

                        VStack(spacing: 4) {
                            if let latest = vm.latestAFTScore {
                                Text("Includes your latest AFT: \(latest.totalScore)/500")
                                    .font(.caption)
                                    .foregroundStyle(MVMTheme.secondaryText)
                            } else {
                                Text("No AFT score yet — the code shares contact info only")
                                    .font(.caption)
                                    .foregroundStyle(MVMTheme.secondaryText)
                            }
                            Text("Your squad leader scans this to import your stats. You choose exactly when to show it — nothing is sent anywhere.")
                                .font(.caption2)
                                .foregroundStyle(MVMTheme.tertiaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("My Stats QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Done") { dismiss() }.foregroundStyle(MVMTheme.accent) } }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                name = name.isEmpty ? profileDisplayName : name
                regenerate()
            }
        }
        .preferredColorScheme(.dark)
    }

    /// Created once and reused, so every code this device emits identifies the
    /// same soldier.
    private var stableMemberID: UUID {
        if let existing = UUID(uuidString: myShareMemberIDRaw) { return existing }
        let fresh = UUID()
        myShareMemberIDRaw = fresh.uuidString
        return fresh
    }

    private func regenerate() {
        let latest = vm.latestAFTScore
        // Identity used to come from three @AppStorage keys — birthYear,
        // soldierSex, aftStandard — that NOTHING in the app ever wrote. Every
        // code emitted claimed 1998 / Male / General, so the receiving roster
        // scored the soldier against the wrong age band and sex column
        // permanently. Take it from the score they actually recorded.
        let currentYear = Calendar.current.component(.year, from: .now)
        let derivedBirthYear = latest.map { currentYear - $0.age } ?? (currentYear - 25)
        let payload = SquadStatsPayload(
            code: joinedSquadCode.isEmpty ? nil : joinedSquadCode,
            name: name.isEmpty ? "Soldier" : name,
            rankTitle: myRankTitle.isEmpty ? nil : myRankTitle,
            email: myShareEmail.isEmpty ? nil : myShareEmail,
            phone: mySharePhone.isEmpty ? nil : mySharePhone,
            memberID: stableMemberID,
            unit: myUnitName.isEmpty ? nil : myUnitName,
            birthYear: derivedBirthYear,
            sexRaw: (latest?.sex ?? .male).rawValue,
            standardRaw: (latest?.standard ?? .general).rawValue,
            aftDate: latest?.date,
            aftRaw: latest.map { [$0.deadliftLbs, $0.pushUpReps, $0.sdcSeconds, $0.plankSeconds, $0.runSeconds] },
            aftPoints: latest.map { [$0.deadliftPoints, $0.pushUpPoints, $0.sdcPoints, $0.plankPoints, $0.runPoints] },
            aftTotal: latest?.totalScore,
            aftPassed: latest.map { score in
                score.totalScore >= AFTScoringEngine.shared.minimumTotal(for: score.standard)
                    && [score.deadliftPoints, score.pushUpPoints, score.sdcPoints, score.plankPoints, score.runPoints].allSatisfy { $0 >= score.standard.minimumPerEvent }
            },
            cftDate: nil,
            cftSeconds: nil,
            cftGo: nil
        )
        if let data = try? JSONEncoder().encode(payload), let json = String(data: data, encoding: .utf8) {
            qrImage = squadQRImage(json)
        }
    }
}

// MARK: - Scan (join a squad / import member stats)

struct SquadScanSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreViewModel.self) private var purchases
    let store: SquadStore

    @AppStorage("joinedSquadName") private var joinedSquadName = ""
    @AppStorage("joinedSquadCode") private var joinedSquadCode = ""

    @State private var resultMessage: String?
    @State private var resultIsError = false
    @State private var scanTrigger = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    if resultMessage == nil {
                        QRCameraView { code in
                            handle(code)
                        }
                        .frame(height: 380)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20).stroke(MVMTheme.border)
                        }

                        Text("Scan a squad invite or a member's Stats QR")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.secondaryText)
                    } else if let resultMessage {
                        VStack(spacing: 14) {
                            Image(systemName: resultIsError ? "xmark.circle.fill" : "checkmark.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(resultIsError ? MVMTheme.danger : MVMTheme.success)
                            Text(resultMessage)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(MVMTheme.primaryText)
                                .multilineTextAlignment(.center)
                            Button {
                                self.resultMessage = nil
                            } label: {
                                Text("Scan Another")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(MVMTheme.accent)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .premiumCard()
                    }
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Scan Squad Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Done") { dismiss() }.foregroundStyle(MVMTheme.accent) } }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sensoryFeedback(.success, trigger: scanTrigger)
        }
        .preferredColorScheme(.dark)
    }

    private func handle(_ code: String) {
        guard let data = code.data(using: .utf8) else {
            resultIsError = true
            resultMessage = "Unreadable code."
            return
        }
        let decoder = JSONDecoder()

        if let invite = try? decoder.decode(SquadInvitePayload.self, from: data), invite.kind == "mvmSquadInvite" {
            joinedSquadName = invite.squadName
            joinedSquadCode = invite.code
            resultIsError = false
            scanTrigger.toggle()
            resultMessage = "Joined \(invite.squadName). Open Join & Share to send your Stats QR back to the squad leader."
            return
        }

        if let stats = try? decoder.decode(SquadStatsPayload.self, from: data), stats.kind == "mvmSquadStats" {
            let summary = store.importStats(stats, isPremium: purchases.isPremium)
            resultIsError = false
            scanTrigger.toggle()
            resultMessage = summary
            return
        }

        resultIsError = true
        resultMessage = "Not a squad code. Workout QR codes are scanned from the Home screen scanner."
    }
}
