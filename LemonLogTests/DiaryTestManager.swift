//
//  DiaryTestManager.swift
//  LemonLogTests
//
//  Created by 권정근 on 10/20/25.
//

import Foundation
import CoreData
import UIKit
@testable import LemonLog


@MainActor
final class DiaryTestManager {
    
    
    // MARK: ✅ SingleTon
    static let sharded = DiaryTestManager()
    let container: NSPersistentContainer
    private init() {
        container = NSPersistentContainer(name: "LemonLog")
        container.loadPersistentStores { _, error in
            if error != nil {
                LogManager.print(.error, "영구저장소에서 불러오기 실패")
            }
        }
    }
    
    
    // MARK: ✅ Property
    private let coreDataManager = DiaryCoreDataManager.shared
    
    
    // MARK: ✅ 더미 이미지 색성 (색상 기반)
    private func dummyImage(_ color: UIColor) -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext()
        return image ?? UIImage()
    }
    
    
    // MARK: ✅ 랜덤 감정 생성
    private func randomEmotion() -> EmotionCategory {
        EmotionCategory.allCases.randomElement() ?? .angry_grade_1
    }
    
    
    // MARK: ✅ 랜덤 색상 (이미지용)
    private func randomColor() -> UIColor {
        let colors: [UIColor] = [ .systemYellow, .systemPink, .systemBlue, .systemGreen, .systemOrange, .systemRed]
        return colors.randomElement()  ?? .systemGray
    }
    
    
    // MARK: ✅ 1. 저장 테스트
    func testSaveDiary() {
        let emotionType = randomEmotion()
        
        let dummy = EmotionDiaryModel(
            id: UUID(),
            emotion: emotionType.rawValue,
            content: "오늘의 감정은 \(emotionType.rawValue) 🤔",
            createdAt: Date(),
            images: [
                dummyImage(randomColor()),
                dummyImage(randomColor())
            ]
        )
        
        let success = coreDataManager.saveDiary(dummy)
        LogManager.print(success ? .success : .error,
                         "✅ [SAVE TEST] \(emotionType.rawValue) 감정일기 저장 \(success ? "성공" : "실패")")
    }
    
    
    // MARK: ✅ 2. 전체 조회 테스트
    func testFetchAllDiaries() {
        let diaries = coreDataManager.fetchDiaries(mode: .all)
        LogManager.print(.info, "✅ [FETCH TEST] 총 \(diaries.count)개의 감정일기 조회됨")
        diaries.forEach {
            LogManager.print(.info, " ▶️ \($0.emotion): \($0.content)")
        }
    }
    
    
    // MARK: ✅ 3. 특정 감정 검색 테스트
    func testFetchByEmotion() {
        let randomType = randomEmotion()
        let result = coreDataManager.fetchDiaries(by: randomType.rawValue)
        LogManager.print(.info, "✅ [SEARCH EMOTION] \(randomType.rawValue) 감정일기 \(result.count)개")
    }
    
    
    // MARK: ✅ 4. 키워드 검색 테스트
    func testSearchByKeyword() {
        let keyword = "angry_grade_1"
        let result = coreDataManager.fetchDiaries(by: keyword)
        LogManager.print(.info, "✅ [SEARCH KEYWORD] '\(keyword)' 결과 \(result.count)개")
    }
    
    
    // MARK: ✅ 5. 최신 일기 테스트
    func testFetchLatestDiary() {
        if let latest = coreDataManager.fetchLatestDiary() {
            LogManager.print(.success, "✅ [LATEST] 최근일기: \(latest.emotion) / \(latest.content)")
        } else {
            LogManager.print(.warning, "⚠️ [LATEST] 최근 일기를 찾을 수 없습니다.")
        }
    }
    
    
    // MARK: ✅ 6. 수정 테스트
    func testUpdateDiary() {
        guard var diary = coreDataManager.fetchDiaries(mode: .all).first else {
            LogManager.print(.warning, "⚠️ [UPDATE TEST] 수정할 데이터가 없습니다.")
            return
        }
        
        diary.content = "수정된 내용입니다 ✏️"
        diary.images?.append(dummyImage(randomColor()))
        let success = coreDataManager.updateDiary(diary)
        LogManager.print(success ? .success : .error,
                         "✅ [UPDATE TEST] 수정 \(success ? "성공" : "실패")")
    }
    
    
    // MARK: ✅ 7. 삭제 테스트
    func testDeleteDiary() {
        guard let first = coreDataManager.fetchDiaries(mode: .all).first else {
            LogManager.print(.warning, "⚠️ [DELETE TEST] 삭제할 데이터가 없습니다.")
            return
        }
        let success = coreDataManager.deleteDiary(by: first.id.uuidString)
        LogManager.print(success ? .success : .error,
                         "🗑️ [DELETE TEST] 삭제 \(success ? "성공" : "실패")")
    }
    
    
    // MARK: ✅ 8. 더미데이터 삭제
    func clearAllData() {
        let coordinator = container.persistentStoreCoordinator
        for store in coordinator.persistentStores {
            do {
                try coordinator.destroyPersistentStore(at: store.url!, ofType: store.type, options: nil)
                LogManager.print(.success, "모든 메세지 삭제 완료 \(coordinator.persistentStores.count)")
            } catch {
                print("❌ Failed to clear store: \(error)")
            }
        }
    }
    
    
    // MARK: 🧩 전체 테스트 실행
    func runAllTests() {
        print("🚀 ==== LemonLog Core Data 테스트 시작 ====")
        testSaveDiary()
        testFetchAllDiaries()
        testFetchByEmotion()
        testSearchByKeyword()
        testFetchLatestDiary()
        testUpdateDiary()
        testDeleteDiary()
        clearAllData()
        print("✅ ==== 모든 테스트 완료 ====")
    }
}
