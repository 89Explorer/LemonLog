//
//  EmotionCategory.swift
//  LemonLog
//
//  Created by 권정근 on 10/15/25.
//

import Foundation
import UIKit


// MARK: ✅ enum - 감정 종류를 담은 열거형
enum EmotionCategory: String, CaseIterable, Codable {
    case none        // 빈값
    case happiness   // 😀 행복
    case sadness     // 😢 슬픔
    case anger       // 😡 분노
    case anxiety     // 😨 불안
    case calm        // 😌 평온
    case surprise    // 😲 놀람
    case love        // 🥰 사랑
    case shame       // 🫣 수치심
    case fatigue     // 😴 피로
}


// MARK: ✅ Struct - 감정의 메타 데이터를 담는 구조체
struct EmotionMetaData {
    let emoji: String              // 대분류 이모지
    let displayName: String        // UI에서 보여줄 대분류 이름
    let score: Int
    let backgroundColor: UIColor   // 컬렉션뷰, 태그용 대표 색
    let subEmotions: [String]      // "# 너무 좋아요"처럼 서술형 태그 문구
}


// MARK: ✅ Enum - 카테고리 구분
extension EmotionCategory {
    var meta: EmotionMetaData {
        switch self {
            
        case .none:
            return EmotionMetaData(
                emoji: "",
                displayName: "",
                score: 0,
                backgroundColor: UIColor.clear,
                subEmotions: []
            )
            
        case .happiness:
            return EmotionMetaData(
                emoji: "😀",
                displayName: "행복",
                score: 3,
                backgroundColor: UIColor.systemYellow.withAlphaComponent(0.65),
                subEmotions: [
                    "# 너무 좋아요",
                    "# 가슴이 설레요",
                    "# 정말 감사해요",
                    "# 마음이 편해요",
                    "# 만족스러워요",
                    "# 마냥 신나요"
                ]
            )
            
        case .sadness:
            return EmotionMetaData(
                emoji: "😢",
                displayName: "슬픔",
                score: -2,
                backgroundColor: UIColor.systemBlue.withAlphaComponent(0.65),
                subEmotions: [
                    "# 마음이 아파요",
                    "# 왠지 모르게 외로워요",
                    "# 기분이 가라앉아요",
                    "# 기대에 못 미쳤어요",
                    "# 후회가 돼요",
                    "# 보고 싶어요"
                ]
            )
            
        case .anger:
            return EmotionMetaData(
                emoji: "😡",
                displayName: "분노",
                score: -3,
                backgroundColor: UIColor.systemRed.withAlphaComponent(0.65),
                subEmotions: [
                    "# 너무 화가 나요",
                    "# 괜히 짜증나요",
                    "# 영 불쾌해요",
                    "# 억울해서 못 참겠어요",
                    "# 속이 터질 것 같아요",
                    "# 답답해서 미치겠어요"
                ]
            )
            
        case .anxiety:
            return EmotionMetaData(
                emoji: "😨",
                displayName: "불안",
                score: -2,
                backgroundColor: UIColor.systemIndigo.withAlphaComponent(0.65),
                subEmotions: [
                    "# 걱정이 많아요",
                    "# 긴장돼서 떨려요",
                    "# 안절부절 못 하겠어요",
                    "# 무서운 느낌이 들어요",
                    "# 마음이 불안해요",
                    "# 당황했어요"
                ]
            )
            
        case .calm:
            return EmotionMetaData(
                emoji: "😌",
                displayName: "평온",
                score: 1,
                backgroundColor: UIColor.systemTeal.withAlphaComponent(0.65),
                subEmotions: [
                    "# 차분하고 조용해요",
                    "# 마음이 평화로워요",
                    "# 편안하고 나른해요",
                    "# 생각이 없어요",
                    "# 그냥 덤덤해요",
                    "# 기분이 좋아요"
                ]
            )
            
        case .surprise:
            return EmotionMetaData(
                emoji: "😲",
                displayName: "놀람",
                score: 0,
                backgroundColor: UIColor.systemGreen.withAlphaComponent(0.65),
                subEmotions: [
                    "# 깜짝 놀랐어요",
                    "# 정말 대단해요",
                    "# 가슴이 벅차요",
                    "# 믿기지 않아요",
                    "# 흥미진진해요",
                    "# 정신이 없어요"
                ]
            )
            
        case .love:
            return EmotionMetaData(
                emoji: "🥰",
                displayName: "사랑",
                score: 2,
                backgroundColor: UIColor.systemPink.withAlphaComponent(0.65),
                subEmotions: [
                    "# 너무 애틋해요",
                    "# 따뜻하고 다정해요",
                    "# 감동받았어요",
                    "# 가깝게 느껴져요",
                    "# 소중한 기분이에요",
                    "# 보고만 있어도 좋아요"
                ]
            )
            
        case .shame:
            return EmotionMetaData(
                emoji: "🫣",
                displayName: "수치심",
                score: -2,
                backgroundColor: UIColor.systemGray.withAlphaComponent(0.65),
                subEmotions: [
                    "# 창피해서 숨고 싶어요",
                    "# 너무 부끄러워요",
                    "# 잘못한 것 같아요",
                    "# 민망해 죽겠어요",
                    "# 다신 그러지 말아야지",
                    "# 얼굴이 화끈거려요"
                ]
            )
            
        case .fatigue:
            return EmotionMetaData(
                emoji: "😴",
                displayName: "피로",
                score: -1,
                backgroundColor: UIColor.systemGray2.withAlphaComponent(0.65),
                subEmotions: [
                    "# 너무 지쳤어요",
                    "# 눈이 감겨요",
                    "# 아무것도 하기 싫어요",
                    "# 힘이 없어요",
                    "# 나른하고 무기력해요",
                    "# 입맛도 없어요"
                ]
            )
        }
    }
}
