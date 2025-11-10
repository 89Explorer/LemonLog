//
//  CalendarViewModel.swift
//  LemonLog
//
//  Created by 권정근 on 11/7/25.
//

import Foundation
import Combine


// MARK: ✅ Enum
enum CalendarMode {
    case dateOnly          // 날짜만 표시
    case withEmotion       // 날짜 아래 감정 이모티콘 표시 (추후 확장용)
}


// MARK: ✅ ViewModel
@MainActor
final class CalendarViewModel: ObservableObject {
    
    
    // MARK: ✅ Published Properties
    @Published private(set) var months: [Date] = []     // [이전달, 현재달, 다음달]
    @Published private(set) var currentMonth: Date      // 현재 월
    @Published private(set) var mode: CalendarMode    //  표시 모드
  
    let calendar: Calendar
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ Init
    init(initialDate: Date = Date(), mode: CalendarMode) {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = .autoupdatingCurrent
        cal.timeZone = .autoupdatingCurrent
        cal.firstWeekday = 1 // 일요일 시작 (한국 기준)
        self.calendar = cal
        self.mode = mode
        
        // 초기 기준 월 (선택한 날짜 or 오늘)
        self.currentMonth = cal.startOfMonth(for: initialDate)
        
        // 초기 anchor 설정
        anchor(to: initialDate)
    }
    
    
    // MARK: ✅ DateFormatter
    private static let headerFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("yyyyMMMM")  // 각 언어의 표기 규칙에 맞게 구성
        return f
    }()
    
    
    // MARK: ✅ Setup (기준 날짜로 anchor 이동)
    func anchor(to date: Date) {
        let baseMonth = calendar.startOfMonth(for: date)
        let prev = calendar.date(byAdding: .month, value: -1, to: baseMonth)!
        let next = calendar.date(byAdding: .month, value: +1, to: baseMonth)!
        currentMonth = baseMonth
        months = [prev, baseMonth, next]
    }
    
    
    // MARK: ✅ Month 이동
    func moveMonth(isForward: Bool) {
        if isForward {
            let newCurrent = months[2]
            let newNext = calendar.date(byAdding: .month, value: 1, to: newCurrent)!
            months = [months[1], newCurrent, newNext]
            currentMonth = newCurrent
        } else {
            let newCurrent = months[0]
            let newPrev = calendar.date(byAdding: .month, value: -1, to: newCurrent)!
            months = [newPrev, newCurrent, months[1]]
            currentMonth = newCurrent
        }
    }

}


// MARK: ✅ Extension - CalendarViewModel Hepler Method
extension CalendarViewModel {
    
    // 해당 달의 1일부터 마지막 날까지의 Date 배열 반환
    // 단, 그 달의 첫 번째 요일이 주의 몇 번째냐에 따라 앞쪽에 nil(빈칸)을 넣어 달력 형태 맞춤
    func days(in month: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else { return [] }
        
        // 요일 오프셋 계산
        let weekdayOffset = (calendar.component(.weekday, from: startOfMonth) - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: weekdayOffset)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        return days
    }
    
    func headerTitle(for month: Date) -> String {
        Self.headerFormatter.string(from: month)
    }
    
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    // 두 날짜가 같은 달안에 속하는지를 비교하는 함수
    // toGranularity: .month 이면 → "두 날짜가 같은 연도·같은 월 인가?"
    // toGranularity: .day 이면 → "두 날짜가 같은 날(연·월·일) 인가?"
    func isSameMonth(_ date: Date, as month: Date) -> Bool {
        calendar.isDate(date, equalTo: month, toGranularity: .month)
    }
    
}


// MARK: ✅ Extension - Hepler Method
extension Calendar {
    
    // 어떤 날짜가 오더라도 그 달의 1일 00:00 정규화
    func startOfMonth(for day: Date) -> Date {
        let comps = dateComponents([.year, .month], from: day)
        return self.date(from: comps)!   // ← self.date 로 명확히
    }
}
