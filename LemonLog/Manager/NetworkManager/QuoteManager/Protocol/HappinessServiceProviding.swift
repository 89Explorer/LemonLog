//
//  HappinessServiceProviding.swift
//  LemonLog
//
//  Created by 권정근 on 10/27/25.
//

import Foundation
import Combine


// MARK: ✅ Protocol
// HappinessService가 “네트워크 호출 기능을 제공”하는 역할이라면,
// 그 역할을 프로토콜로 추상화하는 게 테스트 구조상 가장 깔끔합니다.
protocol HappinessServiceProviding {
    func fetchRandomQuote() -> AnyPublisher<HappinessQuote, Error>
}
