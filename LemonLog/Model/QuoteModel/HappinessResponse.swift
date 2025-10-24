//
//  HappinessResponse.swift
//  LemonLog
//
//  Created by 권정근 on 10/25/25.
//

import Foundation


// MARK: - 전체 응답 구조
struct HappinessResponse: Decodable {
    let message: String
    let statusCode: Int
    let data: HappinessQuote
}


// MARK: - 실제 명언 데이터
struct HappinessQuote: Decodable, Identifiable {
    let id: Int
    let content: String
    let author: String
    let description: String?
    let link: String?
}
