//
//  MainHomeViewModel.swift
//  LemonLog
//
//  Created by 권정근 on 12/2/25.
//

import Foundation
import Combine
import UIKit


final class MainHomeViewModel: ObservableObject {
    
    
    // MARK: ✅ QuoteViewModel 불러오기
    // MainHomeViewModel은 QuoteViewModel을 내부 속성으로 가지고, @Published로 선언하여
    // View가 이 속성의 변화(todayQuote 등)도 감지할 수 있게 합니다.
    @Published var quoteVM: QuoteViewModel
    
    
    // MARK: ✅ CalendarViewModel 불러오기
    @Published var calendarVM: CalendarViewModel
    
    
    // MARK: ✅ Private Properties (데이터 캐싱 및 Combine 관리)
    private var cancellables = Set<AnyCancellable>()  // Combine 구독 관리
    
    
    // MARK: ✅ Initialization
    init(
        quoteViewModel: QuoteViewModel = QuoteViewModel(),
        calendarViewModel: CalendarViewModel = CalendarViewModel()
    ) {
        self.quoteVM = quoteViewModel
        self.calendarVM = calendarViewModel
        
        // 초기화 시 명언 데이터를 로드합니다.
        quoteVM.loadQuotes()
    }
    
    
    // MARK: ✅ Public Interface (명언 갱신 위임)
    // View에서 명언 갱신 버튼을 누르면, 이 함수를 통해 QuoteViewModel로 로직을 위임합니다.
    func refreshTodayQuote() {
        quoteVM.refreshQuotes()
    }
    
}

