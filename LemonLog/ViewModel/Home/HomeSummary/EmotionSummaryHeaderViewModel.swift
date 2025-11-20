//
//  EmotionSummaryHeaderViewModel.swift
//  LemonLog
//
//  Created by 권정근 on 11/19/25.
//


import Foundation
import Combine


@MainActor
final class EmotionSummaryHeaderViewModel: ObservableObject {
    
    
    // MARK: ✅ Published Properties
    @Published private(set) var currentMonth: Date      // 항상 "해당 월의 1일"
    @Published private(set) var weeklyModels: [WeeklyEmotionSummaryModel] = []
    
    
    // MARK: ✅ Dependencies
    let calendar: Calendar
    private let store: DiaryProviding
    private var cancellables = Set<AnyCancellable>()
    
    
    
    // MARK: ✅ Init
    init(store: DiaryProviding? = nil,
         initialDate: Date = Date()
    ) {
        self.store = store ?? DiaryStore.shared
        
        var cal = Calendar(identifier: .gregorian)
        cal.locale = .autoupdatingCurrent
        cal.timeZone = .autoupdatingCurrent
        cal.firstWeekday = 1
        //cal.minimumDaysInFirstWeek = 1
        self.calendar = cal
        
        // ✅ 초기 월은 "해당 월의 1일"
        let normalized = cal.startOfMonth(for: initialDate)
        self.currentMonth = normalized
        
        // ✅ 초기 월 기준으로 로드
        loadMonthlySummary(for: normalized)
        
    }
    
    
    // MARK: ✅ monthTitle
    func monthTitle() -> String {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("yyyyMMMM")
        return f.string(from: currentMonth)
    }
    
    
    // MARK: ✅ moveMonth
    func moveMonth(isForward: Bool) {
        let value = isForward ? 1 : -1
        
        // 다음달 또는 이전달 계산
        if let moved = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            let normalized = calendar.startOfMonth(for: moved)
            
            currentMonth = normalized
            loadMonthlySummary(for: normalized)
        }
    }
    
    
    // MARK: ✅ 월 전체 Summary 로직
    func loadMonthlySummary(for baseDate: Date) {
        
        weeklyModels = []  // 덮어쓰기 방지
        
        let repDates = representativeWeekDates(inMonth: baseDate)
        
        let models = repDates.map { date -> WeeklyEmotionSummaryModel in
            let weekRange = weekRange(for: date)
            let diaries = store.fetchWeeklySummary(for: date)
            
            return WeeklyEmotionSummaryModel(
                weekDescription: weekDescription(from: weekRange),
                top3Emotion: top3Emotions(from: diaries),
                mostFrequentByWeekday: mostFrequentEmotionByWeekday(from: diaries)
            )
        }
        
        self.weeklyModels = models
    }
    
}


// MARK: ✅ Extension
extension EmotionSummaryHeaderViewModel {
    
    
    func representativeWeekDates(inMonth base: Date) -> [Date] {
        
        let cal = calendar
        let monthStart = cal.startOfMonth(for: base)
        guard let nextMonth = cal.date(byAdding: .month, value: 1, to: monthStart) else { return [] }
        
        // 1) 대표 날짜 후보 (1,8,15,22,29)
        var reps: [Date] = []
        [1, 8, 15, 22, 29].forEach { day in
            if let d = cal.date(byAdding: .day, value: day - 1, to: monthStart),
               d < nextMonth {
                reps.append(d)
            }
        }
        
        // 2) 마지막 날이 마지막 주에 포함되는지 확인
        if let lastDay = cal.date(byAdding: .day, value: -1, to: nextMonth) {
            let lastWeekStart = weekStart(for: lastDay)
            
            if let lastRep = reps.last {
                let lastRepWeekStart = weekStart(for: lastRep)
                
                if lastWeekStart != lastRepWeekStart {
                    reps.append(lastDay)  // 마지막 주 추가
                }
            }
        }
        
        return reps.sorted()
    }
    
    func weekStart(for date: Date) -> Date {
        let cal = calendar
        let weekday = cal.component(.weekday, from: date)
        
        // 일요일 = 1
        let daysToSunday = (weekday - cal.firstWeekday + 7) % 7
        return cal.date(byAdding: .day, value: -daysToSunday, to: date)!
    }
    
    func weekRange(for date: Date) -> DateInterval {
        let start = weekStart(for: date)
        let end = calendar.date(byAdding: .day, value: 6, to: start)!
        return DateInterval(start: start, end: end)
    }
    
    func weekDescription(from interval: DateInterval) -> String {
        
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("MMMd")
        
        let weekOfMonth = calendar.component(.weekOfMonth, from: interval.start)
        let weekSuffix = NSLocalizedString("week_suffix", comment: "")
        
        return "\(f.string(from: interval.start)) ~ \(f.string(from: interval.end)) (\(weekOfMonth)\(weekSuffix))"
    }
    
    
    // Most Frequent By Weekday (요일별 최빈 감정)
    func mostFrequentEmotionByWeekday(
        from weeklySummary: [DiaryCoreDataManager.Weekday: [EmotionCategory]]
    ) -> [DiaryCoreDataManager.Weekday: EmotionCategory] {
        
        var result: [DiaryCoreDataManager.Weekday: EmotionCategory] = [:]
        
        for (weekday, arr) in weeklySummary {
            guard !arr.isEmpty else { continue }
            
            let counts = Dictionary(grouping: arr, by: { $0 })
                .mapValues { $0.count }
            
            let maxCount = counts.values.max()
            let candidates = counts.filter { $0.value == maxCount }.map { $0.key }
            
            let final = arr.last(where: { candidates.contains($0) }) ?? arr.last!
            result[weekday] = final
        }
        
        return result
    }
    
    
    // Top 3 Emotions
    func top3Emotions(from weeklySummary: [DiaryCoreDataManager.Weekday: [EmotionCategory]]) -> [EmotionCategory] {
        
        let all = weeklySummary.values.flatMap { $0 }
        guard !all.isEmpty else { return [] }
        
        let counts = Dictionary(grouping: all, by: { $0 }).mapValues { $0.count }
        
        let sorted = counts.sorted { lhs, rhs in
            if lhs.value == rhs.value {
                let lastL = all.lastIndex(of: lhs.key) ?? 0
                let lastR = all.lastIndex(of: rhs.key) ?? 0
                return lastL > lastR
            }
            return lhs.value > rhs.value
        }
            .map { $0.key }
        
        return Array(sorted.prefix(3))
    }
}

