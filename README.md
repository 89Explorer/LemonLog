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

| 기능 | 설명 |
|------|------|
| 🗂️ **Core Data CRUD** | 감정일기 저장, 조회, 수정, 삭제 기능 |
| 🔍 **고급 Fetch 기능** | 감정별/키워드별 검색, 최신 일기 조회 |
| 🧠 **DiaryTestManager** | XCTest 기반 Core Data CRUD 자동화 테스트 |
| 🖼️ **이미지 관리 (예정)** | 앨범 선택 및 로컬 저장, 컬렉션 뷰 미리보기 |
| 🎨 **테마 커스터마이즈 (예정)** | 감정별 색상/아이콘 매핑, 사용자 테마 설정 |
| 🏠 **홈화면 구성 (예정)** | 명언, 랜덤 일기, 주간 감정 요약 바 |
| 🤖 **AI 피드백 (예정)** | OpenAI API 기반 감정 분석/리플렉션 메시지 |
| ☁️ **Firebase (예정)** | Auth, Firestore, Storage 연동 및 백업 |


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

## 🧠 개발 히스토리 (Commit + Blog)
| 날짜 | 주요 작업 |
|------|------------|
|2025.10.21|feat: Core Data CRUD 기능 검증용 DiaryTestManager 추가 및 Core Data 메서드 개선 (https://github.com/89Explorer/LemonLog/commit/c08a348730df9f5eabf21413c9f7ee9c7bd8b65e)|
- https://explorer89.tistory.com/502 (🧪 DiaryTestManager, 어디에 두는 게 맞을까?)
- https://explorer89.tistory.com/503 (⚙️ Core Data에서 catch가 작동하지 않는 이유)
- https://explorer89.tistory.com/504 (💥 Xcode 테스트 실행 시 “DSTROOT install style is not supported on this device.” 에러 해결법)
- https://explorer89.tistory.com/505 (🧠 Core Data CRUD 테스트 자동화 — DiaryTestManager 완전 해설)
- https://explorer89.tistory.com/506 (🚀 Xcode에서 Core Data CRUD 테스트 실행하기)
- https://explorer89.tistory.com/507 (🧩 LemonLog Core Data 테스트 콘솔 로그 분석)

| 날짜 | 주요 작업 |
|------|------------|
|2025.10.20|feat: Core Data CRUD 및 고급 Fetch 기능(페이징·검색) 구현 (https://github.com/89Explorer/LemonLog/commit/bb9fd0f9dd7cd9f193f1071ee4d8fc62f9be9fa5)|
- https://explorer89.tistory.com/492 (🚀 현실적인 iOS 데이터 로딩 전략 — Core Data와 Pagination(페이징) 이야기)
- https://explorer89.tistory.com/493 (📒 감정일기 앱의 데이터 로딩 전략 설계 — 동기 로딩 vs 점진적 로딩(Pagination))
- https://explorer89.tistory.com/494 (🧩 Core Data 매니저 네이밍, 어떻게 하는 게 좋을까?)
- https://explorer89.tistory.com/496 (📚 DiaryCoreDataManager 내부 구조 완전 정리)
- https://explorer89.tistory.com/497 (💾 왜 Core Data의 Read는 반드시 async여야 할까?)
- https://explorer89.tistory.com/501 (🍋 Core Data Fetch 고급 설계 — Predicate, Compound, FetchLimit 완전정복)


| 날짜 | 주요 작업 |
|------|------------|
|2025.10.17|refactor: LogManager 통합 및 DiaryImageFileManager 안정화 리팩터링 (https://github.com/89Explorer/LemonLog/commit/bb8cd67fbe474b16e5cf37889e8b9186766f0576)|
- https://explorer89.tistory.com/491 (🪵 개발/배포 환경을 구분한 로깅 설계)


| 날짜 | 주요 작업 |
|------|------------|
|2025.10.17|feat: DiaryImageFileManager 클래스 설계 및 Core Data 이미지 관리 구조 구축 (https://github.com/89Explorer/LemonLog/commit/18c41e11886050f2ec264f2a42fc314d2e2543ad)|
- https://explorer89.tistory.com/490 (📦 Core Data와 FileManager로 이미지 관리 구조 설계하기)


| 날짜 | 주요 작업 |
|------|------------|
|2025.10.16|feat: 감정일기 및 이미지 엔티티 모델 설계 및 관계 설정 (https://github.com/89Explorer/LemonLog/commit/e653243fb65e25c91f2872402cb642920b693d26)
- https://explorer89.tistory.com/485 (🧩 Core Data에서 여러 이미지를 저장하는 두 가지 방법 비교)
- https://explorer89.tistory.com/486 (📸 Core Data에서 ‘이미지 피드 + 게시글 연결’ 기능을 설계하는 방법)
- https://explorer89.tistory.com/487 (🧠 Core Data + Enum: 감정(EmotionCategory) case를 추가·변경할 때 생기는 문제와 해결법)
- https://explorer89.tistory.com/488 (🧩 Core Data 설계할 때, “나중에 쓸 속성”을 지금 넣어야 할까?)
- https://explorer89.tistory.com/489 (🍋 감정일기 앱의 Core Data 설계 — 왜 이미지 엔티티를 분리했는가?)


| 날짜 | 주요 작업 |
|------|------------|
|2025.10.16|feat: EmotionDiaryModel 구조체 및 EmotionCategory 열거형 설계, 감정 이미지 리소스 추가 (https://github.com/89Explorer/LemonLog/commit/29feec6ae9bea3024fd06ab2a892ba5cc81a5414)|
- https://explorer89.tistory.com/484 (📱 iOS에서 사용자가 선택한 이미지를 FileManager에 저장하는 이유)


| 날짜 | 주요 작업 |
|------|------------|
|2025.10.15|feat: LaunchScreen과 SplashViewController 분리 및 앱 로고 페이드인 화면 구현 (https://github.com/89Explorer/LemonLog/commit/517f61eb2e7d788646d1dd150f65a56fdd58fbc5)|
- https://explorer89.tistory.com/483 (🚀 iOS에서 앱 로고를 보여주는 두 가지 방식 — LaunchScreen vs SplashViewController 완전 정리)


| 날짜 | 주요 작업 |
|------|------------|
|2025.10.15|feat: MVVM 기반 폴더 구조 설계 및 프로젝트 구조 정리 (https://github.com/89Explorer/LemonLog/commit/d5386e6f39abc86478243ebd0f101f8d88618f36)|
- https://explorer89.tistory.com/482 (📁 LemonLog 폴더 구조 정리 — MVVM + Application + Resource 구성)


| 날짜 | 주요 작업 |
|------|------------|
|2025.10.14|feat: 코드 기반 UI 환경 구성 및 앱 아이콘 설정|
- https://explorer89.tistory.com/478 (🚀 iOS 13+ SceneDelegate: UIWindow 설정, 가장 깔끔하게 끝내기!)
- https://explorer89.tistory.com/479 (🍋 LemonLog App Store Connect 카테고리 설정 가이드)


| 날짜 | 주요 작업 |
|------|------------|
|2025.10.13|Merge branch 'main' of https://github.com/89Explorer/LemonLog|
- https://explorer89.tistory.com/477 (🚀 Xcode 프로젝트와 GitHub 원격 저장소 연결 및 병합 오류 해결 완전 가이드)


| 날짜 | 주요 작업 |
|------|------------|
|2025.10.13|Update README.md|
- https://explorer89.tistory.com/474 (🌿 감정일기 앱의 진화: Core Data에서 Firebase, 그리고 AI)


| 날짜 | 주요 작업 |
|------|------------|
|2025.10.12|Initial commit (앱 기획)|
- https://explorer89.tistory.com/469 (Firebase로 시작하는 실전 앱 3선 📱)
- https://explorer89.tistory.com/470 (😊 감정일기의 제품 철학)
- https://explorer89.tistory.com/471 (🧠 감정일기 앱 데이터 모델 설계 (with Firebase + MVVM))
- https://explorer89.tistory.com/473 (☁️ Core Data, iCloud, Firebase — 감정일기 앱에서 어떤 걸 써야 할까?)

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
