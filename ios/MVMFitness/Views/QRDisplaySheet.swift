import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRDisplaySheet: View {
    @Environment(\.dismiss) private var dismiss

    let plan: UnitPTPlan

    @State private var qrImage: UIImage?
    @State private var showSavedAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            if let qrImage {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 260, height: 260)
                                    .padding(20)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            } else {
                                ProgressView()
                                    .frame(width: 260, height: 260)
                            }

                            Text(plan.title)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(MVMTheme.primaryText)

                            Text("Scan to view PT session")
                                .font(.subheadline)
                                .foregroundStyle(MVMTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .premiumCard()

                        if let qrImage {
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    ShareLink(
                                        item: Image(uiImage: qrImage),
                                        preview: SharePreview(plan.title, image: Image(uiImage: qrImage))
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

                                    Button {
                                        saveImageToPhotos(qrImage)
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "square.and.arrow.down")
                                            Text("Save Image")
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

                                ShareLink(item: plan.shareText) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.text")
                                        Text("Share as Text")
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
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                    .adaptiveContainer()
                }
            }
            .navigationTitle("QR Code")
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
        }
        .onAppear {
            generateQR()
        }
    }

    private func generateQR() {
        let payload = UnitPTQRCodePayload(from: plan)
        guard let data = payload.compactJSON else { return }

        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "L"

        guard let outputImage = filter.outputImage else { return }

        let scale = 260.0 / outputImage.extent.width
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return }
        qrImage = UIImage(cgImage: cgImage)
    }

    private func saveImageToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSavedAlert = true
    }
}
