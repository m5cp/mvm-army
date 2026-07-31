import SwiftUI

struct ServiceAcademy: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let abbreviation: String
    let department: String
    let location: String
    let ageRequirement: String
    let nomination: String
    let deadline: String
    let testing: String
    let academics: String
    let fitness: String
    let medical: String
    let interview: String
    let officialURL: URL
}

private let academies: [ServiceAcademy] = [
    .init(
        name: "U.S. Military Academy",
        abbreviation: "USMA",
        department: "Department of the Army",
        location: "West Point, New York",
        ageRequirement: "At least 17; not yet 23 on July 1 of entry year",
        nomination: "Required from an authorized source",
        deadline: "January 31 of senior year",
        testing: "SAT or ACT required",
        academics: "Rigorous college-prep curriculum; GPA, class rank, math, science and English reviewed",
        fitness: "Candidate Fitness Assessment (CFA)",
        medical: "DoDMERB qualification required",
        interview: "Field Force Representative evaluation",
        officialURL: URL(string: "https://www.westpoint.edu/admissions/steps-to-admission")!
    ),
    .init(
        name: "U.S. Naval Academy",
        abbreviation: "USNA",
        department: "Department of the Navy",
        location: "Annapolis, Maryland",
        ageRequirement: "At least 17; not yet 23 on July 1 of entry year",
        nomination: "Required from an authorized source",
        deadline: "Start by Dec. 31, 2026; complete by Jan. 31, 2027",
        testing: "SAT, ACT or CLT accepted for Class of 2031",
        academics: "Whole-person review with substantial weight on math/verbal testing and class rank/GPA",
        fitness: "Candidate Fitness Assessment (CFA)",
        medical: "DoDMERB qualification required",
        interview: "Blue and Gold Officer interview",
        officialURL: URL(string: "https://www.usna.edu/Admissions/Apply/index.php")!
    ),
    .init(
        name: "U.S. Air Force Academy",
        abbreviation: "USAFA",
        department: "Department of the Air Force",
        location: "Colorado Springs, Colorado",
        ageRequirement: "At least 17; not past 23rd birthday by July 1",
        nomination: "Required from an authorized source",
        deadline: "Candidate-specific portal deadlines",
        testing: "SAT, ACT or CLT accepted for Class of 2031",
        academics: "Transcript rigor, GPA, class rank and standardized tests reviewed",
        fitness: "Candidate Fitness Assessment (CFA)",
        medical: "DoDMERB qualification required",
        interview: "Admissions Liaison Officer evaluation",
        officialURL: URL(string: "https://www.academyadmissions.com/apply/application-1/")!
    ),
    .init(
        name: "U.S. Coast Guard Academy",
        abbreviation: "USCGA",
        department: "Department of Homeland Security",
        location: "New London, Connecticut",
        ageRequirement: "17–22 on the last Monday in June",
        nomination: "Not required or considered",
        deadline: "Early Action Oct. 15; Regular Feb. 2",
        testing: "SAT or ACT required",
        academics: "Transcript plus math, English and counselor recommendations",
        fitness: "Physical Fitness Examination (PFE)",
        medical: "DoDMERB qualification required before appointment",
        interview: "Required only when requested by Admissions",
        officialURL: URL(string: "https://uscga.edu/admissions/admission-requirements/")!
    ),
    .init(
        name: "U.S. Merchant Marine Academy",
        abbreviation: "USMMA",
        department: "Department of Transportation (MARAD)",
        location: "Kings Point, New York",
        ageRequirement: "At least 17; not past 25th birthday before July 1",
        nomination: "Congressional nomination normally required; limited Secretarial appointments",
        deadline: "Nomination Jan. 31, 2027; application Feb. 1, 2027",
        testing: "SAT or ACT required; standard timed administration",
        academics: "Minimum English, math and lab-science courses; calculus, physics and chemistry strongly recommended",
        fitness: "Candidate Fitness Assessment (CFA)",
        medical: "DoDMERB and Navy body-composition standards",
        interview: "Nomination interview may be required",
        officialURL: URL(string: "https://www.usmma.edu/admissions/application/steps-admission")!
    )
]

struct AcademyComparisonView: View {
    @State private var searchText = ""
    @State private var selectedAcademy: ServiceAcademy?

    private var filteredAcademies: [ServiceAcademy] {
        guard !searchText.isEmpty else { return academies }
        return academies.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.abbreviation.localizedCaseInsensitiveContains(searchText) ||
            $0.department.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationSplitView {
            List(filteredAcademies, selection: $selectedAcademy) { academy in
                VStack(alignment: .leading, spacing: 4) {
                    Text(academy.abbreviation)
                        .font(.headline)
                    Text(academy.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .tag(academy)
            }
            .navigationTitle("Service Academies")
            .searchable(text: $searchText, prompt: "Search academy")
        } detail: {
            if let academy = selectedAcademy ?? filteredAcademies.first {
                AcademyDetailView(academy: academy)
            } else {
                ContentUnavailableView("No Academy Found",
                                       systemImage: "magnifyingglass",
                                       description: Text("Change the search and try again."))
            }
        }
    }
}

private struct AcademyDetailView: View {
    let academy: ServiceAcademy

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(academy.abbreviation)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(academy.name)
                        .font(.largeTitle.bold())
                    Text("\(academy.department) • \(academy.location)")
                        .foregroundStyle(.secondary)
                }

                GroupBox("Eligibility and Application") {
                    DetailGrid(rows: [
                        ("Age", academy.ageRequirement),
                        ("Nomination", academy.nomination),
                        ("Deadline", academy.deadline),
                        ("Testing", academy.testing)
                    ])
                }

                GroupBox("Candidate Evaluation") {
                    DetailGrid(rows: [
                        ("Academics", academy.academics),
                        ("Fitness", academy.fitness),
                        ("Medical", academy.medical),
                        ("Interview", academy.interview)
                    ])
                }

                Link(destination: academy.officialURL) {
                    Label("Open Official Admissions Page",
                          systemImage: "arrow.up.right.square")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Text("Requirements and deadlines can change. Confirm all information in the official application portal and with each nomination source.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: 850, alignment: .leading)
        }
        .navigationTitle(academy.abbreviation)
    }
}

private struct DetailGrid: View {
    let rows: [(String, String)]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 14) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                GridRow {
                    Text(row.0)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 100, alignment: .leading)
                    Text(row.1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Divider()
                    .gridCellColumns(2)
            }
        }
        .padding(.top, 4)
    }
}

#Preview {
    AcademyComparisonView()
}
