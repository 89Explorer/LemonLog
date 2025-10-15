//
//  EmotionDiaryModel.swift
//  LemonLog
//
//  Created by 권정근 on 10/15/25.
//

import Foundation
import UIKit


// MARK: ✅ Struct - 감정일기를 담을 구조체
struct EmotionDiaryModel: Identifiable {
    let id: UUID
    var emotion: String            // 선택된 감정 (ex. "행복", "화남" 등)
    var content: String            // 일기 내용
    var createdAt: Date            // 작성 날짜
    var images: [UIImage]?         // ✅ 여러 장의 이미지 첨부
}


extension EmotionDiaryModel {
    var emotionCategory: EmotionCategory? {
        get { EmotionCategory(rawValue: emotion) }
        set { emotion = newValue?.rawValue ?? "" }
    }
}

