//
//  HappinessViewModel.swift
//  LemonLog
//
//  Created by 권정근 on 10/25/25.
//

import Foundation
import Combine


@MainActor
final class HappinessViewModel: ObservableObject {
    
    
    // MARK: ✅ Published Properties
    @Published var quote: HappinessQuote?   // 모델 단위로 관리
    
    private let service: HappinessServiceProviding
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ Init
    init(service: HappinessServiceProviding = HappinessService.shared) {
        self.service = service
    }
    
    
    // MARK: ✅ Method
    func loadQuote() {
        service.fetchRandomQuote()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    LogManager.print(.error, "명언 불러오기 실패: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] quoteData in
                self?.quote = quoteData
                LogManager.print(.success, "명언 업데이트 완료")
            })
            .store(in: &cancellables)
    }
}
