import SwiftUI
import ContactsUI

/// Member detail — edit contact info, import from Contacts, email the member,
/// and manually log AFT / CFT / WHtR results. All scoring comes from
/// `AFTScoringEngine`; nothing is computed here.
struct SquadMemberDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    let store: SquadStore
    let memberID: UUID

    @State private var name = ""
    @State private var rankTitle = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var unit = ""
    /// Birth year, sex and standard were creation-only. A wrong birth year
    /// silently scored the member against the wrong age band forever, with no
    /// way to correct it — the single most damaging gap in the roster.
    @State private var birthYearText = ""
    @State private var editSex: SoldierSex = .male
    @State private var editStandard: AFTStandard = .general
    @State private var showDeleteConfirm = false
    @State private var showContactPicker = false
    @State private var showAFTEntry = false
    @State private var showCFTEntry = false
    @State private var showWHtREntry = false
    @State private var saveTrigger = false

    private var member: SquadMember? {
        store.data.members.first { $0.id == memberID }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                if let member {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {
                            contactCard(member)
                            actionsCard(member)
                            historyCard(member)
                            dangerZone
                        }
                        .padding(20)
                    }
                } else {
                    Text("Member not found")
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }
            .navigationTitle(name.isEmpty ? "Member" : name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { saveFields(); dismiss() }
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .onAppear { loadFields() }
            // Swiping the sheet down used to discard every edit silently.
            .onDisappear { saveFields() }
            .alert("Remove \(name.isEmpty ? "member" : name)?", isPresented: $showDeleteConfirm) {
                Button("Remove", role: .destructive) {
                    if let member { store.deleteMember(member) }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes their contact details and every result you have logged for them. It cannot be undone.")
            }
            .sheet(isPresented: $showContactPicker) {
                ContactPicker { contact in
                    let full = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
                    if !full.isEmpty { name = full }
                    if let mail = contact.emailAddresses.first?.value as String?, email.isEmpty {
                        email = mail
                    }
                    if let number = contact.phoneNumbers.first?.value.stringValue, phone.isEmpty {
                        phone = number
                    }
                    saveFields()
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showAFTEntry) {
                if let member { SquadManualAFTSheet(store: store, member: member) }
            }
            .sheet(isPresented: $showCFTEntry) {
                if let member { SquadManualCFTSheet(store: store, member: member) }
            }
            .sheet(isPresented: $showWHtREntry) {
                if let member { SquadManualWHtRSheet(store: store, member: member) }
            }
            .sensoryFeedback(.success, trigger: saveTrigger)
        }
        .preferredColorScheme(.dark)
    }

    private func loadFields() {
        guard let member else { return }
        name = member.name
        rankTitle = member.rankTitle ?? ""
        email = member.email ?? ""
        phone = member.phone ?? ""
        unit = member.unit ?? ""
        birthYearText = "\(member.birthYear)"
        editSex = member.sex
        editStandard = member.standard
    }

    private func saveFields() {
        guard var updated = member else { return }
        updated.name = name.isEmpty ? updated.name : name
        updated.rankTitle = rankTitle.isEmpty ? nil : rankTitle
        updated.email = email.isEmpty ? nil : email
        updated.phone = phone.isEmpty ? nil : phone
        updated.unit = unit.isEmpty ? nil : unit
        // Only accept a plausible birth year; anything else would land in the
        // "Over 62" age band via max(17, ...) and score silently wrong.
        let thisYear = Calendar.current.component(.year, from: .now)
        if let year = Int(birthYearText), year >= thisYear - 75, year <= thisYear - 17 {
            updated.birthYear = year
        }
        updated.sex = editSex
        updated.standard = editStandard
        store.updateMember(updated)
        saveTrigger.toggle()
    }

    private var dangerZone: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                Text("Remove from squad")
            }
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .foregroundStyle(MVMTheme.danger)
    }

    // MARK: - Contact card

    private func contactCard(_ member: SquadMember) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CONTACT")
                .font(.caption.weight(.heavy)).tracking(1.2)
                .foregroundStyle(MVMTheme.tertiaryText)

            field("Name", text: $name)
            field("Rank / Title", text: $rankTitle)
            field("Unit", text: $unit)
            field("Email", text: $email, keyboard: .emailAddress)
            field("Phone", text: $phone, keyboard: .phonePad)
            field("Birth year", text: $birthYearText, keyboard: .numberPad)

            HStack(spacing: 10) {
                Picker("Sex", selection: $editSex) {
                    ForEach(SoldierSex.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                Picker("Standard", selection: $editStandard) {
                    ForEach(AFTStandard.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            .onChange(of: editSex) { _, _ in saveFields() }
            .onChange(of: editStandard) { _, _ in saveFields() }

            HStack(spacing: 10) {
                Button {
                    showContactPicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text("Import from Contacts")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    saveFields()
                    if let url = URL(string: "mailto:\(email)?subject=\(("MVM Fitness — " + store.data.squadName).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                        openURL(url)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "envelope.fill")
                        Text("Email")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(email.isEmpty ? MVMTheme.tertiaryText : MVMTheme.onAmber)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(email.isEmpty ? AnyShapeStyle(MVMTheme.cardSoft) : AnyShapeStyle(MVMTheme.amberButtonGradient))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(email.isEmpty)
            }

            Text("\(member.standard.rawValue) standard \(MVMTheme.dot) Age \(member.age()) \(MVMTheme.dot) Squad data stays on this device")
                .font(.caption2)
                .foregroundStyle(MVMTheme.tertiaryText)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(MVMTheme.border))
    }

    private func field(_ placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
            .autocorrectionDisabled()
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(MVMTheme.cardSoft))
            .foregroundStyle(MVMTheme.primaryText)
            .onSubmit { saveFields() }
    }

    // MARK: - Manual score entry

    private func actionsCard(_ member: SquadMember) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LOG A RESULT")
                .font(.caption.weight(.heavy)).tracking(1.2)
                .foregroundStyle(MVMTheme.tertiaryText)

            entryRow(icon: "list.clipboard.fill", title: "Add AFT Score", subtitle: "5 events, engine-scored") { showAFTEntry = true }
            entryRow(icon: "stopwatch.fill", title: "Add CFT Result", subtitle: "Time + GO/NO-GO") { showCFTEntry = true }
            entryRow(icon: "figure.stand", title: "Add Waist-to-Height", subtitle: "Body composition check") { showWHtREntry = true }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(MVMTheme.border))
    }

    private func entryRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(MVMTheme.primaryText)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(MVMTheme.accent)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - History

    private func historyCard(_ member: SquadMember) -> some View {
        let aft = store.aftHistory(for: member)
        let cft = store.cftHistory(for: member)

        return VStack(alignment: .leading, spacing: 10) {
            Text("HISTORY")
                .font(.caption.weight(.heavy)).tracking(1.2)
                .foregroundStyle(MVMTheme.tertiaryText)

            if aft.isEmpty && cft.isEmpty {
                Text("No results logged yet.")
                    .font(.caption)
                    .foregroundStyle(MVMTheme.tertiaryText)
            }

            ForEach(aft.prefix(6)) { result in
                HStack {
                    Text("AFT")
                        .font(MVMTheme.mono(10, weight: .bold))
                        .foregroundStyle(MVMTheme.amber)
                    Text(result.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                    Spacer()
                    Text("\(result.total)")
                        .font(.subheadline.weight(.heavy)).monospacedDigit()
                        .foregroundStyle(result.passed ? MVMTheme.success : MVMTheme.danger)
                    Text(result.passed ? "PASS" : "FAIL")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(result.passed ? MVMTheme.success : MVMTheme.danger)
                }
                .padding(.vertical, 6)
            }

            ForEach(cft.prefix(4)) { result in
                HStack {
                    Text("CFT")
                        .font(MVMTheme.mono(10, weight: .bold))
                        .foregroundStyle(MVMTheme.amber)
                    Text(result.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(MVMTheme.tertiaryText)
                    Spacer()
                    Text(String(format: "%d:%02d", result.totalSeconds / 60, result.totalSeconds % 60))
                        .font(.subheadline.weight(.bold)).monospacedDigit()
                        .foregroundStyle(MVMTheme.primaryText)
                    Text(result.isGo ? "GO" : "NO-GO")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(result.isGo ? MVMTheme.success : MVMTheme.danger)
                }
                .padding(.vertical, 6)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(MVMTheme.card))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(MVMTheme.border))
    }
}

// MARK: - Contacts picker (no permission prompt — out-of-process picker)

struct ContactPicker: UIViewControllerRepresentable {
    let onSelect: (CNContact) -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onSelect: onSelect) }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        let onSelect: (CNContact) -> Void
        init(onSelect: @escaping (CNContact) -> Void) { self.onSelect = onSelect }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelect(contact)
        }
    }
}

