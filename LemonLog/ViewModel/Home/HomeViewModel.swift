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
                
            }
            .store(in: &cancellables)
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


// MARK: ✅ Extension
extension HomeViewModel {
    
    static func mock() -> HomeViewModel {
        
        let vm = HomeViewModel(store: MockDiaryStore())
        
        // ✅ 실제 observeStore(), loadQuote() 등은 실행하지 않음
        vm.quote = HappinessQuote(
            id: 1,
            content: "당신이 은혜를 베푼 사람보다는 당신에게 호의를 베푼 사람이 당신에게 또 다른 호의를 베풀 준비가 되어있을 것이다.",
            author: "벤자민 프랭클린",
            description: nil,
            link: nil
        )
        
        vm.emotionSummary = [
            ._1: 10,
            ._2: 22,
            ._3: 7,
            ._4: 22,
            ._5: 2,
            ._6: 7,
            ._7: 27
        ]
        
        vm.recentDiaries = [
            EmotionDiaryModel(id: UUID(), emotion: "1", content: "좋은 하루였다", createdAt: Date()),
            EmotionDiaryModel(id: UUID(), emotion: "2", content: "조금 슬펐다", createdAt: Date()),
            EmotionDiaryModel(id: UUID(), emotion: "3", content: "좋은 하루였다", createdAt: Date()),
            EmotionDiaryModel(id: UUID(), emotion: "4", content: "조금 슬펐다", createdAt: Date()),
            EmotionDiaryModel(id: UUID(), emotion: "5", content: "좋은 하루였다", createdAt: Date()),
        ]
        
        vm.diaryImages = [
            (UIImage(systemName: "photo"), "1"),
            (UIImage(systemName: "photo"), "2"),
            (UIImage(systemName: "photo"), "3"),
            (UIImage(systemName: "photo"), "4"),
            (UIImage(systemName: "photo"), "5"),
            (UIImage(systemName: "photo"), "6")
        ]
        return vm
        
    }
}


// MARK: ✅ Mock Store
@MainActor
final class MockDiaryStore: DiaryProviding {
    

    // MARK: ✅ 테스트에서 주입/세팅할 가짜 데이터
    var mockDiaries: [EmotionDiaryModel] = []
    
    var mockImages: [(UIImage?, String)] = []
    
    
    // MARK: ✅ 프로토콜 요구사항 구현
    var diariesPublisher: AnyPublisher<[EmotionDiaryModel], Never> {
        // "Just" -> "값 하나를 즉시 한 번만 방출하고 완료하는 간단한 Publisher"
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
