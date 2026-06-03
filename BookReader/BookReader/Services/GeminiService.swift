import UIKit

enum GeminiError: Error {
    case invalidAPIKey
    case rateLimitExceeded
    case noTextFound
    case networkError
    case decodingError
}

class GeminiService {
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

    func recognizeText(from image: UIImage, apiKey: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw GeminiError.networkError
        }

        let base64Image = imageData.base64EncodedString()

        let prompt = """
        이 이미지에 있는 책의 텍스트를 모두 읽고, 원문 그대로 한국어로 반환해주세요.
        텍스트 외의 설명이나 부가 내용은 포함하지 마세요.
        만약 텍스트가 없다면 빈 문자열을 반환해주세요.
        """

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.1,
                "maxOutputTokens": 2048
            ]
        ]

        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw GeminiError.networkError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw GeminiError.networkError
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.networkError
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 400, 401, 403:
            throw GeminiError.invalidAPIKey
        case 429:
            throw GeminiError.rateLimitExceeded
        default:
            throw GeminiError.networkError
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            throw GeminiError.decodingError
        }

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            throw GeminiError.noTextFound
        }

        return trimmed
    }
}
