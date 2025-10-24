//
//  HappinessService.swift
//  LemonLog
//
//  Created by 권정근 on 10/25/25.
//

import Foundation
import Combine



final class HappinessService {
    
    
    // MARK: ✅ Singleton
    static let shared = HappinessService()
    private init() {}
    
    
    // MARK: ✅ Method
    func fetchRandomQuote() -> AnyPublisher<HappinessQuote, Error> {
        guard let url = URL(string: "https://api.sobabear.com/happiness/random-quote") else {
            LogManager.print(.error, "잘못된 URL")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        LogManager.print(.info, "요청 시작: \(url.absoluteString)")
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                if let httpResponse = output.response as? HTTPURLResponse {
                    LogManager.print(.info, "상태 코드: \(httpResponse.statusCode)")
                }
                return output.data
            }
            .decode(type: HappinessResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                guard response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                LogManager.print(.success, "명언 데이터 수신 성공: \(response.data.author)")
                return response.data
            }
            .receive(on: DispatchQueue.main)
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
            .eraseToAnyPublisher()
    }
    
}
