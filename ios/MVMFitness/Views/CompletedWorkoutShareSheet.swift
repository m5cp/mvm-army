import SwiftUI
import UIKit

struct CompletedWorkoutShareSheet: View {
    let record: CompletedWorkoutRecord
    @Environment(\.dismiss) private var dismiss
    @State private var renderedImage: UIImage?
    @State private var showSavedToast: Bool = false
    @State private var showEditor: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if let image = renderedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
                                .padding(.horizontal, 30)
                        } else {
                            ProgressView()
                                .tint(.white)
                                .frame(height: 300)
                        }

                        HStack(spacing: 12) {
                            Button {
                                if let image = renderedImage {
                                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
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
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(height: 52)
                                .frame(maxWidth: .infinity)
                                .background(MVMTheme.heroGradient)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(PressScaleButtonStyle())
                            .disabled(renderedImage == nil)

                            Button {
                                showEditor = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "slider.horizontal.3")
                                    Text("Edit")
                                }
                                .font(.headline)
                                .foregroundStyle(MVMTheme.accent)
                                .frame(height: 52)
                                .frame(maxWidth: .infinity)
                                .background(MVMTheme.accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(PressScaleButtonStyle())
                            .disabled(renderedImage == nil)
                        }
                        .padding(.horizontal, 20)

                        Button {
                            if let image = renderedImage {
                                let text = "MVM Fitness \u{2014} \(record.title)\n\(record.exerciseCount) exercises\n#MVMFitness #ArmyFitness"
                                let activityVC = UIActivityViewController(activityItems: [image, text], applicationActivities: nil)
                                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                      let rootVC = windowScene.windows.first?.rootViewController else { return }
                                var presenter = rootVC
                                while let presented = presenter.presentedViewController {
                                    presenter = presented
                                }
                                if let popover = activityVC.popoverPresentationController {
                                    popover.sourceView = presenter.view
                                    popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
                                    popover.permittedArrowDirections = []
                                }
                                presenter.present(activityVC, animated: true)
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.headline)
                            .foregroundStyle(MVMTheme.accent)
                            .frame(height: 52)
                            .frame(maxWidth: .infinity)
                            .background(MVMTheme.accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                        .padding(.horizontal, 20)
                        .disabled(renderedImage == nil)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Share Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(MVMTheme.accent)
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
                        .padding(.bottom, 40)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSavedToast)
                }
            }
            .task {
                renderedImage = ShareCardRenderer.renderImage(
                    cardType: .completedWorkout(record: record),
                    date: record.date
                )
            }
            .sheet(isPresented: $showEditor) {
                if let image = renderedImage {
                    ShareCardEditorView(baseImage: image)
                }
            }
        }
    }
}
