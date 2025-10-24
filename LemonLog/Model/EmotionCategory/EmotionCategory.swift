//
//  EmotionCategory.swift
//  LemonLog
//
//  Created by 권정근 on 10/15/25.
//

import Foundation
import UIKit


// MARK: ✅ enum - 감정 종류를 담은 열거형
enum EmotionCategory: String, CaseIterable {
    case angry_grade_1
    case angry_grade_2
    case angry_grade_3
    
    case coffee_grade_1
    
    case happy_grade_1
    case happy_grade_2
    case happy_Grade_3
    
    case hungry_grade_1
    case hungry_grade_2
    case hungry_grade_3
    
    case love_grade_1
    case love_grade_2
    case love_grade_3
    
    case mask_grade_1
    
    case ridiculous_grade_1
    case ridiculous_grade_2
    case ridiculous_grade_3
    
    case sad_grade_1
    case sad_grade_2
    case sad_grade_3
    
    case sleepy_grade_1
    case sleepy_grade_2
    case sleepy_grade_3
    
    case sweat_grade_1
    
    // 이미지 이름과 rawValue 통일 -> 중복 switch 제거
    var emotionImage: UIImage? {
        return UIImage(named: "lemon_\(rawValue)")
    }
    
}
