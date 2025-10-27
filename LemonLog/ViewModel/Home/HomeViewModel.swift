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
        observeStore()
        bindHappinessQuote()
        Task {
            await loadDiaryImages()
        }
        happinessViewModel.loadQuote()   // 홈 진입시 명언을 바로 호출
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