// MARK: - Manual AFT entry (engine-scored)

struct SquadManualAFTSheet: View {
    @Environment(\.dismiss) private var dismiss
    let store: SquadStore
    let member: SquadMember

    @State private var mdlText = "180"
    @State private var hrpText = "25"
    @State private var sdcMin = "2"; @State private var sdcSec = "00"
    @State private var plkMin = "2"; @State private var plkSec = "00"
    @State private var runMin = "16"; @State private var runSec = "00"

    private let engine = AFTScoringEngine.shared

    private var raw: [Int] {
        [Int(mdlText) ?? 0, Int(hrpText) ?? 0,
         (Int(sdcMin) ?? 0) * 60 + (Int(sdcSec) ?? 0),
         (Int(plkMin) ?? 0) * 60 + (Int(plkSec) ?? 0),
         (Int(runMin) ?? 0) * 60 + (Int(runSec) ?? 0)]
    }

    private var points: [Int] {
        let events: [AFTEventType] = [.mdl, .hrp, .sdc, .plk, .run2mi]
        return events.enumerated().map { index, event in
            engine.score(event: event, age: member.age(), sex: member.sex, standard: member.standard, rawValue: raw[index])
        }
    }

    private var total: Int { points.reduce(0, +) }

    private var passed: Bool {
        points.allSatisfy { $0 >= member.standard.minimumPerEvent }
            && total >= engine.minimumTotal(for: member.standard)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        pair("MDL", value: $mdlText, suffix: "LB")
                        pair("HRP", value: $hrpText, suffix: "REPS")
                        timePair("SDC", min: $sdcMin, sec: $sdcSec)
                        timePair("PLK", min: $plkMin, sec: $plkSec)
                        timePair("2MR", min: $runMin, sec: $runSec)

                        HStack {
                            Text("TOTAL")
                                .font(MVMTheme.mono(11)).kerning(1.2)
                                .foregroundStyle(MVMTheme.tertiaryText)
                            Spacer()
                            Text("\(total)")
                                .font(MVMTheme.scoreDisplay(34))
                                .foregroundStyle(passed ? MVMTheme.success : MVMTheme.danger)
                            Text(passed ? "GO" : "NO GO")
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(passed ? MVMTheme.success : MVMTheme.danger)
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 14).fill(MVMTheme.card))

