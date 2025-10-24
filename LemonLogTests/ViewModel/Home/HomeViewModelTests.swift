//
//  HomeViewModelTests.swift
//  LemonLogTests
//
//  Created by 권정근 on 10/24/25.
//

import XCTest
import Combine
@testable import LemonLog


// MARK: - Mock Store
@MainActor
final class MockDiaryStore: DiaryProviding {
    

    // MARK: ✅ 테스트에서 주입/세팅할 가짜 데이터
    var mockDiaries: [EmotionDiaryModel] = []
    
    var mockImages: [(UIImage?, String)] = []
    
    
    // MARK: ✅ 프로토콜 요구사항 구현
    var diariesPublisher: AnyPublisher<[EmotionDiaryModel], Never> {
        // "Just" -> "값 하나를 즉시 한 번만 방출하고 완료하는 간단한 Publisher"
        Just(mockDiaries).eraseToAnyPublisher()
    }
    
    var snapshot: [EmotionDiaryModel] { mockDiaries }
    
    func diary(with id: String) -> EmotionDiaryModel? {
        mockDiaries.first { $0.id.uuidString == id }
    }

    func diaries(inWeekOf date: Date) -> [EmotionDiaryModel] { mockDiaries }

    func countByEmotion(inWeekOf date: Date) -> [EmotionCategory: Int] {
        Dictionary(grouping: mockDiaries) { EmotionCategory(rawValue: $0.emotion) ?? .happy_grade_1 }
            .mapValues(\.count)
    }
    
    func fetchFirstImages() async -> [(image: UIImage?, diaryID: String)] {
        mockImages
    }
}


// MARK: - HomeViewModel Test
// ViewModel이 데이터를 어떻게 가공해서 화면에 보여주는가 확인하는 테스트
@MainActor
final class HomeViewModelTests: XCTestCase {
    
    
    // MARK: ✅ Combine 구독을 담아두는 바구니
    var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ 최근 5개의 일기만 노출되는지 확인하는 메서드
    func testRecentDiariesLimitToFive() {
        
        let mockStore = MockDiaryStore()
        mockStore.mockDiaries = (1...10).map {
            EmotionDiaryModel(
                id: UUID(),
                emotion: "happy_grade_1",
                content: "테스트 \($0)",
                createdAt: Date().addingTimeInterval(-Double($0) * 100)
            )
        }
        
        let viewModel = HomeViewModel(store: mockStore)
        let expectation = XCTestExpectation(description: "Wait for recent diaries update")
        
        viewModel.$recentDiaries
            .dropFirst()    // 초기값 스킵
            .sink { diaries in
                if diaries.count == 5 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        // "recentDiaries.count"가 정확히 5개인지 확인
        XCTAssertEqual(viewModel.recentDiaries.count, 5)
    }
    
    
    // MARK: ✅ 감정별 통계까 올바르게 나오는지 확인하는 메서드 
    func testEmotionSummaryCountsProperly() {
        let mockStore = MockDiaryStore()
        mockStore.mockDiaries = [
            EmotionDiaryModel(id: UUID(), emotion: "happy_grade_1", content: "", createdAt: Date()),
            EmotionDiaryModel(id: UUID(), emotion: "sad_grade_1", content: "", createdAt: Date()),
            EmotionDiaryModel(id: UUID(), emotion: "happy_grade_1", content: "", createdAt: Date())
        ]
        
        let viewModel = HomeViewModel(store: mockStore)
        let expectation = XCTestExpectation(description: "Wait for recent diaries update")
        
        viewModel.$emotionSummary
            .dropFirst()
            .sink { summary in
                if !summary.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(viewModel.emotionSummary[.happy_grade_1], 2)
        XCTAssertEqual(viewModel.emotionSummary[.sad_grade_1], 1)
    }
}


