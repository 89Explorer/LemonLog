//
//  HappinessServiceTests.swift
//  LemonLogTests
//
//  Created by 권정근 on 10/25/25.
//

import XCTest
import Combine
@testable import LemonLog

final class HappinessServiceTests: XCTestCase {
    
    private var cancellables: Set<AnyCancellable>!
    private var service: HappinessService!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        service = HappinessService.shared
    }
    
    override func tearDown() {
        cancellables = nil
        service = nil
        super.tearDown()
    }
    
    func test_fetchRandomQuote_Success() {
        // Given
        let expectation = XCTestExpectation(description: "명언 API 호출이 성공적으로 완료되어야 함")
        
        // When
        service.fetchRandomQuote()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("API 호출 실패: \(error.localizedDescription)")
                }
            }, receiveValue: { quote in
                // Then
                XCTAssertFalse(quote.content.isEmpty, "명언 내용이 비어있으면 안 됨")
                XCTAssertFalse(quote.author.isEmpty, "작가 정보가 비어있으면 안 됨")
                LogManager.print(.success, "✅ 테스트 성공: \(quote.author) - \(quote.content)")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 5.0)
    }
}
