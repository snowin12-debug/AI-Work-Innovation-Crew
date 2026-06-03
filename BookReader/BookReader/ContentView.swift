import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if settingsViewModel.apiKey.isEmpty && !settingsViewModel.hasSeenOnboarding {
                OnboardingView()
                    .environmentObject(settingsViewModel)
            } else {
                TabView(selection: $selectedTab) {
                    CameraView()
                        .tabItem {
                            Label("카메라", systemImage: "camera.fill")
                        }
                        .tag(0)

                    SettingsView()
                        .tabItem {
                            Label("설정", systemImage: "gear")
                        }
                        .tag(1)
                }
                .accentColor(Color("AccentOrange"))
            }
        }
    }
}
