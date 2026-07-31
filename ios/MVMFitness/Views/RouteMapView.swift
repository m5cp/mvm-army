import SwiftUI
import MapKit

/// Full-screen route view (Apple Fitness style): tap any route thumbnail to
/// open the whole track with pinch/pan, a Map / Satellite / Hybrid style
/// switcher, and the session stats on a floating plate.
struct RouteMapView: View {
    let record: QuickStartRecord
    @Environment(\.dismiss) private var dismiss

    private enum RouteMapStyle: String, CaseIterable, Identifiable {
        case standard = "Map"
        case hybrid = "Hybrid"
        case imagery = "Satellite"
        var id: String { rawValue }

        var mapStyle: MapStyle {
            switch self {
            case .standard: return .standard(elevation: .realistic)
            case .hybrid: return .hybrid(elevation: .realistic)
            case .imagery: return .imagery(elevation: .realistic)
            }
        }
    }

    @State private var styleChoice: RouteMapStyle = .standard
    @State private var position: MapCameraPosition = .automatic

    private var coords: [CLLocationCoordinate2D] {
        record.routeCoordinates.map(\.clCoordinate)
    }

    private struct MileMarker: Identifiable {
        let id: Int          // mile number
        let coordinate: CLLocationCoordinate2D
        let splitLabel: String?  // "8:42" split for that mile, when timing exists
    }

    /// Apple Fitness-style mile pins: positioned every 1609.34 m along the
    /// route; per-mile split times when the record carries time offsets
    /// (older records show the pin without a time).
    private var mileMarkers: [MileMarker] {
        let coordList = coords
        guard coordList.count > 1 else { return [] }
        let offsets = record.routeTimeOffsets
        let hasTimes = offsets?.count == coordList.count

        var markers: [MileMarker] = []
        var cumulative: Double = 0
        var nextMile: Double = 1609.34
        var mileIndex = 1
        var lastMileTime: Double = 0

        for i in 1..<coordList.count {
            let a = CLLocation(latitude: coordList[i - 1].latitude, longitude: coordList[i - 1].longitude)
            let b = CLLocation(latitude: coordList[i].latitude, longitude: coordList[i].longitude)
            let delta = a.distance(from: b)
            guard delta > 0, delta < 200 else { continue }
            cumulative += delta

            while cumulative >= nextMile {
                var split: String?
                if hasTimes, let offsets {
                    let t = offsets[i]
                    let mileSeconds = t - lastMileTime
                    if mileSeconds > 0 {
                        split = String(format: "%d:%02d", Int(mileSeconds) / 60, Int(mileSeconds) % 60)
                    }
                    lastMileTime = t
                }
                markers.append(MileMarker(id: mileIndex, coordinate: coordList[i], splitLabel: split))
                mileIndex += 1
                nextMile += 1609.34
            }
        }
        return markers
    }

    /// Region fitted around the whole route with a comfortable margin.
    private var fittedRegion: MKCoordinateRegion? {
        guard let first = coords.first else { return nil }
        var minLat = first.latitude, maxLat = first.latitude
        var minLon = first.longitude, maxLon = first.longitude
        for c in coords {
            minLat = min(minLat, c.latitude); maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
        }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2),
            span: MKCoordinateSpan(
                latitudeDelta: max((maxLat - minLat) * 1.4, 0.004),
                longitudeDelta: max((maxLon - minLon) * 1.4, 0.004)
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $position) {
                    if coords.count > 1 {
                        MapPolyline(coordinates: coords)
                            .stroke(MVMTheme.amber, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    }

                    if let first = coords.first {
                        Annotation("Start", coordinate: first) {
                            Circle()
                                .fill(MVMTheme.success)
                                .frame(width: 14, height: 14)
                                .overlay { Circle().stroke(.white, lineWidth: 2.5) }
                        }
                    }

                    if let last = coords.last, coords.count > 1 {
                        Annotation("Finish", coordinate: last) {
                            Circle()
                                .fill(MVMTheme.danger)
                                .frame(width: 14, height: 14)
                                .overlay { Circle().stroke(.white, lineWidth: 2.5) }
                        }
                    }

                    ForEach(mileMarkers) { marker in
                        Annotation("", coordinate: marker.coordinate) {
                            VStack(spacing: 1) {
                                Text("MI \(marker.id)")
                                    .font(.system(size: 9, weight: .heavy))
                                if let split = marker.splitLabel {
                                    Text(split)
                                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                }
                            }
                            .foregroundStyle(MVMTheme.onAmber)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(MVMTheme.amber)
                            .clipShape(Capsule())
                            .overlay { Capsule().stroke(.white.opacity(0.8), lineWidth: 1) }
                        }
                    }
                }
                .mapStyle(styleChoice.mapStyle)
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 12) {
                    stylePicker
                    statsPlate
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .navigationTitle(record.activity.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(MVMTheme.accent)
                }
            }
            .onAppear {
                if let region = fittedRegion {
                    position = .region(region)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var stylePicker: some View {
        HStack(spacing: 3) {
            ForEach(RouteMapStyle.allCases) { style in
                let selected = styleChoice == style
                Text(style.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(selected ? MVMTheme.onAmber : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(selected ? AnyShapeStyle(MVMTheme.amberButtonGradient) : AnyShapeStyle(.clear))
                    .clipShape(Capsule())
                    .contentShape(Capsule())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            styleChoice = style
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(style.rawValue) view")
                    .accessibilityAddTraits(selected ? [.isButton, .isSelected] : [.isButton])
            }
        }
        .padding(3)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    private var statsPlate: some View {
        HStack(spacing: 0) {
            routeStat(label: "DISTANCE", value: record.formattedDistance)
            statDivider
            routeStat(label: "DURATION", value: record.formattedDuration)
            statDivider
            routeStat(label: "AVG PACE", value: record.formattedPace)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        }
    }

    private func routeStat(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(MVMTheme.mono(9))
                .kerning(1.1)
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(1)
                .fixedSize()
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .fixedSize()
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.15))
            .frame(width: 1, height: 28)
    }
}
