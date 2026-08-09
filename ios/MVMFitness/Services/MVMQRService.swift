import UIKit
import CoreImage.CIFilterBuiltins

/// One QR generator and one decoder for the whole app.
///
/// There were six separate `CIFilter.qrCodeGenerator()` call sites, three
/// payload shapes with no shared envelope, and a plan payload that nothing could
/// decode — so "Save to My Plans" was a dead button. Every code now carries a
/// unique id and a kind, so a scanner knows what it is holding, a rescan can be
/// recognised as a duplicate, and new kinds can be added without breaking old
/// codes.
enum MVMQRService {

    // MARK: - Envelope

    enum Kind: String, Codable {
        case appInvite      = "mvmAppInvite"
        case squadInvite    = "mvmSquadInvite"
        case squadStats     = "mvmSquadStats"
        case workout        = "mvmWorkout"
        case unitPTPlan     = "mvmUnitPTPlan"
        case weeklyPlan     = "mvmWeeklyPlan"
    }

    /// Wraps any payload with an identity so two otherwise-identical codes are
    /// still distinguishable, and a rescan of the SAME code is recognisable.
    struct Envelope: Codable {
        var v: Int = 2
        var kind: Kind
        /// Unique per generated code.
        var id: UUID = UUID()
        var createdAt: Date = .now
        /// The original payload, re-encoded.
        var body: Data
    }

    // MARK: - Generation

    /// Encodes a payload into a uniquely-identified envelope and renders it.
    static func makeCode<T: Encodable>(_ payload: T, kind: Kind) -> (image: UIImage?, id: UUID, json: String)? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let body = try? encoder.encode(payload) else { return nil }
        let envelope = Envelope(kind: kind, body: body)
        guard let data = try? encoder.encode(envelope),
              let json = String(data: data, encoding: .utf8) else { return nil }
        return (image(from: json), envelope.id, json)
    }

    /// An invite to the app itself — no personal data, just a pointer.
    static func appInvite() -> UIImage? {
        struct AppInvite: Codable {
            var app = "MVM Fitness"
            var url = AppLinks.appStoreURLString
        }
        return makeCode(AppInvite(), kind: .appInvite)?.image
    }

    /// Renders a string as a QR image. Single implementation for the whole app.
    static func image(from string: String, scale: CGFloat = 12) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        // Medium correction keeps the code readable when a camera sees it at an
        // angle without inflating the module count for large payloads.
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    // MARK: - Decoding

    /// Decodes a scanned string into a kind plus its raw body, handling both the
    /// v2 envelope and the older bare payloads that shipped before it.
    static func decode(_ scanned: String) -> (kind: Kind, id: UUID?, body: Data)? {
        guard let data = scanned.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let envelope = try? decoder.decode(Envelope.self, from: data) {
            return (envelope.kind, envelope.id, envelope.body)
        }

        // Legacy codes: a bare payload with a `kind` string and no envelope.
        struct LegacyProbe: Codable { let kind: String? }
        if let probe = try? JSONDecoder().decode(LegacyProbe.self, from: data),
           let raw = probe.kind,
           let kind = Kind(rawValue: raw) {
            return (kind, nil, data)
        }
        return nil
    }

    /// Convenience: decode straight to a concrete payload type.
    static func decode<T: Decodable>(_ scanned: String, as type: T.Type, kind expected: Kind) -> T? {
        guard let (kind, _, body) = decode(scanned), kind == expected else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let value = try? decoder.decode(type, from: body) { return value }
        // Legacy path: the body IS the payload.
        return try? JSONDecoder().decode(type, from: body)
    }
}
