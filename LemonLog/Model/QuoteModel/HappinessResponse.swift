//
//  HappinessResponse.swift
//  LemonLog
//
//  Created by 권정근 on 10/25/25.
//
// ▶️ Git Gist 에서 생성한 커스텀 API를 호출하는 데이터 모델 - CustomQoute ◀️

import Foundation


// MARK: ✅ 커스텀 명언 데이터 (새 API 대응)
struct CustomQuote: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let category: String
    let text: String
    let source: String
}


// MARK: ✅ 실제 명언 데이터 (새 API 대응)
struct HappinessQuote: Decodable, Identifiable, Hashable, Sendable {
    let id: UUID = UUID()
    let content: String            // message
    let author: String
    let authorProfile: String?     // authorProfile (옵셔널 처리)
    let description: String?       // 기존 필드는 남겨두되, 항상 nil일 수 있음
    let link: String?              // 동일

    enum CodingKeys: String, CodingKey {
        case content = "message"
        case author
        case authorProfile
        case description
        case link
    }
}


/*

 // 아래 내용은 명언을 불러오기 전의 URL 구조
 // MARK: - 전체 응답 구조
 struct HappinessResponse: Decodable {
     let message: String
     let statusCode: Int
     let data: HappinessQuote
 }


 // MARK: - 실제 명언 데이터
 struct HappinessQuote: Decodable, Identifiable, Hashable, Sendable {
     let id: Int
     let content: String
     let author: String
     let description: String?
     let link: String?
 }

 */
