import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ShareCardEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let baseImage: UIImage

    @State private var editedImage: UIImage?
    @State private var selectedFilter: ShareCardFilter = .none
    @State private var stickers: [StickerItem] = []
    @State private var showStickerPicker: Bool = false
    @State private var showPhotoSource: Bool = false
    @State private var showCamera: Bool = false
    @State private var overlayPhoto: UIImage?
    @State private var overlayOffset: CGSize = .zero
    @State private var overlayScale: CGFloat = 1.0
    @State private var overlayCorner: OverlayCorner = .topLeft
    @State private var photoMode: PhotoMode = .background
    @State private var showSavedToast: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var dragOffset: CGSize = .zero

    private let ciContext = CIContext()

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            cardPreview
                                .padding(.horizontal, 20)
                                .padding(.top, 12)

                            photoOverlaySection
                            filterSection
                            stickerSection
                        }
                        .padding(.bottom, 20)
                    }

                    actionBar
                }
            }
            .navigationTitle("Edit Share Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showStickerPicker) {
                StickerPickerSheet { sticker in
                    stickers.append(sticker)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        overlayPhoto = image
                    }
                }
            }
            .overlay {
                if showSavedToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(MVMTheme.success)
                            Text("Saved to Photos")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.bottom, 100)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSavedToast)
                }
            }
        }
        .onAppear {
            editedImage = baseImage
        }
    }

    private var cardPreview: some View {
        ZStack {
            if let img = compositeImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
            }
        }
    }

    private var compositeImage: UIImage? {
        guard let base = applyFilter(to: baseImage, filter: selectedFilter) else { return baseImage }

        let renderer = UIGraphicsImageRenderer(size: base.size)
        return renderer.image { ctx in
            if let photo = overlayPhoto, photoMode == .background {
                let filteredPhoto = applyFilter(to: photo, filter: selectedFilter) ?? photo
                let photoAspect = filteredPhoto.size.width / filteredPhoto.size.height
                let baseAspect = base.size.width / base.size.height
                let drawRect: CGRect
                if photoAspect > baseAspect {
                    let h = base.size.height
                    let w = h * photoAspect
                    drawRect = CGRect(x: (base.size.width - w) / 2, y: 0, width: w, height: h)
                } else {
                    let w = base.size.width
                    let h = w / photoAspect
                    drawRect = CGRect(x: 0, y: (base.size.height - h) / 2, width: w, height: h)
                }
                filteredPhoto.draw(in: drawRect)
                ctx.cgContext.setFillColor(UIColor.black.withAlphaComponent(0.45).cgColor)
                ctx.cgContext.fill(CGRect(origin: .zero, size: base.size))
                base.draw(at: .zero, blendMode: .screen, alpha: 0.85)
            } else {
                base.draw(at: .zero)
            }

            if let photo = overlayPhoto, photoMode == .overlay {
                let photoSize = CGSize(
                    width: base.size.width * overlayScale,
                    height: base.size.width * overlayScale * (photo.size.height / photo.size.width)
                )
                let margin: CGFloat = 40
                let origin: CGPoint
                switch overlayCorner {
                case .topLeft:
                    origin = CGPoint(x: margin, y: margin)
                case .topRight:
                    origin = CGPoint(x: base.size.width - photoSize.width - margin, y: margin)
                case .bottomLeft:
                    origin = CGPoint(x: margin, y: base.size.height - photoSize.height - margin)
                case .bottomRight:
                    origin = CGPoint(x: base.size.width - photoSize.width - margin, y: base.size.height - photoSize.height - margin)
                }

                let photoRect = CGRect(origin: origin, size: photoSize)
                let clipPath = UIBezierPath(roundedRect: photoRect, cornerRadius: 20)

                ctx.cgContext.saveGState()
                ctx.cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.3).cgColor)
                ctx.cgContext.setLineWidth(4)
                ctx.cgContext.addPath(clipPath.cgPath)
                ctx.cgContext.strokePath()

                clipPath.addClip()
                photo.draw(in: photoRect)
                ctx.cgContext.restoreGState()
            }

            for sticker in stickers {
                let stickerAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 80)
                ]
                let stickerStr = NSAttributedString(string: sticker.emoji, attributes: stickerAttrs)
                let x = sticker.position.x * base.size.width
                let y = sticker.position.y * base.size.height
                stickerStr.draw(at: CGPoint(x: x, y: y))
            }
        }
    }

    private var photoOverlaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PHOTO")
                .font(.caption.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        VStack(spacing: 6) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title3)
                                .foregroundStyle(MVMTheme.accent)
                                .frame(width: 56, height: 56)
                                .background(MVMTheme.accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            Text("Upload")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(MVMTheme.secondaryText)
                        }
                    }

                    Button {
                        showCamera = true
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "camera.fill")
                                .font(.title3)
                                .foregroundStyle(MVMTheme.accent)
                                .frame(width: 56, height: 56)
                                .background(MVMTheme.accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            Text("Selfie")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(MVMTheme.secondaryText)
                        }
                    }

                    if overlayPhoto != nil {
                        Button {
                            overlayPhoto = nil
                        } label: {
                            VStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.red)
                                    .frame(width: 56, height: 56)
                                    .background(.red.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                Text("Remove")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(MVMTheme.secondaryText)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .contentMargins(.horizontal, 4)

            if overlayPhoto != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("MODE")
                        .font(.caption2.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(MVMTheme.tertiaryText)

                    HStack(spacing: 8) {
                        ForEach(PhotoMode.allCases) { mode in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    photoMode = mode
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: mode.icon)
                                        .font(.caption2.weight(.bold))
                                    Text(mode.label)
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(photoMode == mode ? .white : MVMTheme.secondaryText)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(photoMode == mode ? MVMTheme.accent : MVMTheme.cardSoft)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if photoMode == .overlay {
                        Text("POSITION")
                            .font(.caption2.weight(.bold))
                            .tracking(0.8)
                            .foregroundStyle(MVMTheme.tertiaryText)
                            .padding(.top, 4)

                        HStack(spacing: 8) {
                            ForEach(OverlayCorner.allCases) { corner in
                                Button {
                                    overlayCorner = corner
                                } label: {
                                    Text(corner.label)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(overlayCorner == corner ? .white : MVMTheme.secondaryText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(overlayCorner == corner ? MVMTheme.accent : MVMTheme.cardSoft)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        HStack(spacing: 12) {
                            Text("Size")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MVMTheme.secondaryText)
                            Slider(value: $overlayScale, in: 0.15...0.5)
                                .tint(MVMTheme.accent)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraOverlayView { image in
                overlayPhoto = image
            }
        }
    }

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FILTERS")
                .font(.caption.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(MVMTheme.tertiaryText)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(ShareCardFilter.allCases) { filter in
                        filterButton(filter)
                    }
                }
                .padding(.horizontal, 20)
            }
            .contentMargins(.horizontal, 4)
        }
    }

    private func filterButton(_ filter: ShareCardFilter) -> some View {
        let isSelected = selectedFilter == filter
        let thumbnail = applyFilter(to: baseImage, filter: filter)

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedFilter = filter
            }
        } label: {
            VStack(spacing: 6) {
                if let thumb = thumbnail {
                    Image(uiImage: thumb)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? MVMTheme.accent : Color.clear, lineWidth: 2)
                        }
                }
                Text(filter.displayName)
                    .font(.caption2.weight(isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? MVMTheme.accent : MVMTheme.tertiaryText)
            }
        }
        .buttonStyle(.plain)
    }

    private var stickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("STICKERS")
                    .font(.caption.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(MVMTheme.tertiaryText)

                Spacer()

                if !stickers.isEmpty {
                    Button {
                        stickers.removeAll()
                    } label: {
                        Text("Clear All")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(quickStickers, id: \.self) { emoji in
                        Button {
                            let randomX = Double.random(in: 0.2...0.7)
                            let randomY = Double.random(in: 0.2...0.7)
                            stickers.append(StickerItem(emoji: emoji, position: CGPoint(x: randomX, y: randomY)))
                        } label: {
                            Text(emoji)
                                .font(.system(size: 28))
                                .frame(width: 48, height: 48)
                                .background(MVMTheme.cardSoft)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        showStickerPicker = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(MVMTheme.accent)
                            .frame(width: 48, height: 48)
                            .background(MVMTheme.accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
            }
            .contentMargins(.horizontal, 4)
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            if let final = compositeImage {
                ShareLink(
                    item: Image(uiImage: final),
                    preview: SharePreview("MVM Fitness", image: Image(uiImage: final))
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            Button {
                if let final = compositeImage {
                    UIImageWriteToSavedPhotosAlbum(final, nil, nil, nil)
                    showSavedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSavedToast = false
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Save")
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(MVMTheme.accent)
                .frame(height: 52)
                .frame(maxWidth: .infinity)
                .background(MVMTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(MVMTheme.background)
    }

    private func applyFilter(to image: UIImage, filter: ShareCardFilter) -> UIImage? {
        guard filter != .none else { return image }
        guard let ciImage = CIImage(image: image) else { return image }

        let filtered: CIImage?
        switch filter {
        case .none:
            return image
        case .vivid:
            let f = CIFilter.colorControls()
            f.inputImage = ciImage
            f.saturation = 1.4
            f.contrast = 1.1
            f.brightness = 0.02
            filtered = f.outputImage
        case .cool:
            let f = CIFilter.temperatureAndTint()
            f.inputImage = ciImage
            f.neutral = CIVector(x: 5500, y: 0)
            f.targetNeutral = CIVector(x: 7500, y: 0)
            filtered = f.outputImage
        case .warm:
            let f = CIFilter.temperatureAndTint()
            f.inputImage = ciImage
            f.neutral = CIVector(x: 6500, y: 0)
            f.targetNeutral = CIVector(x: 4500, y: 0)
            filtered = f.outputImage
        case .noir:
            let f = CIFilter.photoEffectNoir()
            f.inputImage = ciImage
            filtered = f.outputImage
        case .chrome:
            let f = CIFilter.photoEffectChrome()
            f.inputImage = ciImage
            filtered = f.outputImage
        case .fade:
            let f = CIFilter.photoEffectFade()
            f.inputImage = ciImage
            filtered = f.outputImage
        case .dramatic:
            let controls = CIFilter.colorControls()
            controls.inputImage = ciImage
            controls.contrast = 1.3
            controls.brightness = -0.05
            controls.saturation = 0.8
            filtered = controls.outputImage
        }

        guard let output = filtered,
              let cgImage = ciContext.createCGImage(output, from: output.extent) else { return image }
        return UIImage(cgImage: cgImage)
    }

    private let quickStickers = [
        "\u{1F4AA}", "\u{1F525}", "\u{2B50}", "\u{1F3C6}", "\u{1F1FA}\u{1F1F8}",
        "\u{26A1}", "\u{1F4AF}", "\u{1F396}", "\u{1F6E1}", "\u{2694}\u{FE0F}",
        "\u{1F3CB}\u{FE0F}", "\u{1F947}"
    ]
}

nonisolated enum ShareCardFilter: String, CaseIterable, Identifiable, Sendable {
    case none = "Original"
    case vivid = "Vivid"
    case cool = "Cool"
    case warm = "Warm"
    case noir = "Noir"
    case chrome = "Chrome"
    case fade = "Fade"
    case dramatic = "Dramatic"

    var id: String { rawValue }
    var displayName: String { rawValue }
}

nonisolated enum PhotoMode: String, CaseIterable, Identifiable, Sendable {
    case background = "Background"
    case overlay = "Overlay"

    var id: String { rawValue }
    var label: String { rawValue }
    var icon: String {
        switch self {
        case .background: return "photo.fill"
        case .overlay: return "square.on.square"
        }
    }
}

nonisolated enum OverlayCorner: String, CaseIterable, Identifiable, Sendable {
    case topLeft = "Top Left"
    case topRight = "Top Right"
    case bottomLeft = "Bottom Left"
    case bottomRight = "Bottom Right"

    var id: String { rawValue }
    var label: String { rawValue }
}

struct StickerItem: Identifiable {
    let id = UUID()
    let emoji: String
    var position: CGPoint
}

struct StickerPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSelect: (StickerItem) -> Void

    private let categories: [(String, [String])] = [
        ("Fitness", ["\u{1F4AA}", "\u{1F3CB}\u{FE0F}", "\u{1F3C3}", "\u{1F9D8}", "\u{26BD}", "\u{1F3C0}", "\u{1F3C8}", "\u{1F6B4}", "\u{1F3CA}", "\u{1F94A}", "\u{1F93C}", "\u{1F938}"]),
        ("Military", ["\u{1F396}", "\u{1F3C5}", "\u{1F6E1}", "\u{2694}\u{FE0F}", "\u{1F1FA}\u{1F1F8}", "\u{1FA96}", "\u{1F9ED}", "\u{2B50}", "\u{1F31F}", "\u{2728}", "\u{1F4AB}", "\u{1F3AF}"]),
        ("Celebration", ["\u{1F525}", "\u{1F4AF}", "\u{1F947}", "\u{1F3C6}", "\u{26A1}", "\u{1F389}", "\u{1F38A}", "\u{1F386}", "\u{1F60E}", "\u{1F929}", "\u{1F4A5}", "\u{2705}"]),
        ("Motivation", ["\u{2764}\u{FE0F}", "\u{1F49A}", "\u{1F499}", "\u{1F4A8}", "\u{1F680}", "\u{1F3F3}\u{FE0F}", "\u{1F4AA}", "\u{1F9BE}", "\u{1FAE1}", "\u{270C}\u{FE0F}", "\u{1F44A}", "\u{1F91C}"])
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(categories, id: \.0) { category, emojis in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(category.uppercased())
                                    .font(.caption.weight(.bold))
                                    .tracking(1.0)
                                    .foregroundStyle(MVMTheme.tertiaryText)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                                    ForEach(emojis, id: \.self) { emoji in
                                        Button {
                                            let randomX = Double.random(in: 0.15...0.7)
                                            let randomY = Double.random(in: 0.15...0.7)
                                            onSelect(StickerItem(emoji: emoji, position: CGPoint(x: randomX, y: randomY)))
                                            dismiss()
                                        } label: {
                                            Text(emoji)
                                                .font(.system(size: 32))
                                                .frame(width: 50, height: 50)
                                                .background(MVMTheme.cardSoft)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
            }
            .navigationTitle("Stickers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(MVMTheme.background)
    }
}

struct CameraOverlayView: View {
    @Environment(\.dismiss) private var dismiss

    let onCapture: (UIImage) -> Void

    var body: some View {
        ZStack {
            MVMTheme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Camera Preview")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Install this app on your device\nvia the Rork App to use the camera.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    dismiss()
                } label: {
                    Text("Close")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 48)
                        .background(MVMTheme.heroGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(PressScaleButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
