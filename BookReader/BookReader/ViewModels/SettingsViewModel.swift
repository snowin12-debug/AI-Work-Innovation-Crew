import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @Published var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: "gemini_api_key") }
    }

    @Published var ttsRate: Float {
        didSet { UserDefaults.standard.set(ttsRate, forKey: "tts_rate") }
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasSeenOnboarding, forKey: "has_seen_onboarding") }
    }

    init() {
        self.apiKey = UserDefaults.standard.string(forKey: "gemini_api_key") ?? ""
        self.ttsRate = UserDefaults.standard.float(forKey: "tts_rate").nonZero ?? 0.45
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "has_seen_onboarding")
    }
}

extension Float {
    var nonZero: Float? { self == 0 ? nil : self }
}
