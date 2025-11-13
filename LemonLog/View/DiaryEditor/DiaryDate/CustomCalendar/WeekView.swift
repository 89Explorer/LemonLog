//
//  WeekView.swift
//  LemonLog
//
//  Created by 권정근 on 11/7/25.
//
import UIKit


final class WeekView: UIStackView {
    
    
    // MARK: ✅ Properties
    private var daysOfWeek: [String] = []
    private var calendar: Calendar
    private var locale: Locale
    
    
    // MARK: ✅ Init
    init(locale: Locale = .autoupdatingCurrent, calendar: Calendar = .autoupdatingCurrent) {
        self.locale = locale
        var cal = calendar
        cal.locale = locale
        self.calendar = cal
        
        super.init(frame: .zero)
        configureStackView()
        configureLabels()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Configure StackView
    private func configureStackView() {
        axis = .horizontal
        alignment = .center
        distribution = .fillEqually
        spacing = 0
    }
    
    
    // MARK: ✅ Configure Label
    // 캘린더의 요일(일, 월, 화....)을 화면에 표시하는 함수
    private func configureLabels() {
        
        // 현재 설정된 달력(calnedar)와 언어(locale)을 기준으로 요일 이름 배열 가져오는 부분
        daysOfWeek = Self.localizedWeekdaySymbols(using: calendar, locale: locale)
        
        // '일요일'과 '토요일'의 실제 인덱스를 계산
        let sundayIndex = Self.rotatedIndex(of: 1, firstWeekday: calendar.firstWeekday)
        let saturdayIndex = Self.rotatedIndex(of: 7, firstWeekday: calendar.firstWeekday)
        
        // Locale: fr_FR (프랑스)
        // calendar.firstWeekday: 2 (월요일)
        // 배열 순서: [일, 월, 화, 수 ...토]
        // sundaayIndex: 6
        // saturdayIndex: 5
        
        for (index, day) in daysOfWeek.enumerated() {
            let label = UILabel()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textAlignment = .center
            
            // 주말 강조 (다크모드 대응)
            if index == sundayIndex {
                label.textColor = UIColor.systemRed.withAlphaComponent(0.85)
            } else if index == saturdayIndex {
                label.textColor = UIColor.systemBlue.withAlphaComponent(0.85)
            } else {
                label.textColor = UIColor.black.withAlphaComponent(0.75)
            }
        
            addArrangedSubview(label)
        }
    }
    
}


// MARK: ✅ Hepler Method
extension WeekView {
    
    // MARK: localizedWeekdaySymbols - 현재 지역(locale)과 달력(calendar)에 맞게 요일 이름 배열을 만들어주는 함수
    private static func localizedWeekdaySymbols(using calendar: Calendar, locale: Locale) -> [String] {
        let formatter = DateFormatter()
        
        // 언어와 지역 설정
        formatter.locale = locale
        
        // shortStandaloneWeekdaySymbols - "2025년 11월 (월)" 같은 문장용이 아닌 독립된 요일 라벨용
        guard var symbols = formatter.shortStandaloneWeekdaySymbols else {
            return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        }
        
        // 사용 중인 달력에 이 지역을 적용
        var cal = calendar
        cal.locale = locale
        
        // 달력의 첫 번째 요일이 배열에서 몇 번째인지 계산하는 부분
        let firstWeekdayIndex = (cal.firstWeekday - 1 + 7) % 7
        
        if firstWeekdayIndex > 0 {
            let prefix = symbols[..<firstWeekdayIndex]
            let suffix = symbols[firstWeekdayIndex...]
            symbols = Array(suffix + prefix)
            
            // 에: symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], firstWeekdayIndex = 1
            // prefix = ["Sun"]
            // suffix = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            // Array(suffix + prefix) -> ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        }
        
        return symbols
    }
    
    
    // MARK:  rotatedIndex - Locale에 맞게 "일요일/토요일"의 실제 배열 위치를 계산
    private static func rotatedIndex(of weekday: Int, firstWeekday: Int) -> Int {
        // (요일 - 시작요일 + 7) % 7
        return (weekday - firstWeekday + 7) % 7
    }
}
