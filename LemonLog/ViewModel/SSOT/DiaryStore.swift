//
//  DiaryStore.swift
//  LemonLog
//
//  Created by 권정근 on 10/22/25.
//

import Foundation
import Combine
import UIKit


// MARK: - 감정일기 데이터의 전역 상태를 관리하는 ViewModel (Single Source of Truth)
@MainActor
final class DiaryStore: DiaryProviding {
    
    
    // MARK: ✅ Singleton
    static let shared = DiaryStore(manager: DiaryCoreDataManager.shared)
    
    
    // MARK: ✅ Dependencies
    private let manager: DiaryCoreDataManager
    
    
    // MARK: ✅ Subjects
    private let diariesSubject = CurrentValueSubject<[EmotionDiaryModel], Never>([])
    

    // MARK: ✅ Publishers (DiaryProviding)
    var diariesPublisher: AnyPublisher<[EmotionDiaryModel], Never> {
        diariesSubject.eraseToAnyPublisher()
    }
    
    var snapshot: [EmotionDiaryModel] { diariesSubject.value }
    
    
    // MARK: ✅ Init
    init(manager: DiaryCoreDataManager) {
        self.manager = manager
        Task {
            await reload()
        }
    }
    
   
    // MARK: ✅ READ
    // 전체 일기 로드 (비동기)
    func reload() async {
        await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            let diaries = await self.manager.fetchDiairesAsync(mode: .all)
            let sorted = diaries.sorted(by: { $0.createdAt > $1.createdAt })
            await MainActor.run {
                self.diariesSubject.send(sorted)
            }
        }.value
    }
    
    func diary(with id: String) -> EmotionDiaryModel? {
        diariesSubject.value.first { $0.id.uuidString == id }
    }
    
    func diaries(inWeekOf date: Date) -> [EmotionDiaryModel] {
        let calendar = Calendar.current
        guard let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start else { return [] }
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? date
        return diariesSubject.value.filter { $0.createdAt >= start && $0.createdAt < end }
    }
    
    func countByEmotion(inWeekOf date: Date) -> [EmotionCategory : Int] {
        let weekly = diaries(inWeekOf: date)
        return Dictionary(grouping: weekly) { EmotionCategory(rawValue: $0.emotion)! }.mapValues(\.count)
    }

    
    func fetchWeeklySummary(for date: Date) -> [DiaryCoreDataManager.Weekday : [EmotionCategory]] {
        manager.fetchWeeklySummary(for: date)
    }
    
    func fetchFirstImages() async -> [(image: UIImage?, diaryID: String)] {
        await manager.fetchFirstImages()
    }
    
    
    // MARK: ✅ Write
    @discardableResult
    func save(_ diary: EmotionDiaryModel) -> Bool {
        let success = manager.saveDiary(diary)
        if success {
            var newList = diariesSubject.value
            newList.append(diary)
            diariesSubject.send(newList.sorted { $0.createdAt > $1.createdAt })
        }
        return success
    }
    
    @discardableResult
    func update(_ diary: EmotionDiaryModel) -> Bool {
        let success = manager.updateDiary(diary)
        if success {
            var list = diariesSubject.value
            if let index = list.firstIndex(where: { $0.id == diary.id }) {
                list[index] = diary
                diariesSubject.send(list.sorted { $0.createdAt > $1.createdAt })
            } else {
                Task { await reload() }
            }
        }
        return success
    }
    
    @discardableResult
    func delete(id: String) -> Bool {
        let success = manager.deleteDiary(by: id)
        if success {
            var list = diariesSubject.value
            list.removeAll { $0.id.uuidString == id }
            diariesSubject.send(list)
        }
        return success
    }
}
