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
        guard let url = URL(string: "https://api.sobabear.com/happiness/random-quote") else {
            LogManager.print(.error, "잘못된 URL")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        LogManager.print(.info, "요청 시작: \(url.absoluteString)")
        
        // 🔹 2. 네트워크 요청 (URLSession)
        return URLSession.shared.dataTaskPublisher(for: url)
            // 🔹 3. 응답 처리 (상태 코드 확인)
            .tryMap { output -> Data in
                if let httpResponse = output.response as? HTTPURLResponse {
                    LogManager.print(.info, "상태 코드: \(httpResponse.statusCode)")
                }
                return output.data
            }
            // 🔹 4. JSON 디코딩
            .decode(type: HappinessResponse.self, decoder: JSONDecoder())
            // 🔹 5. 상태 코드 검증 + 데이터 추출
            .tryMap { response in
                guard response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                LogManager.print(.success, "명언 데이터 수신 성공: \(response.data.author)")
                return response.data
            }
            // 🔹 6. 메인 스레드에서 수신
            .receive(on: DispatchQueue.main)
            // 🔹 7. 이벤트 로그 처리
            .handleEvents(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        LogManager.print(.error, "API 호출 실패: \(error.localizedDescription)")
                    case .finished:
                        LogManager.print(.success, "API 호출 완료")
                    }
                    
                }
            )
            // 🔹 8. Publisher 타입 통합
            .eraseToAnyPublisher()
    }
    
}
