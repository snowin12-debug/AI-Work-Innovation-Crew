import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showAPIKeyField = false
    @State private var tempAPIKey = ""
    @State private var showSavedAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFF8F0")
                    .ignoresSafeArea()

                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Gemini API 키", systemImage: "key.fill")
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                                if !settingsViewModel.apiKey.isEmpty {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }

                            SecureField("API 키를 입력하세요", text: $tempAPIKey)
                                .font(.system(size: 14))
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3))
                                )

                            if !settingsViewModel.apiKey.isEmpty {
                                Text("현재 키: \(String(settingsViewModel.apiKey.prefix(8)))••••••••")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }

                            Button(action: saveAPIKey) {
                                Text("저장하기")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color("AccentOrange"))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("API 설정")
                    } footer: {
                        Text("Google AI Studio (ai.google.dev)에서 무료 API 키를 발급받을 수 있습니다.")
                            .font(.system(size: 12))
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("읽기 속도", systemImage: "speedometer")
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                                Text(speedLabel)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("AccentOrange"))
                                    .fontWeight(.semibold)
                            }

                            HStack(spacing: 12) {
                                Image(systemName: "tortoise.fill")
                                    .foregroundColor(.secondary)
                                Slider(value: $settingsViewModel.ttsRate, in: 0.3...0.65, step: 0.05)
                                    .accentColor(Color("AccentOrange"))
                                Image(systemName: "hare.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("음성 설정")
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            HowToStep(number: "1", icon: "camera.fill", text: "카메라 탭으로 이동하세요")
                            HowToStep(number: "2", icon: "book.pages.fill", text: "책 페이지를 가이드 사각형 안에 맞추세요")
                            HowToStep(number: "3", icon: "hand.tap.fill", text: "\"📸 읽기 시작\" 버튼을 누르세요")
                            HowToStep(number: "4", icon: "speaker.wave.3.fill", text: "인식된 텍스트를 확인하고 읽어주기를 누르세요")
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("사용 방법")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("설정")
            .alert("저장되었습니다", isPresented: $showSavedAlert) {
                Button("확인", role: .cancel) {}
            }
        }
        .onAppear {
            tempAPIKey = ""
        }
    }

    private var speedLabel: String {
        let rate = settingsViewModel.ttsRate
        if rate < 0.4 { return "느리게 (아이용)" }
        else if rate < 0.55 { return "보통" }
        else { return "빠르게" }
    }

    private func saveAPIKey() {
        guard !tempAPIKey.isEmpty else { return }
        settingsViewModel.apiKey = tempAPIKey
        settingsViewModel.hasSeenOnboarding = true
        tempAPIKey = ""
        showSavedAlert = true
    }
}

struct HowToStep: View {
    let number: String
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color("AccentOrange").opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(Color("AccentOrange"))
            }
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
        }
    }
}
