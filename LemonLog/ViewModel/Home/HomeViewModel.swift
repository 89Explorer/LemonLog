//
//  HomeViewModel.swift
//  LemonLog
//
//  Created by 권정근 on 10/24/25.
//

import Foundation
import Combine
import UIKit


@MainActor
final class HomeViewModel: ObservableObject {
    
    
    // MARK: ✅ Dependencies
    private let happinessViewModel = HappinessViewModel()
    private let store: DiaryProviding
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ Published Properties (UI에 바인딩)
    @Published private(set) var recentDiaries: [EmotionDiaryModel] = []
    @Published private(set) var emotionSummary: [EmotionCategory: Int] = [:]
    @Published private(set) var weeklySummary: [DiaryCoreDataManager.Weekday: [EmotionCategory]] = [:]
    @Published private(set) var diaryImages: [(image: UIImage?, diaryID: String)] = []
    @Published private(set) var quote: HappinessQuote?
    
    
    // MARK: ✅ Init
    init(store: DiaryProviding? = nil) {
        
        // Swift 6 - safe 초기화
        self.store = store ?? DiaryStore.shared
        //observeStore()   // 목업 데이터를 위해 잠시 멈춤
        bindHappinessQuote()
        Task {
            //await loadDiaryImages()    // 목업 데이터를 위해 잠시 멈춤
            //loadWeeklySummary()
        }
        //happinessViewModel.loadQuote()   // 홈 진입시 명언을 바로 호출. // 목업 데이터를 위해 잠시 멈춤
    }
    
    
    // MARK: ✅ Observe DiaryStore Updates
    private func observeStore() {
        store.diariesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] diaries in
                guard let self else { return }
                
                // 최근 일기 5개만 보이기
                self.recentDiaries = Array(diaries.prefix(5))
                
                // 주간 감정 비율 계산
                self.emotionSummary = store.countByEmotion(inWeekOf: Date())
                
                // 주간 감정 요약
                self.loadWeeklySummary()
                
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: ✅ Load Weekly Emotion Summary
    func loadWeeklySummary(for date: Date = Date()) {
        weeklySummary = store.fetchWeeklySummary(for: date)
    }
    
    
    // MARK: ✅ Load Diary Images
    func loadDiaryImages() async {
        let results = await store.fetchFirstImages()
        await MainActor.run {
            self.diaryImages = results
        }
    }
    
    
    // MARK: ✅ Bind HappinessViewModel
    private func bindHappinessQuote() {
        happinessViewModel.$quote
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quote in
                self?.quote = quote
            }
            .store(in: &cancellables)
    }
}


// MARK: ✅ Extension - 요일 별 감정 데이터 가공
extension HomeViewModel {
    
    // 요일별 가장 많이 선택된 감정
    // 예시: 월요일: [😀, 😡, 😀] → 😀
    var mostFrequentEmotionByWeekday: [DiaryCoreDataManager.Weekday: EmotionCategory] {
        var result: [DiaryCoreDataManager.Weekday: EmotionCategory] = [:]
        
        for (weekday, emotions) in weeklySummary {
            guard !emotions.isEmpty else { continue }
            
            // 감정별 등장 횟수 집계
            let counts = Dictionary(grouping: emotions, by: { $0 }).mapValues { $0.count }
            
            // 가장 많은 감정 수 찾기
            let maxCount = counts.values.max() ?? 0
            
            // 등장 횟수가 최대인 감정들 필터링
            let mostFrequent = counts.filter { $0.value == maxCount }.map { $0.key }
            
            // 최대 등장 횟수가 동률이라면 가장 "마지막에 선택된" 감정을 사용
            let finalEmotion = emotions.last(where: { mostFrequent.contains($0) }) ?? emotions.last!
            result[weekday] = finalEmotion
        }
        
        return result
    }
    
