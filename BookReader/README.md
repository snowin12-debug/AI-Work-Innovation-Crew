# 📚 BookReader — 아이를 위한 iOS 책 읽기 앱

카메라로 책 페이지를 비추면 자동으로 텍스트를 인식하고, 한국어 TTS로 소리 내어 읽어주는 iOS 앱입니다.

## 기술 스택

| 항목 | 선택 |
|------|------|
| 플랫폼 | iOS 16+ (Swift, SwiftUI) |
| OCR | Google Gemini API (gemini-2.0-flash) |
| TTS | Apple AVSpeechSynthesizer (ko-KR) |
| 카메라 | AVFoundation |

## Xcode 프로젝트 설정

### 1. 새 프로젝트 생성
- Xcode → File → New → Project
- **iOS App** 선택
- Product Name: `BookReader`
- Interface: **SwiftUI**
- Minimum Deployments: **iOS 16.0**

### 2. 소스 파일 추가
이 저장소의 `BookReader/BookReader/` 폴더 안의 파일들을 Xcode 프로젝트에 드래그&드롭하세요.

```
BookReader/
├── BookReaderApp.swift
├── ContentView.swift
├── Info.plist
├── Views/
│   ├── CameraView.swift
│   ├── ResultView.swift
│   ├── SettingsView.swift
│   └── OnboardingView.swift
├── ViewModels/
│   ├── CameraViewModel.swift
│   ├── OCRViewModel.swift
│   └── SettingsViewModel.swift
├── Services/
│   ├── GeminiService.swift
│   └── TTSService.swift
└── Utils/
    └── ImageUtils.swift
```

### 3. AccentOrange 색상 추가
- Assets.xcassets → `+` → Color Set
- 이름: `AccentOrange`
- 색상값: `#FF8C42` (R:255 G:140 B:66)

### 4. Info.plist 권한 추가
이미 포함되어 있습니다. Xcode 프로젝트 타겟 → Info 탭에서 확인:
- `NSCameraUsageDescription`: 책을 촬영하여 텍스트를 인식하기 위해 카메라가 필요합니다.

## Gemini API 키 발급

1. [Google AI Studio](https://ai.google.dev) 접속
2. **Get API key** 클릭 → 무료 키 생성
3. 앱 실행 후 설정 탭에서 API 키 입력

## 사용 방법

1. 앱 실행 → API 키 입력 (최초 1회)
2. 카메라 탭에서 책 페이지를 가이드 사각형 안에 맞추기
3. **📸 읽기 시작** 버튼 터치
4. 인식된 텍스트 확인 후 **▶ 읽어주기** 터치
5. TTS 속도 슬라이더로 읽기 속도 조절 가능

## 주요 기능

- ✅ 카메라 라이브 프리뷰 + 페이지 가이드라인
- ✅ Gemini API OCR (이미지 → 텍스트)
- ✅ 한국어 TTS 재생 / 일시정지 / 정지
- ✅ TTS 재생 중 단어 하이라이트
- ✅ 읽기 속도 조절 슬라이더
- ✅ API 키 설정 및 저장 (UserDefaults)
- ✅ 온보딩 플로우
- ✅ 한국어 에러 안내 메시지
