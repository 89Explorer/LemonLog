//
//  DiaryStoreTests.swift
//  LemonLogTests
//
//  Created by 권정근 on 10/23/25.
//

import XCTest
import Combine
@testable import LemonLog


@MainActor
final class DiaryStoreTests: XCTestCase {
    
    
    private var store: DiaryStore!
    private var cancellables: Set<AnyCancellable> = []
    
    
    override func setUpWithError() throws {
        store = DiaryStore(manager: DiaryCoreDataManager.shared)
        cancellables = []
    }
    
    override func tearDownWithError() throws {
        store = nil
        cancellables.removeAll()
    }
    
    
    private func makeDummyDiary(content: String = "테스트 일기") -> EmotionDiaryModel {
        EmotionDiaryModel(
            id: UUID(),
            emotion: "happy_grade_1",
            content: content,
            createdAt: Date(),
            images: nil
        )
    }
    
    func testReloadLoadAllDiaries() async {
        let dummy = makeDummyDiary()
        _ = store.save(dummy)
        await store.reload()
        XCTAssertFalse(store.snapshot.isEmpty)
        XCTAssertTrue(store.snapshot.contains(where: { $0.id == dummy.id }))
    }
    
    func testSaveDiaryUpdatePublisher() async {
        let expectation = XCTestExpectation(description: "Publisher 업데이트 대기")
        
        store.diariesPublisher
            .dropFirst()
            .sink { diaries in
                if diaries.contains(where: { $0.content == "새 일기 저장 테스트" }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        let dummy = makeDummyDiary(content: "새 일기 저장 테스트")
        _ = store.save(dummy)
        
        await fulfillment(of: [expectation], timeout: 3.0)
    }
    
    
    func testUpdateDiaryReflectsChanges() async {
        let dummy = makeDummyDiary(content: "수정 전 내용")
        _ = store.save(dummy)
        
        var updated = dummy
        updated.content = "수정된 내용 👍"
        _ = store.update(updated)
        
        await store.reload()
        let found = store.snapshot.first(where: { $0.id == dummy.id})
        XCTAssertEqual(found?.content, "수정된 내용 👍")
    }
    
    func testDeleteDiaryRemovesFromPublisher() async {
        let dummy = makeDummyDiary()
        _ = store.save(dummy)
        
        await store.reload()
        XCTAssertTrue(store.snapshot.contains(where: { $0.id == dummy.id }))
        
        _ = store.delete(id: dummy.id.uuidString)
        await store.reload()
        XCTAssertFalse(store.snapshot.contains(where: { $0.id == dummy.id }))
    }
}
