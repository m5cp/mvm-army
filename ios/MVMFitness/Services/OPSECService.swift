import Foundation
import SwiftUI

/// Operational security controls.
///
/// This app is used by service members whose location patterns, unit
/// affiliation and roster are sensitive. In 2018 a fitness app's global activity
/// heatmap exposed the layout and patrol patterns of forward operating bases —
/// from nothing more than people running with tracking on. That failure mode is
/// the reason these switches exist and default the way they do.
///
/// The app has no backend. Nothing here talks to a server, so training data
/// never leaves the device except through iCloud sync and whatever the user
/// deliberately shares. OPSEC mode closes both of those doors.
@MainActor
@Observable
final class OPSECService {
    static let shared = OPSECService()

    private enum Keys {
        static let opsecMode = "opsecModeEnabled"
        static let gpsDisabled = "opsecDisableGPS"
        static let iCloudDisabled = "opsecDisableCloudSync"
        static let stripIdentity = "opsecStripIdentityFromShares"
    }

    private let defaults = UserDefaults.standard

    /// @Observable rewrites stored properties into computed accessors, so
    /// assignments in init() DO fire didSet — unlike a plain class. Without this
    /// guard the master-switch cascade ran during load and rewrote every
    /// sub-toggle before it had been read, so a deliberately re-enabled GPS
    /// could never survive a relaunch.
    private var isLoading = true

    init() {
        opsecMode = defaults.bool(forKey: Keys.opsecMode)
        gpsDisabled = defaults.bool(forKey: Keys.gpsDisabled)
        iCloudDisabled = defaults.bool(forKey: Keys.iCloudDisabled)
        stripIdentity = defaults.bool(forKey: Keys.stripIdentity)
        isLoading = false
    }

    /// Master switch. Turning it on enables every individual control; turning it
    /// off leaves the individual controls where the user set them, so a
    /// deliberate choice is never silently undone.
    var opsecMode: Bool = false {
        didSet {
            defaults.set(opsecMode, forKey: Keys.opsecMode)
            if opsecMode, !isLoading {
                gpsDisabled = true
                iCloudDisabled = true
                stripIdentity = true
            }
        }
    }

    /// No route is recorded and no location permission is requested. Sessions
    /// still time, still count, and still use the pedometer for distance.
    var gpsDisabled: Bool = false {
        didSet {
            defaults.set(gpsDisabled, forKey: Keys.gpsDisabled)
            // Hiding the map is not enough. Without this, switching OPSEC on
            // mid-run told the user there was no GPS while the route kept
            // recording and was still saved at the end.
            if gpsDisabled, !isLoading {
                NotificationCenter.default.post(name: .opsecGPSDisabled, object: nil)
            }
        }
    }

    /// Nothing is mirrored to iCloud. Everything stays in this device's
    /// Application Support container.
    var iCloudDisabled: Bool = false {
        didSet {
            defaults.set(iCloudDisabled, forKey: Keys.iCloudDisabled)
            // Stopping future mirroring is not enough — everything synced up to
            // now is still sitting in the ubiquity container, which is exactly
            // the data this switch is meant to remove.
            if iCloudDisabled, !isLoading { DataStore.purgeAllKeysFromCloud() }
        }
    }

    /// Name, rank and unit are omitted from share cards, exported PDFs and QR
    /// payloads. Scores still share; the person and the unit do not.
    var stripIdentity: Bool = false {
        didSet { defaults.set(stripIdentity, forKey: Keys.stripIdentity) }
    }

    /// Name to print on a shared artifact, or empty when identity is stripped.
    func shareName(_ name: String) -> String {
        stripIdentity ? "" : name
    }

    /// Static read for non-observable contexts (DataStore's io queue).
    nonisolated static var isCloudSyncDisabled: Bool {
        UserDefaults.standard.bool(forKey: "opsecDisableCloudSync")
    }

    nonisolated static var isGPSDisabled: Bool {
        UserDefaults.standard.bool(forKey: "opsecDisableGPS")
    }
}


extension Notification.Name {
    /// Posted when GPS is switched off, so any live session stops recording.
    static let opsecGPSDisabled = Notification.Name("mvm.opsec.gpsDisabled")
}
