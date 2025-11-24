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
    
    
    // MARK: ✅ loadMonthlySummary  월 전체 Summary 로직
    func loadMonthlySummary(for baseDate: Date) {
        
        weeklyModels = []  // 덮어쓰기 방지
        
        let repDates = representativeWeekDates(inMonth: baseDate)
        
        let models = repDates.map { date -> WeeklyEmotionSummaryModel in
        let diaries = store.fetchWeeklySummary(for: date)
            
            return self.makeWeeklyEmotionSummaryModel(for: date, baseMonth: date, weeklySummary: diaries)
        }
        
        self.weeklyModels = models
    }
    
    
    // MARK: ✅ makeWeeklyEmotionSummaryModel
    func makeWeeklyEmotionSummaryModel(
        for date: Date,
        baseMonth: Date,
        weeklySummary: [DiaryCoreDataManager.Weekday: [EmotionCategory]]
    ) -> WeeklyEmotionSummaryModel {
        
        let interval = weekRange(for: date)
        let weekDates = buildWeekDates(from: interval)
        
        return WeeklyEmotionSummaryModel(
            weekDescription: weekDescription(for: date, inMonth: baseMonth),
            top3Emotion: top3Emotions(from: weeklySummary),
            mostFrequentByWeekday: mostFrequentEmotionByWeekday(from: weeklySummary),
            weekDates: weekDates,
            baseMonth: baseMonth
        )
    }
    
    
    // MARK: ✅ buildWeekDates
    // 주간 (일 ~ 토) 날짜를 요일 enum으로 매핑해주는 함수
    func buildWeekDates(from interval: DateInterval) -> [DiaryCoreDataManager.Weekday: Date] {
        let cal = calendar
        var dict: [DiaryCoreDataManager.Weekday: Date] = [:]

        // 이번 주의 7일 반복
        for offset in 0..<7 {
            
            // 매일 하루씩 증가한 날짜
            let day = cal.date(byAdding: .day, value: offset, to: interval.start)!
            
            // Calendar 방식 (1 ~ 7) 요일 index
            let weekdayIndex = cal.component(.weekday, from: day)
            
            // 요일 index(Int) → Weekday enum 변환
            if let weekday = DiaryCoreDataManager.Weekday(weekdayIndex: weekdayIndex) {
                dict[weekday] = day
            }
        }

        return dict
    }

}


// MARK: ✅ Extension
extension EmotionSummaryHeaderViewModel {
    
    
    // MARK: ✅ representativeWeekDates
    // 각 주의 대표 날짜를 생성하는 함수
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
        // lastDay -> 30일, lastWeekStart -> 30일, lastRep -> 29일, lastRepWeekStart -> 23일
        // lastWeekStart과 lastRepWeekStart 둘이 다르면, reps에 포함
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
    
    
    // MARK: ✅ weekStart
    // 주어진 날짜(date)가 속한 '주(week)'의 시작 요일(일요일)을 구하는 함수
    func weekStart(for date: Date) -> Date {
        let cal = calendar
        
        // Calendar 방식 (1 ~ 7) 요일 index
        let weekday = cal.component(.weekday, from: date)
        
        // 일요일 = 1
        let daysToSunday = (weekday - cal.firstWeekday + 7) % 7
        return cal.date(byAdding: .day, value: -daysToSunday, to: date)!
    }
    
    
    // MARK: ✅ weekRange
    // 일요일 ~ 토요일까지의 범위 (DateInterval)을 만든는 함수
    func weekRange(for date: Date) -> DateInterval {
        let start = weekStart(for: date)
        let end = calendar.date(byAdding: .day, value: 6, to: start)!
        return DateInterval(start: start, end: end)
    }
    
    
    // MARK: ✅ weekNumer
    // baseMonth 기준으로 date가 몇 번째 주인지 계산
    func weekNumber(for date: Date, inMonth baseMonth: Date) -> Int {
        let cal = calendar
        let monthStart = cal.startOfMonth(for: baseMonth)
        let firstWeekStart = weekStart(for: monthStart)
        
        let currentWeekStart = weekStart(for: date)
        
        // 주차 차이 계산
        let diff = cal.dateComponents([.weekOfYear], from: firstWeekStart, to: currentWeekStart).weekOfYear ?? 0
        
        return diff + 1
    }
    
    
    // MARK: ✅ weekDescription
    // (1월 1일 ~ 1월 7일 (1주차))
    func weekDescription(for date: Date, inMonth baseMonth: Date) -> String {
        let range = weekRange(for: date)

        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("MMMd")

        let weekNum = weekNumber(for: date, inMonth: baseMonth)
        let weekSuffix = NSLocalizedString("week_suffix", comment: "")

        return "\(f.string(from: range.start)) ~ \(f.string(from: range.end)) (\(weekNum)\(weekSuffix))"
    }
    
    
    // ✅ MARK: mostFrequentEmotionByWeekday
    // (요일별 최빈 감정)
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
    
    
    // MARK: ✅ Top 3 Emotions
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