    // 이번 주 전체에서 가장 많이 선택된 감정 상위 3개
    // 예시: [😀:4, 😢:3, 😡:3] → [😀, 😡, 😢]
    var top3EmotionsThisWeek: [EmotionCategory] {
        // 모든 요일의 감정을 하나로 합침
        let allEmotions = weeklySummary.values.flatMap { $0 }
        guard !allEmotions.isEmpty else { return [] }
        
        // 감정별 등장 횟수 계산
        let counts = Dictionary(grouping: allEmotions, by: { $0 }).mapValues { $0.count }
        
        // 최대 등장 수 찾기 + 최근 감정 기준 정렬
        let sorted = counts
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    // 등장 횟수가 같으면 마지막으로 등장한 순서대로
                    let lastIndexL = allEmotions.lastIndex(of: lhs.key) ?? 0
                    let lastIndexR = allEmotions.lastIndex(of: rhs.key) ?? 0
                    return lastIndexL > lastIndexR
                } else {
                    return lhs.value > rhs.value
                }
            }
            .map { $0.key }
        
        // 상위 3개만 반환
        return Array(sorted.prefix(3))
    }

}


// MARK: ✅ Extension - Mock Preview용 ViewModel
extension HomeViewModel {
    
    static func mock() -> HomeViewModel {
        let mockStore = MockDiaryStore()
        let vm = HomeViewModel(store: mockStore)
        
        // ✅ 명언 섹션 (하드코딩된 테스트 데이터)
        vm.quote = HappinessQuote(
            id: 1,
            content: "“당신이 은혜를 베푼 사람보다는 당신에게 호의를 베푼 사람이 당신에게 또 다른 호의를 베풀 준비가 되어있을 것이다.",
            author: "벤자민 프랭클린",
            description: "18세기 정치가이자 과학자, 실용적 지혜의 상징",
            link: nil
        )
        
        // ✅ 주간 감정 요약 (MockDiaryStore의 더미 데이터 사용)
        vm.weeklySummary = mockStore.fetchWeeklySummary(for: Date())
        
        // ✅ 감정 비율 (Emotion Summary)
        vm.emotionSummary = [
            ._1: 10,
            ._2: 22,
            ._3: 7,
            ._4: 22,
            ._5: 2,
            ._6: 7,
            ._7: 27
        ]
        
        // ✅ 최근 일기 (Recent Entries)
        vm.recentDiaries = (1...5).map {
            EmotionDiaryModel(
                id: UUID(),
                emotion: "\($0)",
                content: ["좋은 하루였다", "조금 슬펐다"].randomElement()!,
                createdAt: Date().addingTimeInterval(-Double($0) * 3600)
            )
        }
        
        // ✅ 사진 일기 (Photo Diaries)
        vm.diaryImages = (1...6).map { (UIImage(systemName: "photo"), "\($0)") }
        
        return vm
    }
}


// MARK: ✅ Mock Store
@MainActor
final class MockDiaryStore: DiaryProviding {
    
    var mockDiaries: [EmotionDiaryModel] = []
    var mockImages: [(UIImage?, String)] = []

    func fetchWeeklySummary(for date: Date) -> [DiaryCoreDataManager.Weekday: [EmotionCategory]] {
        return [
            .mon: [._1, ._2, ._3],
            .tue: [._4],
            .wed: [._5, ._2],
            .thu: [._1],
            .fri: [._3, ._3, ._2],
            .sat: [],
            .sun: [._1, ._1, ._1]
        ]
    }

    var diariesPublisher: AnyPublisher<[EmotionDiaryModel], Never> {
        Just(mockDiaries).eraseToAnyPublisher()
    }
    
    var snapshot: [EmotionDiaryModel] { mockDiaries }

    func diary(with id: String) -> EmotionDiaryModel? {
        mockDiaries.first { $0.id.uuidString == id }
    }
    
    func diaries(inWeekOf date: Date) -> [EmotionDiaryModel] { mockDiaries }
    
    func countByEmotion(inWeekOf date: Date) -> [EmotionCategory: Int] {
        Dictionary(grouping: mockDiaries) { EmotionCategory(rawValue: $0.emotion) ?? ._1 }
            .mapValues(\.count)
    }
    
    func fetchFirstImages() async -> [(image: UIImage?, diaryID: String)] {
        mockImages
    }
}
