//
//  QuoteViewModel.swift
//  LemonLog
//
//  Created by 권정근 on 12/2/25.
//
// ▶️ Git Gist 에서 생성한 커스텀 API를 호출하기 위한 ViewModel ◀️

import Foundation
import Combine


// MARK: ViewModel
final class QuoteViewModel: ObservableObject {
    
    
    // MARK: ✅ Published Properties (View에 바인딩)
    @Published var todayQuote: CustomQuote? // View에 표시될 오늘의 명언
    @Published var isLoading: Bool = false  // 로딩 상태 표시
    @Published var errorMessage: String?    // 오류 메시지
    
    
    // MARK: ✅ Private Properties (데이터 캐싱 및 Combine 관리)
    private var quoteService: QuoteServiceProviding   // 메모리에 전체 명언 목록 저장
    private var allQuotes: [CustomQuote] = []
    private var cancellables = Set<AnyCancellable>()  // Combine 구독 관리
    
    
    init(quoteService: QuoteServiceProviding = QuoteService.shared) {
        self.quoteService = quoteService
    }
    
    
    // MARK: ✅ Main Method
    // Gist에서 전체 명언 데이터를 로드, 로드 성공 시 랜덤 명언을 선택합니다.
    func loadQuotes() {
        
        // 이미 데이터가 메모리에 있다면 (재실행이 아닌 단순 갱신이라면) 바로 랜덤 선택
        if !allQuotes.isEmpty {
            selectRandomQuote()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        quoteService.fetchAllQuotes()
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    
                    // 네트워크 실패 시 오류 메시지 업데이트
                    LogManager.print(.error, "[ViewModel] 데이터 로드 실패: \(error.localizedDescription)")
                    self.errorMessage = "명언을 불러오는 데 실패햇습니다. 네트워크를 확인해주세요."
                case .finished:
                    LogManager.print(.success, "[ViewModel] 데이터 로드 완료 및 구독 종료")
                }
            } receiveValue: { [weak self] quotes in
                guard let self = self else { return }
                // 받은 전체 목록을 메모리에 저장
                self.allQuotes = quotes
                // 랜덤으로 명언을 선택하여 View에 게시
                self.selectRandomQuote()
            }
            .store(in: &cancellables)  // 구독 관리

    }
    
    
    // MARK: ✅ Business Logic
    // 메모리에 저장된 전체 명언 목록에서 랜덤으로 하나를 선택하여 todayQuote를 업데이트합니다.
    func selectRandomQuote() {
      
        guard !allQuotes.isEmpty else {
            LogManager.print(.error, "[ViewModel] 명언 목록이 비어있어 랜덤 선택 불가")
            self.errorMessage = "표시할 명언 데이터가 없습니다."
            return
        }
        
        // 전체 목록 중 하나를 랜덤으로 선택
        let randomQuote = allQuotes.randomElement()
        
        // todayQuote를 업데이트하고 View에 알림
        self.todayQuote = randomQuote
        LogManager.print(.success, "[ViewModel] 새로운 랜덤 명언 선택됨: \(randomQuote?.text ?? "")")
    }
    
    
    // MARK: ✅ Public Interface (View에서 버튼 클릭시 호출)
    // 사용자 요청에 의해 새로운 랜덤 명언을 표시할 떄 사용합니다.
    func refreshQuotes() {
        
        // 메모리 데이터가 있다면 네트워크 호출 없이 즉시 갱신
        if !allQuotes.isEmpty {
            selectRandomQuote()
        } else {
            
            // 메모리에 데이터가 없다면 로드부터 다시 시도
            loadQuotes()
        }
    }

}
