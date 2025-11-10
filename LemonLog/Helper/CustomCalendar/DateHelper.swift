//
//  DateHelper.swift
//  LemonLog
//
//  Created by 권정근 on 11/7/25.
//

import Foundation

/*
// MARK: ✅ Enum - 커스텀 캘린더를 만들기 위한 헬퍼 메서드 모음
enum DateHelper {
    
    // 이번 달의 첫 번째 날짜 (예: 2025-11-01)
    static func startOfMonth(_ date: Date, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    // 이번 달의 마지막 날짜 (얘: 2025-11-30)
    static func endOfMonth(_ date: Date, calendar: Calendar) -> Date {
        guard let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return date
        }
        let comps = DateComponents(month: 1, day: -1)
        return calendar.date(byAdding: comps, to: start)!
    }
    
    // 이번 달의 총 일수
    static func numberOfDays(inMonth date: Date, calendar: Calendar) -> Int {
        calendar.range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    // 이번 달의 첫 번쨰 요일 인덱스 (0=일요일, 1=월요일...)
    static func weekdayIndexOfFirstDay(_ date: Date, calendar: Calendar) -> Int {
        let firstDay = startOfMonth(date, calendar: calendar)
        let weekday = calendar.component(.weekday, from: firstDay)
        return weekday - 1    // 0-based
    }
    
    // 핵심: 달력용 그리드 (6주 x 7일) 데이터 생성
    static func buildMonthGrid(
        for baseDate: Date,
        selected: Date?,
        minDate: Date?,
        maxDate: Date?,
        calendar: Calendar,
        locale:Locale
    ) -> MonthGrid {
        
        let startOfMonth = startOfMonth(baseDate, calendar: calendar)
        let daysInMonth = numberOfDays(inMonth: baseDate, calendar: calendar)
        
        // 이번 달 첫 요일 (로케일 기준, firstWeekday 반영)
        var firstWeekday = calendar.component(.weekday, from: startOfMonth)
        firstWeekday = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        // 이전 달 마지막 날
        guard let prevMonth = calendar.date(byAdding: .month, value: -1, to: baseDate) else {
            LogManager.print(.error, "이전 달 계산 실패")
            fatalError("이전 달 계산 실패")
        }
        let dayInPrevMonth = numberOfDays(inMonth: prevMonth, calendar: calendar)
        
        var days: [DayCellModel] = []
        
        // 이전 달 날짜 채우기
        if firstWeekday > 0 {
            for i in stride(from: firstWeekday - 1, through: 0, by: -1) {
                let day = dayInPrevMonth - i
                guard let date = calendar.date(bySetting: .day, value: day, of: prevMonth) else { continue }
                days.append(makeDayModel(for: date, ownership: .previousMonth, selected: selected, minDate: minDate, maxDate: maxDate, calendar: calendar))
            }
        }
        
        // 이번 달 날짜 채우기
        for day in 1...daysInMonth {
            guard let date = calendar.date(bySetting: .day, value: day, of: baseDate) else { continue }
            days.append(makeDayModel(for: date, ownership: .currentMonth, selected: selected, minDate: minDate, maxDate: maxDate, calendar: calendar))
        }
        
        // 다음 달 날짜 채우기 (6주 그리드 유지)
        while days.count < 42 {
            let nextIndex = days.count - (firstWeekday + daysInMonth)
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: baseDate),
                  let date = calendar.date(bySetting: .day, value: nextIndex + 1, of: nextMonth)
            else { break }
            
            days.append(makeDayModel(for: date, ownership: .nextMonth, selected: selected, minDate: minDate, maxDate: maxDate, calendar: calendar))
        }
        
        // 완성
        let comps = calendar.dateComponents([.year, .month], from: baseDate)
        return MonthGrid(year: comps.year!, month: comps.month!, days: days)
    }
    
    // DayCellModel 생성 헬퍼
    private static func makeDayModel(
        for date: Date,
        ownership: DayOwnership,
        selected: Date?,
        minDate: Date?,
        maxDate: Date?,
        calendar: Calendar
    ) -> DayCellModel {
        
        let isToday = calendar.isDateInToday(date)
        let isSelected = selected.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        
        // 날짜 제한 검사
        var isEnabled: Bool = true
        if let min = minDate, date < min { isEnabled = false }
        if let max = maxDate, date > max { isEnabled = false }
        
        return DayCellModel(
            date: date,
            ownership: ownership,
            isToday: isToday,
            isSelected: isSelected,
            isEnabled: isEnabled
        )
    }
    
}
*/
