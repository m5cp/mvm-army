import SwiftUI
import CoreImage.CIFilterBuiltins

struct WorkoutQRSheet: View {
    @Environment(\.dismiss) private var dismiss

    let workout: WorkoutDay
    let workoutType: String

    @State private var qrImage: UIImage?
    @State private var showSavedAlert = false
    @State private var shareItems: [Any] = []
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        qrCard
                        if qrImage != nil {
                            actionButtons
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                    .adaptiveContainer()
                }
            }
            .navigationTitle("Share QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Saved", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("QR code saved to your photo library.")
            }
            .sheet(isPresented: $showShareSheet) {
                if !shareItems.isEmpty {
                    ShareSheet(items: shareItems)
                }
            }
        }
        .onAppear {
            generateQR()
        }
    }

    private var qrCard: some View {
        VStack(spacing: 16) {
            if let qrImage {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                    .padding(20)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(MVMTheme.accent)
                    Text("Generating QR...")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }
                .frame(width: 240, height: 240)
            }

            VStack(spacing: 6) {
                Text(workout.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(MVMTheme.primaryText)
                    .multilineTextAlignment(.center)

                Text("\(workout.exercises.count) exercises · \(workoutType)")
                    .font(.subheadline)
                    .foregroundStyle(MVMTheme.secondaryText)
            }

            Text("Scan with MVM Army to import this workout")
                .font(.caption)
                .foregroundStyle(MVMTheme.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .premiumCard()
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                if let qrImage {
                    ShareLink(
                        item: Image(uiImage: qrImage),
                        preview: SharePreview(workout.title, image: Image(uiImage: qrImage))
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share QR")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 52)
                        .frame(maxWidth: .infinity)
                        .background(MVMTheme.heroGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }

                Button {
                    if let qrImage {
                        UIImageWriteToSavedPhotosAlbum(qrImage, nil, nil, nil)
                        showSavedAlert = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 52)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#2563EB"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            Button {
                let card = ShareCardRenderer.shareItems(
                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                )
                shareItems = card
                showShareSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "photo")
                    Text("Share as Card")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MVMTheme.accent)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(MVMTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    private func generateQR() {
        let payload = WorkoutQRPayload(from: workout, type: workoutType)
        guard let data = payload.compactJSON else { return }

        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "L"

        guard let outputImage = filter.outputImage else { return }

        let scale = 240.0 / outputImage.extent.width
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return }
        qrImage = UIImage(cgImage: cgImage)
    }
}
