//
//  QuoteServiceProviding.swift
//  LemonLog
//
//  Created by 권정근 on 12/2/25.
//
// ▶️ Git Gist 에서 생성한 커스텀 API를 호출하기 위한 프로토콜 ◀️

import Foundation
import Combine


// MARK: ✅ Protocol
// 서비스 프로토콜 정의 (의존성 주입을 위해 필요)
protocol QuoteServiceProviding: AnyObject {
    func fetchAllQuotes() -> AnyPublisher<[CustomQuote], Error>
}
