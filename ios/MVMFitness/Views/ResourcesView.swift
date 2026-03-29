import SwiftUI
import PDFKit

struct ResourcesView: View {
    @State private var selectedPDF: PDFResource?

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(PDFResource.allCases) { resource in
                        Button {
                            selectedPDF = resource
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: resource.icon)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(MVMTheme.accent)
                                    .frame(width: 40, height: 40)
                                    .background(MVMTheme.accent.opacity(0.12))
                                    .clipShape(.rect(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(resource.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(MVMTheme.primaryText)
                                        .multilineTextAlignment(.leading)
                                    Text(resource.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(MVMTheme.tertiaryText)
                                }

                                Spacer(minLength: 0)

                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
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
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .adaptiveContainer()
            }
        }
        .navigationTitle("Resources")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(MVMTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .fullScreenCover(item: $selectedPDF) { resource in
            PDFViewerScreen(resource: resource)
        }
    }
}

nonisolated enum PDFResource: String, CaseIterable, Identifiable {
    case scoringScales
    case daForm705
    case atp7_22_02

    nonisolated var id: String { rawValue }

    @MainActor
    var title: String {
        switch self {
        case .scoringScales: return "AFT Scoring Scales"
        case .daForm705: return "DA Form 705"
        case .atp7_22_02: return "ATP 7-22.02 Holistic Health & Fitness"
        }
    }

    @MainActor
    var subtitle: String {
        switch self {
        case .scoringScales: return "Army Fitness Test scoring tables"
        case .daForm705: return "Army Physical Fitness Test scorecard"
        case .atp7_22_02: return "H2F training doctrine"
        }
    }

    @MainActor
    var icon: String {
        switch self {
        case .scoringScales: return "tablecells"
        case .daForm705: return "doc.richtext"
        case .atp7_22_02: return "book.fill"
        }
    }

    @MainActor
    var fileName: String {
        switch self {
        case .scoringScales: return "Scoring_Scales_Army_Fitness_Test"
        case .daForm705: return "DA_Form_705_Army_Fitness_Test"
        case .atp7_22_02: return "ATP_7_22_02_Holistic_Health_Fitness"
        }
    }
}

struct PDFViewerScreen: View {
    let resource: PDFResource
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                if let url = Bundle.main.url(forResource: resource.fileName, withExtension: "pdf") {
                    PDFKitView(url: url)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.questionmark")
                            .font(.system(size: 40))
                            .foregroundStyle(MVMTheme.tertiaryText)
                        Text("PDF not found")
                            .font(.headline)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                }
            }
            .navigationTitle(resource.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(MVMTheme.secondaryText)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if let url = Bundle.main.url(forResource: resource.fileName, withExtension: "pdf") {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(MVMTheme.accent)
                        }
                    }
                }
            }
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = UIColor(MVMTheme.background)
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
