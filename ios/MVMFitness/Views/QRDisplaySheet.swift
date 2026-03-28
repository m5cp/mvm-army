import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRDisplaySheet: View {
    @Environment(\.dismiss) private var dismiss

    let plan: UnitPTPlan

    @State private var qrImage: UIImage?

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

                                ShareLink(item: plan.shareText) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.text")
                                        Text("Share Text")
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
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
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
        }
        .onAppear {
            generateQR()
        }
    }

    private func generateQR() {
        guard let data = plan.qrJSON else { return }

        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return }

        let scale = 260.0 / outputImage.extent.width
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return }
        qrImage = UIImage(cgImage: cgImage)
    }
}
