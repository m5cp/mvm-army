import UIKit
import PDFKit

enum DAForm705PDFService {

    static func generatePDF(from data: DAForm705ExportData) -> Data? {
        guard let templateURL = Bundle.main.url(forResource: "DA_Form_705_Army_Fitness_Test", withExtension: "pdf"),
              let document = PDFDocument(url: templateURL) else {
            return nil
        }

        fillSoldierInfo(in: document, data: data)
        fillTestOneFields(in: document, data: data)

        return document.dataRepresentation()
    }

    static func savePDFToTemp(data: Data, soldierName: String) -> URL? {
        let sanitized = soldierName.isEmpty ? "Soldier" : soldierName.replacingOccurrences(of: " ", with: "_")
        let dateStr = DateFormatter.shortFileDate.string(from: .now)
        let fileName = "DA_Form_705_\(sanitized)_\(dateStr).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private static func fillSoldierInfo(in document: PDFDocument, data: DAForm705ExportData) {
        setTextField(in: document, fieldName: "Name", value: data.soldierName)
        setTextField(in: document, fieldName: "Unit_Location", value: data.unit)

        if data.sex == .male {
            setCheckbox(in: document, fieldName: "Male", checked: true)
        } else {
            setCheckbox(in: document, fieldName: "Female", checked: true)
        }

        if data.standard == .combat {
            setCheckbox(in: document, fieldName: "Check_Standard_Combat", checked: true)
        } else {
            setCheckbox(in: document, fieldName: "Check_Standard_General", checked: true)
        }
    }

    private static func fillTestOneFields(in document: PDFDocument, data: DAForm705ExportData) {
        setTextField(in: document, fieldName: "Test_One_Age", value: "\(data.age)")
        setTextField(in: document, fieldName: "Test_One_MOS", value: data.mos)
        setTextField(in: document, fieldName: "Test_One_Rank_Grade", value: data.payGrade)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        setTextField(in: document, fieldName: "Test_One_Date", value: dateFormatter.string(from: data.testDate))

        setTextField(in: document, fieldName: "Test_One_First_Attempt", value: "\(data.deadliftLbs)")
        setTextField(in: document, fieldName: "Test_One_Points1", value: "\(data.deadliftPoints)")

        setTextField(in: document, fieldName: "Test_One_Repetitions", value: "\(data.pushUpReps)")
        setTextField(in: document, fieldName: "Test_One_Points3", value: "\(data.pushUpPoints)")

        setTextField(in: document, fieldName: "Test_One_Time1", value: formatTime(data.sdcSeconds))
        setTextField(in: document, fieldName: "Test_One_Points4", value: "\(data.sdcPoints)")

        setTextField(in: document, fieldName: "Test_One_Time2", value: formatTime(data.plankSeconds))
        setTextField(in: document, fieldName: "Test_One_Points5", value: "\(data.plankPoints)")

        setTextField(in: document, fieldName: "Test_One_Time3", value: formatTime(data.runSeconds))
        setTextField(in: document, fieldName: "Test_One_Points6", value: "\(data.runPoints)")

        setTextField(in: document, fieldName: "Test_One_Total_Points", value: "\(data.totalScore)")

        if data.passed {
            setCheckbox(in: document, fieldName: "Test_One_Go", checked: true)
            setCheckbox(in: document, fieldName: "Test_One_Final_Go", checked: true)
        } else {
            setCheckbox(in: document, fieldName: "Test_One_NoGo", checked: true)
            setCheckbox(in: document, fieldName: "Test_One_Final_NoGo", checked: true)
        }

        if !data.height.isEmpty {
            setTextField(in: document, fieldName: "Test_One_Height", value: data.height)
        }
        if !data.weight.isEmpty {
            setTextField(in: document, fieldName: "Test_One_Weight", value: data.weight)
        }
        if !data.bodyFatPercent.isEmpty {
            setTextField(in: document, fieldName: "Test_One_Body_Fat", value: data.bodyFatPercent)
        }
        if !data.bodyCompDate.isEmpty {
            setTextField(in: document, fieldName: "Test_One_Body_Composition_Date", value: data.bodyCompDate)
        }

        if !data.oicName.isEmpty {
            setTextField(in: document, fieldName: "OIC_NCOIC_Name_Test_One", value: data.oicName)
        }
        if !data.ncoicName.isEmpty {
            setTextField(in: document, fieldName: "OIC_NCOIC_Rank_Grade_Test_One", value: data.ncoicName)
        }
        if !data.oicDate.isEmpty {
            setTextField(in: document, fieldName: "OIC_NCOIC_Date_Test_One", value: data.oicDate)
        }

        let soldierDateStr = dateFormatter.string(from: data.testDate)
        setTextField(in: document, fieldName: "Signature_Soldier_Date_Test_One", value: soldierDateStr)
    }

    // MARK: - Field Helpers

    private static func setTextField(in document: PDFDocument, fieldName: String, value: String) {
        guard !value.isEmpty else { return }
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }
            for annotation in page.annotations {
                if annotation.fieldName == fieldName && annotation.widgetFieldType == .text {
                    annotation.widgetStringValue = value
                    return
                }
            }
        }
    }

    private static func setCheckbox(in document: PDFDocument, fieldName: String, checked: Bool) {
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }
            for annotation in page.annotations {
                if annotation.fieldName == fieldName && annotation.widgetFieldType == .button {
                    annotation.buttonWidgetState = checked ? .onState : .offState
                    return
                }
            }
        }
    }

    private static func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private extension DateFormatter {
    static let shortFileDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f
    }()
}
