//
//  DiaryProviding.swift
//  LemonLog
//
//  Created by 권정근 on 10/22/25.
//

import Foundation
import Combine
import UIKit


// MARK: - 감정일기 데이터에 접근하기 위한 읽기 전용 인터페이스
//(ViewModel들은 이 프로토콜만 알고, 실제 Store 구현체는 몰라도 된다.)
@MainActor
protocol DiaryProviding: AnyObject {
    
    
    // MARK: ✅ Property
    // 감정일기 전체 목록 (Publisher로 실시간 반영됨)
    var diariesPublisher: AnyPublisher<[EmotionDiaryModel], Never> { get }
    
    // 즉시 접근 가능한 현재 상태 스냅샷 (읽기 전용)
    var snapshot: [EmotionDiaryModel] { get }
    
    
    // MARK: ✅ Read
    // 특정 일기 조회
    func diary(with id: String) -> EmotionDiaryModel?
    
    // 특정 주(week)에 해당하는 일기들 조회
    func diaries(inWeekOf date: Date) -> [EmotionDiaryModel]
    
    // 주간 감정별 통계 (예: 행복 3개, 슬픔 2개)
    func countByEmotion(inWeekOf date: Date) -> [EmotionCategory: Int]
    
    // 특정 주(week)에 해당하는 요일별 감정 요약
    // 여기서 반환 타입이 "DiaryCoreDataManager.Weekday" 이유
    // DiaryCoreDataManager에 enum이 정의되어 있고, ViewModel은 Calendar 계산을 알 필요가 없기 때문
    func fetchWeeklySummary(for date: Date) -> [DiaryCoreDataManager.Weekday: [EmotionCategory]]
    
    // 대표 이미지 로드
    func fetchFirstImages() async -> [(image: UIImage?, diaryID: String)]
    
    
    // MARK: ✅ Write
    @discardableResult
    func save(_ diary: EmotionDiaryModel) -> Bool
    
    @discardableResult
    func update(_ diary: EmotionDiaryModel) -> Bool
    
    @discardableResult
    func delete(id: String) -> Bool 
    
}
