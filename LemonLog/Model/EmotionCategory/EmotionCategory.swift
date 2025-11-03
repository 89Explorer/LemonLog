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
    
    case _0 = "0"
    case _1 = "1"
    case _2 = "2"
    case _3 = "3"
    case _4 = "4"
    case _5 = "5"
    case _6 = "6"
    case _7 = "7"
    case _8 = "8"
    case _9 = "9"
    case _10 = "10"
    case _11 = "11"
    case _12 = "12"
    case _13 = "13"
    case _14 = "14"
    case _15 = "15"
    case _16 = "16"
    case _17 = "17"
    case _18 = "18"
    case _19 = "19"
    case _20 = "20"
    case _21 = "21"
    case _22 = "22"
    case _23 = "23"
    case _24 = "24"
    case _25 = "25"
    
    // 이미지 이름과 rawValue 통일 -> 중복 switch 제거
    var emotionImage: UIImage? {
        return UIImage(named: "\(rawValue)")
    }
    
}
//enum EmotionCategory: String, CaseIterable {
//    
//    case angry_grade_1
//    case angry_grade_2
//    case angry_grade_3
//    
//    case coffee_grade_1
//    
//    case happy_grade_1
//    case happy_grade_2
//    case happy_Grade_3
//    
//    case hungry_grade_1
//    case hungry_grade_2
//    case hungry_grade_3
//    
//    case love_grade_1
//    case love_grade_2
//    case love_grade_3
//    
//    case mask_grade_1
//    
//    case ridiculous_grade_1
//    case ridiculous_grade_2
//    case ridiculous_grade_3
//    
//    case sad_grade_1
//    case sad_grade_2
//    case sad_grade_3
//    
//    case sleepy_grade_1
//    case sleepy_grade_2
//    case sleepy_grade_3
//    
//    case sweat_grade_1
//    
//    // 이미지 이름과 rawValue 통일 -> 중복 switch 제거
//    var emotionImage: UIImage? {
//        return UIImage(named: "lemon_\(rawValue)")
//    }
//    
//}

