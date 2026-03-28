import Foundation

nonisolated struct DAForm705ExportData: Codable, Sendable {
    var soldierName: String
    var age: Int
    var sex: SoldierSex
    var standard: AFTStandard
    var mos: String
    var payGrade: String
    var unit: String
    var testDate: Date
    var testType: TestType
    var deadliftLbs: Int
    var pushUpReps: Int
    var sdcSeconds: Int
    var plankSeconds: Int
    var runSeconds: Int
    var deadliftPoints: Int
    var pushUpPoints: Int
    var sdcPoints: Int
    var plankPoints: Int
    var runPoints: Int
    var totalScore: Int
    var passed: Bool
    var height: String
    var weight: String
    var bodyFatPercent: String
    var bodyCompDate: String
    var oicName: String
    var oicDate: String
    var ncoicName: String
    var ncoicDate: String

    nonisolated enum TestType: String, Codable, CaseIterable, Identifiable, Sendable {
        case record = "Record"
        case practice = "Practice"
        case diagnostic = "Diagnostic"

        var id: String { rawValue }
    }

    init(from result: AFTCalculatorResult) {
        self.soldierName = result.soldierName
        self.age = result.age
        self.sex = result.sex
        self.standard = result.standard
        self.mos = ""
        self.payGrade = ""
        self.unit = ""
        self.testDate = result.date
        self.testType = .record
        self.deadliftLbs = result.deadliftLbs
        self.pushUpReps = result.pushUpReps
        self.sdcSeconds = result.sdcSeconds
        self.plankSeconds = result.plankSeconds
        self.runSeconds = result.runSeconds
        self.deadliftPoints = result.deadliftPoints
        self.pushUpPoints = result.pushUpPoints
        self.sdcPoints = result.sdcPoints
        self.plankPoints = result.plankPoints
        self.runPoints = result.runPoints
        self.totalScore = result.totalScore
        self.passed = result.passed
        self.height = ""
        self.weight = ""
        self.bodyFatPercent = ""
        self.bodyCompDate = ""
        self.oicName = ""
        self.oicDate = ""
        self.ncoicName = ""
        self.ncoicDate = ""
    }
}
