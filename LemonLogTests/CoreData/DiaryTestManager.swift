//
//  DiaryTestManager.swift
//  LemonLogTests
//
//  Created by 권정근 on 10/20/25.
//


import XCTest
import CoreData
import UIKit
@testable import LemonLog

@MainActor
final class DiaryCoreDataManagerTests: XCTestCase {
    
    
    // MARK: ✅ Properties
    var sut: DiaryCoreDataManager!
    var container: NSPersistentContainer!
    
    
    // MARK: ✅ Setup / Teardown
    override func setUp() async throws {
        try await super.setUp()
        
        // In-memory Core Data 설정
        container = NSPersistentContainer(name: "LemonLog")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        
        sut = DiaryCoreDataManager.shared
        LogManager.print(.info, "테스트용 InMemory CoreData 스택 초기화 완료")
    }
    
    override func tearDown() async throws {
        sut = nil
        container = nil
        try await super.tearDown()
        LogManager.print(.info, "테스트 종료 및 리소스 해제 완료")
    }
    
    
    // MARK: ✅ Helper Methods
    private func makeDummyDiary(emotion: EmotionCategory,
                                date: Date = Date(),
                                content: String = "테스트 내용") -> EmotionDiaryModel {
        EmotionDiaryModel(
            id: UUID(),
            emotion: emotion.rawValue,
            content: content,
            createdAt: date,
            images: nil
        )
    }
    
    // MARK: ✅ Tests
    func test_saveDiary_shouldSucceed() {
        let dummy = makeDummyDiary(emotion: ._1)
        let success = sut.saveDiary(dummy)
        XCTAssertTrue(success)
        LogManager.print(success ? .success : .error, "감정일기 저장 테스트 완료: \(dummy.emotion)")
    }
    
    func test_fetchDiaries_shouldReturnAll() {
        for i in 0..<5 {
            let dummy = makeDummyDiary(emotion: EmotionCategory.allCases[i])
            _ = sut.saveDiary(dummy)
        }
        
        let diaries = sut.fetchDiaries(mode: .all)
        XCTAssertEqual(diaries.count, 5)
        LogManager.print(.success, "총 \(diaries.count)개의 감정일기 조회 성공")
    }
    
    func test_fetchDiaries_withPaging_shouldLimitResults() {
        for i in 0..<10 {
            let dummy = makeDummyDiary(emotion: EmotionCategory.allCases[i % EmotionCategory.allCases.count])
            _ = sut.saveDiary(dummy)
        }
        
        let paged = sut.fetchDiaries(mode: .paged(limit: 3, offset: 0))
        XCTAssertEqual(paged.count, 3)
        LogManager.print(.success, "페이징 테스트 성공 — 3개만 반환됨")
    }
    
    func test_fetchDiaryById_shouldReturnCorrectDiary() {
        let dummy = makeDummyDiary(emotion: ._2)
        _ = sut.saveDiary(dummy)
        
        let fetched = sut.fetchDiary(by: dummy.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, dummy.id)
        LogManager.print(.success, "ID 기반 단일 조회 성공: \(dummy.id)")
    }

    func test_fetchDiariesByEmotion_shouldFilterCorrectly() {
        let targetEmotion = EmotionCategory._3
        let dummy1 = makeDummyDiary(emotion: ._1)
        let dummy2 = makeDummyDiary(emotion: targetEmotion)
        _ = sut.saveDiary(dummy1)
        _ = sut.saveDiary(dummy2)
        
        let result = sut.fetchDiaries(by: targetEmotion.rawValue)
        XCTAssertTrue(result.allSatisfy { $0.emotion == targetEmotion.rawValue })
        LogManager.print(.success, "특정 감정(\(targetEmotion.rawValue)) 필터링 성공, 총 \(result.count)개")
    }
    
    func test_searchDiariesByKeyword_shouldReturnMatchingContent() {
        let keyword = "기쁨"
        let dummy1 = makeDummyDiary(emotion: ._4, content: "오늘은 \(keyword)이 넘친다")
        let dummy2 = makeDummyDiary(emotion: ._5, content: "우울한 하루였어")
        _ = sut.saveDiary(dummy1)
        _ = sut.saveDiary(dummy2)
        
        let result = sut.searchDiaries(by: keyword)
        XCTAssertEqual(result.count, 1)
        LogManager.print(.success, "키워드(\(keyword)) 검색 결과: \(result.count)개")
    }
    
    func test_fetchLatestDiary_shouldReturnMostRecentOne() {
        let oldDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let recentDate = Date()
        
        let old = makeDummyDiary(emotion: ._1, date: oldDate)
        let recent = makeDummyDiary(emotion: ._2, date: recentDate)
        _ = sut.saveDiary(old)
        _ = sut.saveDiary(recent)
        
        let latest = sut.fetchLatestDiary()
        XCTAssertEqual(latest?.emotion, "_2")
        LogManager.print(.success, "최신 일기 조회 성공: \(latest?.emotion ?? "nil")")
    }
    
    func test_updateDiary_shouldReflectChanges() {
        var dummy = makeDummyDiary(emotion: ._3)
        _ = sut.saveDiary(dummy)
        
        dummy.content = "수정된 내용"
        let success = sut.updateDiary(dummy)
        XCTAssertTrue(success)
        
        let updated = sut.fetchDiary(by: dummy.id)
        XCTAssertEqual(updated?.content, "수정된 내용")
        LogManager.print(.success, "감정일기 수정 반영 성공: \(updated?.content ?? "")")
    }
    
    func test_deleteDiary_shouldRemoveEntity() {
        let dummy = makeDummyDiary(emotion: ._5)
        _ = sut.saveDiary(dummy)
        
        let deleteSuccess = sut.deleteDiary(by: dummy.id.uuidString)
        XCTAssertTrue(deleteSuccess)
        
        let afterDelete = sut.fetchDiary(by: dummy.id)
        XCTAssertNil(afterDelete)
        LogManager.print(.success, "감정일기 삭제 성공: \(dummy.id)")
    }
    
    func test_fetchWeeklySummary_shouldGroupByWeekday() {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())!.start
        
        let samples: [(offset: Int, emotion: EmotionCategory)] = [
            (0, ._1), (1, ._2), (2, ._3), (3, ._4),
            (4, ._1), (5, ._2), (6, ._3)
        ]
        for sample in samples {
            let date = calendar.date(byAdding: .day, value: sample.offset, to: startOfWeek)!
            _ = sut.saveDiary(makeDummyDiary(emotion: sample.emotion, date: date))
        }
        
        let summary = sut.fetchWeeklySummary(for: Date())
        XCTAssertFalse(summary.isEmpty)
        XCTAssertEqual(summary.keys.count, 7)
        
        LogManager.print(.success, "fetchWeeklySummary() 실행 성공 — 총 \(summary.count)개의 요일 데이터 반환됨")
        summary.sorted(by: { $0.key.rawValue < $1.key.rawValue }).forEach {
            LogManager.print(.info, "\( $0.key.rawValue ): \( $0.value.map { $0.rawValue })")
        }
    }
}
