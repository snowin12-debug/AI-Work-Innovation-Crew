import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @StateObject private var ocrViewModel = OCRViewModel()
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showResult = false

    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(session: cameraViewModel.session)
                .ignoresSafeArea()

            // Guide overlay
            GeometryReader { geo in
                let guideRect = CGRect(
                    x: geo.size.width * 0.05,
                    y: geo.size.height * 0.15,
                    width: geo.size.width * 0.90,
                    height: geo.size.height * 0.55
                )

                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .mask(
                            Rectangle()
                                .ignoresSafeArea()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .frame(width: guideRect.width, height: guideRect.height)
                                        .blendMode(.destinationOut)
                                )
                        )

                    // Guide border
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                        .frame(width: guideRect.width, height: guideRect.height)

                    // Corner markers
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("AccentOrange"), lineWidth: 3)
                        .frame(width: guideRect.width, height: guideRect.height)
                        .mask(
                            ZStack {
                                ForEach([
                                    CGPoint(x: 0, y: 0),
                                    CGPoint(x: 1, y: 0),
                                    CGPoint(x: 0, y: 1),
                                    CGPoint(x: 1, y: 1)
                                ], id: \.x) { corner in
                                    Rectangle()
                                        .frame(width: 40, height: 40)
                                        .offset(
                                            x: (corner.x - 0.5) * (guideRect.width - 40),
                                            y: (corner.y - 0.5) * (guideRect.height - 40)
                                        )
                                }
                            }
                        )

                    // Guide text
                    VStack {
                        Spacer()
                            .frame(height: guideRect.minY - 50)
                        Text("📖 책 페이지를 사각형 안에 맞춰주세요")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(20)
                        Spacer()
                    }
                }
            }

            // Bottom controls
            VStack {
                Spacer()

                if ocrViewModel.isLoading {
                    LoadingView()
                        .padding(.bottom, 20)
                } else {
                    Button(action: {
                        captureAndProcess()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                            Text("📸 읽기 시작")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(
                            LinearGradient(
                                colors: [Color("AccentOrange"), Color.orange.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(32)
                        .shadow(color: Color("AccentOrange").opacity(0.5), radius: 10, y: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }

            // Error toast
            if let error = ocrViewModel.errorMessage {
                VStack {
                    ErrorToastView(message: error) {
                        ocrViewModel.errorMessage = nil
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
        }
        .onAppear {
            cameraViewModel.startSession()
        }
        .onDisappear {
            cameraViewModel.stopSession()
        }
        .sheet(isPresented: $showResult) {
            ResultView(
                text: ocrViewModel.recognizedText,
                ttsService: TTSService(defaultRate: settingsViewModel.ttsRate)
            )
        }
        .onChange(of: ocrViewModel.recognizedText) { text in
            if !text.isEmpty {
                showResult = true
            }
        }
    }

    private func captureAndProcess() {
        guard !settingsViewModel.apiKey.isEmpty else {
            ocrViewModel.errorMessage = "API 키를 먼저 설정해주세요. 설정 탭에서 입력해주세요."
            return
        }

        cameraViewModel.capturePhoto { image in
            guard let image = image else {
                ocrViewModel.errorMessage = "사진 촬영에 실패했습니다. 다시 시도해주세요."
                return
            }

            Task {
                await ocrViewModel.recognizeText(
                    from: image,
                    apiKey: settingsViewModel.apiKey
                )
            }
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

class PreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    var session: AVCaptureSession? {
        get { previewLayer.session }
        set {
            previewLayer.session = newValue
            previewLayer.videoGravity = .resizeAspectFill
        }
    }
}

struct LoadingView: View {
    @State private var rotation = 0.0
    @State private var scale = 1.0

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                ForEach(0..<3) { i in
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color("AccentOrange"))
                        .rotationEffect(.degrees(rotation + Double(i * 30)))
                        .scaleEffect(scale)
                        .opacity(0.3 + Double(i) * 0.3)
                }
            }
            .frame(width: 80, height: 80)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.2
                }
            }

            Text("텍스트를 인식하는 중...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
        }
        .padding(.bottom, 40)
    }
}

struct ErrorToastView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(14)
        .background(Color.black.opacity(0.85))
        .cornerRadius(14)
        .shadow(radius: 8)
    }
}
