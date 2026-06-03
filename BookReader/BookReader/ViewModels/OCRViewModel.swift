import SwiftUI

@MainActor
class OCRViewModel: ObservableObject {
    @Published var recognizedText = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let geminiService = GeminiService()

    func recognizeText(from image: UIImage, apiKey: String) async {
        isLoading = true
        errorMessage = nil
        recognizedText = ""

        do {
            let text = try await geminiService.recognizeText(from: image, apiKey: apiKey)
            recognizedText = text
        } catch GeminiError.invalidAPIKey {
            errorMessage = "API 키가 올바르지 않습니다. 설정에서 확인해주세요."
        } catch GeminiError.rateLimitExceeded {
            errorMessage = "API 사용 한도를 초과했습니다. 잠시 후 다시 시도해주세요."
        } catch GeminiError.noTextFound {
            errorMessage = "텍스트를 찾을 수 없습니다. 책 페이지가 잘 보이도록 다시 촬영해주세요."
        } catch GeminiError.networkError {
            errorMessage = "네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요."
        } catch {
            errorMessage = "오류가 발생했습니다: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