                        Button {
                            store.addAFT(SquadAFTResult(
                                memberID: member.id,
                                mdlLbs: raw[0], hrpReps: raw[1], sdcSeconds: raw[2],
                                plkSeconds: raw[3], runSeconds: raw[4],
                                eventPoints: points, total: total, passed: passed
                            ))
                            dismiss()
                        } label: {
                            Text("Save AFT Result")
                                .font(.headline.weight(.bold)).foregroundStyle(MVMTheme.onAmber)
                                .frame(maxWidth: .infinity).frame(height: 52)
                                .background(MVMTheme.amberButtonGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .contentShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }
                    .padding(20)
                }
            }
            .navigationTitle("\(member.name) \(MVMTheme.dot) AFT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func pair(_ label: String, value: Binding<String>, suffix: String) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(MVMTheme.mono(11, weight: .bold))
                .foregroundStyle(MVMTheme.amber)
                .frame(width: 44, alignment: .leading)
            TextField("0", text: value)
                .keyboardType(.numberPad)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(MVMTheme.cardSoft))
                .foregroundStyle(MVMTheme.primaryText)
            Text(suffix)
                .font(MVMTheme.mono(10))
                .foregroundStyle(MVMTheme.tertiaryText)
                .frame(width: 44, alignment: .leading)
        }
    }

    private func timePair(_ label: String, min: Binding<String>, sec: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(MVMTheme.mono(11, weight: .bold))
                .foregroundStyle(MVMTheme.amber)
                .frame(width: 44, alignment: .leading)
            TextField("0", text: min)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(MVMTheme.cardSoft))
                .foregroundStyle(MVMTheme.primaryText)
            Text(":").foregroundStyle(MVMTheme.tertiaryText)
            TextField("00", text: sec)
                .keyboardType(.numberPad)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(MVMTheme.cardSoft))
                .foregroundStyle(MVMTheme.primaryText)
            Text("M:S")
                .font(MVMTheme.mono(10))
                .foregroundStyle(MVMTheme.tertiaryText)
                .frame(width: 44, alignment: .leading)
        }
    }
}

