import SwiftUI
import AVFoundation

struct QRScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var scannedPlan: UnitPTPlan?
    @State private var scannedWorkout: WorkoutDay?
    @State private var errorMessage: String?
    @State private var savedConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                MVMTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if scannedPlan == nil && scannedWorkout == nil {
                            cameraSection
                        }

                        if let scannedPlan {
                            importedPlanCard(scannedPlan)
                        }

                        if let scannedWorkout {
                            importedWorkoutCard(scannedWorkout)
                        }

                        if let errorMessage {
                            errorCard(errorMessage)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                    .adaptiveContainer()
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Scan Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(MVMTheme.primaryText)
                }
            }
            .toolbarBackground(MVMTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sensoryFeedback(.success, trigger: savedConfirmation)
        }
    }

    private var cameraSection: some View {
        VStack(spacing: 0) {
            #if targetEnvironment(simulator)
            cameraUnavailablePlaceholder
            #else
            if AVCaptureDevice.default(for: .video) != nil {
                QRCameraView { code in
                    handleScannedCode(code)
                }
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(MVMTheme.border)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(MVMTheme.accent.opacity(0.6), lineWidth: 2)
                        .frame(width: 200, height: 200)
                }
            } else {
                cameraUnavailablePlaceholder
            }
            #endif
        }
    }

    private var cameraUnavailablePlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 48))
                .foregroundStyle(MVMTheme.accent)

            Text("Camera Preview")
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("Install this app on your device via the Rork App to use the camera for QR scanning.")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .premiumCard()
    }

    private func importedPlanCard(_ plan: UnitPTPlan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(MVMTheme.success)
                Text("Imported PT Plan")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.success)
            }

            Text(plan.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text(plan.objective)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)

            if !plan.equipment.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.caption)
                        .foregroundStyle(MVMTheme.accent)
                    Text(plan.equipment)
                        .font(.caption)
                        .foregroundStyle(MVMTheme.secondaryText)
                }
            }

            Text("\(plan.mainEffort.count) exercise blocks")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.accent)

            if !plan.mainEffort.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(plan.mainEffort.prefix(5).enumerated()), id: \.element.id) { index, block in
                        Text("\(index + 1). \(block.description)")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.secondaryText)
                            .lineLimit(2)
                    }
                    if plan.mainEffort.count > 5 {
                        Text("+ \(plan.mainEffort.count - 5) more...")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(MVMTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                vm.unitPTPlans.insert(plan, at: 0)
                vm.persistAll()
                savedConfirmation.toggle()
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down.on.square")
                    Text("Save to My Plans")
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
                scannedPlan = nil
                scannedWorkout = nil
                errorMessage = nil
            } label: {
                Text("Scan Another")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(18)
        .premiumCard()
    }

    private func importedWorkoutCard(_ workout: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(MVMTheme.success)
                Text("Imported Workout")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.success)
            }

            Text(workout.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(MVMTheme.primaryText)

            Text("\(workout.exercises.count) exercises")
                .font(.subheadline)
                .foregroundStyle(MVMTheme.accent)

            if !workout.exercises.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(workout.exercises.prefix(5).enumerated()), id: \.element.id) { index, exercise in
                        Text("\(index + 1). \(exercise.name) — \(exercise.displayDetail)")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.secondaryText)
                            .lineLimit(2)
                    }
                    if workout.exercises.count > 5 {
                        Text("+ \(workout.exercises.count - 5) more...")
                            .font(.caption)
                            .foregroundStyle(MVMTheme.tertiaryText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(MVMTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                vm.saveImportedWorkout(workout)
                savedConfirmation.toggle()
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down.on.square")
                    Text("Save Workout")
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
                scannedPlan = nil
                scannedWorkout = nil
                errorMessage = nil
            } label: {
                Text("Scan Another")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MVMTheme.accent)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(MVMTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(18)
        .premiumCard()
    }

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(MVMTheme.warning)
                Text("Import Error")
                    .font(.headline)
                    .foregroundStyle(MVMTheme.primaryText)
            }
            Text(message)
                .font(.subheadline)
                .foregroundStyle(MVMTheme.secondaryText)
        }
        .padding(18)
        .premiumCard()
    }

    private func handleScannedCode(_ code: String) {
        errorMessage = nil
        scannedPlan = nil
        scannedWorkout = nil

        guard let data = code.data(using: .utf8) else {
            errorMessage = "Invalid text data."
            return
        }

        let decoder = JSONDecoder()

        if let workoutPayload = try? decoder.decode(WorkoutQRPayload.self, from: data), workoutPayload.v == 1 {
            scannedWorkout = workoutPayload.toWorkoutDay()
            return
        }

        if let payload = try? decoder.decode(UnitPTQRCodePayload.self, from: data) {
            scannedPlan = payload.toUnitPTPlan()
            return
        }

        decoder.dateDecodingStrategy = .iso8601
        if let plan = try? decoder.decode(UnitPTPlan.self, from: data) {
            scannedPlan = plan
            return
        }

        errorMessage = "Could not decode workout. Make sure the QR code is from MVM Army."
    }
}

struct QRCameraView: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> QRCameraViewController {
        let vc = QRCameraViewController()
        vc.onCodeScanned = onCodeScanned
        return vc
    }

    func updateUIViewController(_ uiViewController: QRCameraViewController, context: Context) {}
}

class QRCameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeScanned: ((String) -> Void)?
    private var captureSession: AVCaptureSession?
    private var hasScanned = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        captureSession = session

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layer = view.layer.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer }) as? AVCaptureVideoPreviewLayer {
            layer.frame = view.bounds
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }

    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        Task { @MainActor in
            guard !hasScanned,
                  let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  object.type == .qr,
                  let code = object.stringValue else { return }

            hasScanned = true
            captureSession?.stopRunning()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onCodeScanned?(code)
        }
    }
}
