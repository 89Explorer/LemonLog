//
//  HappinessService.swift
//  LemonLog
//
//  Created by 권정근 on 10/25/25.
//

import Foundation
import Combine


// MARK: - 🍋 행복 명언 서비스
final class HappinessService: HappinessServiceProviding {
    
    
    // MARK: ✅ Singleton
    static let shared = HappinessService()
    private init() {}
    
    
    // MARK: ✅ Method
    // 명언 가져오기 (Fetch Random Quote)
    func fetchRandomQuote() -> AnyPublisher<HappinessQuote, Error> {
        
        // 🔹 1. URL 생성
        guard let url = URL(string: "https://korean-advice-open-api.vercel.app/api/advice") else {
            LogManager.print(.error, "잘못된 URL")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        LogManager.print(.info, "요청 시작: \(url.absoluteString)")
        
        
        return URLSession.shared.dataTaskPublisher(for: url)
        // 🔹 2. HTTP 상태 코드 검증 + 로그
            .tryMap { output -> Data in
                if let httpResponse = output.response as? HTTPURLResponse {
                    LogManager.print(.info, "상태 코드: \(httpResponse.statusCode)")
                    
                    guard (200..<300).contains(httpResponse.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                }
                return output.data
            }
        // 🔹 3. 바로 HappinessQuote로 디코딩
            .decode(type: HappinessQuote.self, decoder: JSONDecoder())
        // 🔹 4. 메인 스레드에서 수신
            .receive(on: DispatchQueue.main)
        // 🔹 5. 이벤트 로그 처리
            .handleEvents(
                receiveOutput: { quote in
                    LogManager.print(.success, "명언 데이터 수신 성공: \(quote.author)")
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
        // 🔹 6. Publisher 타입 통합
            .eraseToAnyPublisher()
    }
    
}
