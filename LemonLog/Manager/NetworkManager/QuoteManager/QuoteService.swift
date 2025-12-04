//
//  QuoteService.swift
//  LemonLog
//
//  Created by 권정근 on 12/2/25.
//
// ▶️ Git Gist 에서 생성한 커스텀 API를 호출하는 매니저 ◀️

import Foundation
import Combine


// MARK: ✅ Gist 기반 명언 서비스 구현
// GitHub Gist Raw URL을 통해 모든 명언 데이터를 비동기적으로 가져오는 서비스
final class QuoteService: QuoteServiceProviding {
    
    
    // Constants - URL 주소
    // 직접 제공한 Gist Raw URL 주소
    private let gistRawURLString = "https://gist.githubusercontent.com/89Explorer/acb2693347a8f8efb26efa735d5b3196/raw/0d8249868ff11d5cf6bd40fcd75bc1e24483c1fe/quotes.json"
    
    // Singleton
    static let shared = QuoteService()
    private init() { }
    
    // Method
    // Gist로부터 전체 명언을 가져옵니다.
    func fetchAllQuotes() -> AnyPublisher<[CustomQuote], any Error> {
        
        // 🔹 URL 생성
        guard let url = URL(string: gistRawURLString) else {
            LogManager.print(.error, "잘못된 URL")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        LogManager.print(.info, "요청 시작: \(url.absoluteString)")
        
        return URLSession.shared.dataTaskPublisher(for: url)
        // 🔹 HTTP 상태 코드 검증 및 Data 추출
            .tryMap { output -> Data in
                if let httpResponse = output.response as? HTTPURLResponse {
                    LogManager.print(.info, "상태 코드: \(httpResponse.statusCode)")
                    
                    guard (200..<300).contains(httpResponse.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                }
                return output.data
            }
        // 🔹 CustomQoute 배열 ([CustomQuote])로 디코딩
            .decode(type: [CustomQuote].self, decoder: JSONDecoder())
        // 🔹 메인 스레드에서 수신 (UI 업데이트)
            .receive(on: DispatchQueue.main)
        // 🔹 이벤트 로그 처리 및 디버깅
            .handleEvents(
                receiveOutput: { quote in
                    LogManager.print(.success, "명언 데이터 수신 성공: \(quote)")
                },
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        LogManager.print(.error, "API 호출 실패: \(error.localizedDescription)")
                    case .finished:
                        LogManager.print(.success, "API 호출 완료")
                    }
                    
                }
            )
        // Publisher 타입 통합 및 반환
            .eraseToAnyPublisher()
        
    }

}
