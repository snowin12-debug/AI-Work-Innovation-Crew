import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var apiKey = ""
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Color(hex: "#FFF8F0").ignoresSafeArea()

            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        emoji: "📚",
                        title: "BookReader에 오신 것을\n환영합니다!",
                        description: "카메라로 책을 비추면\n자동으로 읽어드립니다"
                    )
                    .tag(0)

                    OnboardingPageView(
                        emoji: "🔑",
                        title: "API 키 설정",
                        description: "Google AI Studio에서\n무료 Gemini API 키를 받아\n아래에 입력해주세요"
                    )
                    .tag(1)
                }
                .tabViewStyle(.page)
                .frame(height: 400)

                if currentPage == 1 {
                    VStack(spacing: 16) {
                        SecureField("Gemini API 키 입력", text: $apiKey)
                            .font(.system(size: 16))
                            .padding(14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                            .padding(.horizontal, 28)

                        Button(action: startApp) {
                            Text("시작하기 →")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(apiKey.isEmpty ? Color.gray : Color("AccentOrange"))
                                .cornerRadius(30)
                                .padding(.horizontal, 28)
                        }
                        .disabled(apiKey.isEmpty)

                        Button("나중에 설정하기") {
                            settingsViewModel.hasSeenOnboarding = true
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Button(action: { withAnimation { currentPage = 1 } }) {
                        Text("다음 →")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("AccentOrange"))
                            .cornerRadius(30)
                            .padding(.horizontal, 28)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .animation(.easeInOut, value: currentPage)
    }

    private func startApp() {
        settingsViewModel.apiKey = apiKey
        settingsViewModel.hasSeenOnboarding = true
    }
}

struct OnboardingPageView: View {
    let emoji: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 24) {
            Text(emoji)
                .font(.system(size: 80))

            Text(title)
                .font(.system(size: 26, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            Text(description)
                .font(.system(size: 17))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .lineSpacing(6)
        }
        .padding(40)
    }
}
