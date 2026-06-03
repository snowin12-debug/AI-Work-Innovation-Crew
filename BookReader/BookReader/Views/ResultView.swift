import SwiftUI

struct ResultView: View {
    let text: String
    @ObservedObject var ttsService: TTSService
    @Environment(\.dismiss) var dismiss
    @State private var highlightRange: NSRange? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFF8F0")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Text scroll area
                    ScrollView {
                        HighlightedTextView(
                            text: text,
                            highlightRange: highlightRange
                        )
                        .padding(20)
                    }
                    .frame(maxHeight: .infinity)

                    Divider()

                    // Controls
                    VStack(spacing: 16) {
                        // Speed slider
                        HStack(spacing: 12) {
                            Image(systemName: "tortoise.fill")
                                .foregroundColor(.secondary)
                            Slider(value: $ttsService.rate, in: 0.3...0.65, step: 0.05)
                                .accentColor(Color("AccentOrange"))
                            Image(systemName: "hare.fill")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 24)

                        // Playback buttons
                        HStack(spacing: 20) {
                            // Stop
                            Button(action: { ttsService.stop() }) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(Color.gray)
                                    .clipShape(Circle())
                            }

                            // Play / Pause
                            Button(action: {
                                if ttsService.isSpeaking {
                                    ttsService.pause()
                                } else if ttsService.isPaused {
                                    ttsService.resume()
                                } else {
                                    ttsService.speak(text: text) { range in
                                        highlightRange = range
                                    }
                                }
                            }) {
                                Image(systemName: ttsService.isSpeaking ? "pause.fill" : "play.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                                    .frame(width: 72, height: 72)
                                    .background(Color("AccentOrange"))
                                    .clipShape(Circle())
                                    .shadow(color: Color("AccentOrange").opacity(0.4), radius: 8, y: 4)
                            }

                            // Placeholder for balance
                            Color.clear
                                .frame(width: 56, height: 56)
                        }

                        Text(ttsService.isSpeaking ? "읽는 중..." : (ttsService.isPaused ? "일시정지됨" : "▶ 읽어주기 버튼을 눌러보세요"))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    .background(Color.white)
                }
            }
            .navigationTitle("인식된 텍스트")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        ttsService.stop()
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            ttsService.stop()
        }
    }
}

struct HighlightedTextView: View {
    let text: String
    let highlightRange: NSRange?

    var body: some View {
        Text(attributedString)
            .font(.system(size: 18))
            .lineSpacing(8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var attributedString: AttributedString {
        var attributed = AttributedString(text)

        if let range = highlightRange,
           let swiftRange = Range(range, in: text),
           let attrRange = AttributedString(text).range(of: String(text[swiftRange])) {
            attributed[attrRange].backgroundColor = Color("AccentOrange").opacity(0.3)
            attributed[attrRange].foregroundColor = Color.primary
        }

        return attributed
    }
}