// MARK: - Manual CFT entry

struct SquadManualCFTSheet: View {
    @Environment(\.dismiss) private var dismiss
    let store: SquadStore
    let member: SquadMember

    @State private var minText = "18"
    @State private var secText = "00"
    @State private var isGo = true

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        TextField("18", text: $minText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(MVMTheme.cardSoft))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text(":").foregroundStyle(MVMTheme.tertiaryText)
                        TextField("00", text: $secText)
                            .keyboardType(.numberPad)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(MVMTheme.cardSoft))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("TOTAL TIME")
                            .font(MVMTheme.mono(10))
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }

                    Picker("Result", selection: $isGo) {
                        Text("GO").tag(true)
                        Text("NO-GO").tag(false)
                    }
                    .pickerStyle(.segmented)

                    Button {
                        let seconds = (Int(minText) ?? 0) * 60 + (Int(secText) ?? 0)
                        store.addCFT(SquadCFTResult(memberID: member.id, totalSeconds: seconds, isGo: isGo))
                        dismiss()
                    } label: {
                        Text("Save CFT Result")
                            .font(.headline.weight(.bold)).foregroundStyle(MVMTheme.onAmber)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(MVMTheme.amberButtonGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("\(member.name) \(MVMTheme.dot) CFT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
    }
}

// MARK: - Manual WHtR entry

struct SquadManualWHtRSheet: View {
    @Environment(\.dismiss) private var dismiss
    let store: SquadStore
    let member: SquadMember

    @State private var waistText = "34"
    @State private var heightText = "69"

    private var ratio: Double {
        let h = Double(heightText) ?? 0
        return h > 0 ? (Double(waistText) ?? 0) / h : 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        TextField("34", text: $waistText)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(MVMTheme.cardSoft))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("WAIST IN")
                            .font(MVMTheme.mono(9)).foregroundStyle(MVMTheme.tertiaryText)
                        TextField("69", text: $heightText)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(MVMTheme.cardSoft))
                            .foregroundStyle(MVMTheme.primaryText)
                        Text("HT IN")
                            .font(MVMTheme.mono(9)).foregroundStyle(MVMTheme.tertiaryText)
                    }

                    Text(String(format: "Ratio %.2f %@", ratio, ratio < 0.55 && ratio > 0 ? "\u{00B7} MEETS STANDARD" : ""))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(ratio > 0 && ratio < 0.55 ? MVMTheme.success : MVMTheme.warning)

                    Button {
                        store.addWHtR(SquadWHtRResult(memberID: member.id, waistInches: Double(waistText) ?? 0, heightInches: Double(heightText) ?? 0))
                        dismiss()
                    } label: {
                        Text("Save WHtR")
                            .font(.headline.weight(.bold)).foregroundStyle(MVMTheme.onAmber)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(MVMTheme.amberButtonGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("\(member.name) \(MVMTheme.dot) WHtR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } } }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
    }
}
