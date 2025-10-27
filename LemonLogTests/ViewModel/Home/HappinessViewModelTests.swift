//
//  HappinessViewModelTests.swift
//  LemonLogTests
//
//  Created by 권정근 on 10/25/25.
//

import XCTest
import Combine
@testable import LemonLog


// MARK: - Mock Service
final class MockHappinessService: HappinessServiceProviding {
    func fetchRandomQuote() -> AnyPublisher<HappinessQuote, Error> {
        let mockQuote = HappinessQuote(
            id: 999,
            content: "행복은 마음가짐의 문제다.",
            author: "익명",
            description: "테스트용 Mock 데이터",
            link: nil
        )
        return Just(mockQuote)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}


// MARK: - Tests
@MainActor
final class HappinessViewModelTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    private var viewModel: HappinessViewModel!
    private var mockService: MockHappinessService!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        cancellables = []
        mockService = MockHappinessService()
        viewModel = HappinessViewModel(service: mockService)
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Tests
    func test_loadQuote_UpdatesPublishedValues() {
        // Given
        let expectation = XCTestExpectation(description: "ViewModel이 HappinessService 결과로 상태를 업데이트해야 함")
        
        // Then
        viewModel.$quote
            .dropFirst() // 초기값("") 이후의 첫 번째 emit만 받음
            .sink { quote in
                XCTAssertEqual(quote, "행복은 마음가짐의 문제다.")
                XCTAssertEqual(self.viewModel.author, "")

                LogManager.print(.success, "✅ ViewModel 상태 업데이트 성공")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.loadQuote()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        wait(for: [expectation], timeout: 3.0)
    }
}
