# LemonLog 🍋

**레몬로그**는 하루의 감정을 상큼하게 기록하고 회복을 돕는 감정 힐링 다이어리입니다.  
초기에는 **Core Data 기반의 개인 일기**로 시작하고, 이후 **Firebase 기반의 공유(커뮤니티)** 및 **OpenAI 기반 감정 분석/피드백**으로 확장될 예정입니다.

---

## 🔖 주요 기능 (MVP)
- 로컬 감정일기 CRUD (Core Data)
- 감정 타입(이모지) 선택 및 감정별 색상/아이콘 매핑
- 이미지 첨부(앨범 선택) 및 사진 미리보기 (컬렉션 뷰)
- 홈 화면: 명언 + 지난 일기 랜덤 표시 + 주간 감정 요약 바
- 사용자 지정 배경색 (테마/커스터마이즈)

---

## 🚀 기술 스택
- iOS: Swift, UIKit
- 아키텍처: MVVM
- 로컬 DB: Core Data
- 인증/백업/커뮤니티(예정): Firebase (Auth, Firestore, Storage)
- AI(예정): OpenAI (감정 분석 / 리플렉션 메시지)
- 빌드/테스트: Xcode, XCTest
- CI(권장): GitHub Actions

---

## ⚙️ 빠른 시작 (개발 환경)
1. Xcode로 프로젝트 오픈 (`LemonLog.xcodeproj`)
2. scheme에서 개발용 설정 선택
3. CocoaPods / Swift Package Manager로 의존성 설치 (프로젝트에 따라)
4. Firebase 연동: `GoogleService-Info.plist`를 프로젝트에 추가
5. (옵션) `.env` 또는 GitHub Secrets에 API 키 저장 (OpenAI 키 등)

---

## 🗂 프로젝트 구조 (권장)
<br/>LemonLog/
<br/>├─ AppDelegate.swift / SceneDelegate.swift
<br/>├─ Model
<br/>├─ ViewModel
<br/>├─ View/
<br/>├─ CoreData/
<br/>├─ Firebase/ 
<br/>└─ Resources/

---

## ✅ 개발 가이드라인
- 아키텍처: MVVM (View는 ViewModel만 참조)
- 모든 네트워크/데이터 액세스는 `Manager/Service` 클래스(예: `CoreDataManager`, `FirebaseManager`)로 분리
- 민감한 키(예: OpenAI API Key, Firebase config)는 절대 레포에 커밋하지 말 것
- 단위 테스트는 `XCTest` 사용

---

## 📁 .gitignore (예시)

Xcode 템플릿을 사용하되, 다음을 포함하세요:

Xcode

- DerivedData/
- build/
  *.xcuserstate
  *.xcworkspace
- !Podfile

SwiftPM

- .swiftpm

CocoaPods

- Pods/

Fastlane

- fastlane/report.xml

Homebrew

- .DS_Store
- .env
- GoogleService-Info.plist

---

## 📜 License
이 프로젝트는 **MIT License** 하에 배포되나, 
앱 스토어 등록 후에는 **No License** 로 변경됩니다.

---

## 🤝 기여
환영합니다! 풀 리퀘스트(PR) 전에는 이슈 등록/토론을 먼저 해주세요.  
브랜치 전략: `main`(배포용), `develop`(개발), `feature/*` (기능 브랜치)

---

## 📬 연락
궁금한 점이나 제안이 있으시면 이슈 열어주세요.
