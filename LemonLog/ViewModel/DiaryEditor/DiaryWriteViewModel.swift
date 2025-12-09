//
//  DiaryWriteViewModel.swift
//  LemonLog
//
//  Created by 권정근 on 11/5/25.
//

import Foundation
import Combine
import UIKit


@MainActor
final class DiaryWriteViewModel: ObservableObject {
    
    
    // MARK: ✅ Dependencies
    private let store: DiaryProviding
    let mode: DiaryMode
    
    
    // MARK: ✅ UI State
    @Published var uiState: DiaryEditorUIState
    
    
    // MARK: ✅ Data (diary)
    // originalDiary를 복사한 데이터
    @Published var editableDiary: EmotionDiaryModel
   
    // 원본 파일
    private let originalDiary: EmotionDiaryModel?
   
    // 에러 메시지
    @Published var errorMessage: String?
    
    // 감정 선택 가능 유무를 담는 프로퍼티
    @Published var canSelectEmotion: Bool = true

    
    
    // MARK: ✅ Initialization
    init(mode: DiaryMode, store: DiaryProviding? = nil) {
        self.store = store ?? DiaryStore.shared
        self.mode = mode
        
        switch mode {
            
        case .create:
            originalDiary = nil
            editableDiary = EmotionDiaryModel(
                id: UUID(),
                emotion: EmotionSelection(category: .none, subEmotion: []),
                content: ContentSections(situation: "", thought: "", reeval: "", action: ""),
                createdAt: Date(),
                images: []
            )
            
            uiState = DiaryEditorUIState(
                navigationTitle: NSLocalizedString("diary_editor_title_create", comment: ""),
                saveButtonTitle: NSLocalizedString("save_button_title", comment: "")
            )
            
        case .edit(let diary):
            originalDiary = diary
            editableDiary = diary
            
            uiState = DiaryEditorUIState(
                navigationTitle: NSLocalizedString("diary_editor_title_edit", comment: ""),
                saveButtonTitle: NSLocalizedString("update_button_title", comment: "")
            )
        }
    }
}


// MARK: ✅ Extension (저장 + 유효성 검사 + 삭제)
extension DiaryWriteViewModel {

    // 유효성 검사 후 저장하는 메서드
    func trySaveDiary() {

        let validation = validate(editableDiary)

        if !validation.isValid {
            uiState.validationResult = validation
            return
        }

        saveEditableDiary()
        uiState.saveCompleted = true
    }

    // 유효성 검사 (content 부분 작성 확인)
    private func validate(_ diary: EmotionDiaryModel) -> DiaryValidationResult {

        var errors: [DiaryValidationError] = []

        let content = diary.content

        if content.situation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.init(field: .situation,
                message: NSLocalizedString("validation_error_situation_required", comment: "")))
        }

        if content.thought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.init(field: .thought,
                message: NSLocalizedString("validation_error_thought_required", comment: "")))
        }

        if content.reeval.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.init(field: .reeval,
                message: NSLocalizedString("validation_error_reeval_required", comment: "")))
        }

        if content.action.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.init(field: .action,
                message: NSLocalizedString("validation_error_action_required", comment: "")))
        }

        return DiaryValidationResult(errors: errors)
    }

    // 저장 메서드
    private func saveEditableDiary() {
        switch mode {
        case .create:
            store.save(editableDiary)
        case .edit:
            store.update(editableDiary)
        }
    }

    // 삭제 메서드
    func deleteDiary() {
        if let origin = originalDiary {
            store.delete(id: origin.id.uuidString)
        }
    }
}


// MARK: ✅ Helper Method
extension DiaryWriteViewModel {
    
    // 내용 작성 업데이트 함수
    func updateContent(_ field: DiaryField, text: String) {
        switch field {
        case .situation: editableDiary.content.situation = text
        case .thought: editableDiary.content.thought = text
        case .reeval: editableDiary.content.reeval = text
        case .action: editableDiary.content.action = text
        default: break
        }
    }

}


// MARK: ✅ Extension (감정 단계의 유효성검사)
extension DiaryWriteViewModel {
    
    // 감정 선택 업데이트 함수
    func updateEmotion(_ emotion: EmotionSelection) {
        editableDiary.emotion = emotion
    }
    
    // 감정 선택시 유효성 검사 + 상태 업데이트
    @discardableResult
    func trySelectEmotion(_ emotion: EmotionSelection) -> Bool {
        
        // 아무것도 선택 안한 경우
        if emotion.subEmotion.isEmpty {
            editableDiary.emotion = EmotionSelection(category: .none, subEmotion: [])
            return true
        }
        
        // 최대 3개 제한
        if emotion.subEmotion.count > 3 {
            triggerError(.selectionLimit)
            return false
        }
        
        // 다른 카테고리 선택 불가
        let currentCategory = editableDiary.emotion.category
        if currentCategory != .none && currentCategory != emotion.category {
            triggerError(.categoryMismatch)
            return false
        }
        
        // 정상 선택 -> viewModel 업데이트
        //canSelectEmotion = true
        updateEmotion(emotion)
        return true
    }

    // 에러메세지를 전달하는 메서드
    private func triggerError(_ error: DiaryValidationErrorMessage) {
        errorMessage = error.localizedMessage
    }
    
    @discardableResult
    func canProceedToNextStep(_ step: DiaryWriteStep) -> Bool {
        switch step {
            
        case .emotion:
            guard !editableDiary.emotion.subEmotion.isEmpty else {
                triggerError(.emotionRequired)
                return false
            }
            return true
            
        case .situation:
            guard !editableDiary.content.situation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                triggerError(.situationRequired)
                return false
            }
            return true
            
        case .thought:
            guard !editableDiary.content.thought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                triggerError(.thoughtRequired)
                return false
            }
            return true
            
        case .reeval:
            guard !editableDiary.content.reeval.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                triggerError(.reevaluateRequired)
                return false
            }
            return true
            
        case .action:
            guard !editableDiary.content.action.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                triggerError(.actionRequired)
                return false
            }
            return true
            
        case .dateAndImages:
            return true
        }
    }
}


// MARK: ✅ enum - Diary Mode
enum DiaryMode {
    case create
    case edit(EmotionDiaryModel)
}


// MARK: ✅ Struct (화면용 UI 상태 + 저장용 상태를 담는 구조체)
struct DiaryEditorUIState {
    var navigationTitle: String
    var saveButtonTitle: String
    var saveCompleted: Bool = false
    var validationResult: DiaryValidationResult? = nil
}


// MARK: ✅ Enum (Emotion 유효성 검사에 따른 안내 멘트)
enum DiaryValidationErrorMessage: String {
    
    // 감정 단계(Emotion)
    case emotionRequired = "validation_error_emotion_required"
    case selectionLimit = "max_selection_limit"
    case categoryMismatch = "category_mismatch_error"
    case minimumEmotionSelection = "minimum_selection_required"
    
    // Situation 단계
    case situationRequired = "validation_error_situation_required"
    
    // Thought 단계
    case thoughtRequired = "validation_error_thought_required"
    
    // Re-evaluate 단계
    case reevaluateRequired = "validation_error_reeval_required"
    
    // Action 단계
    case actionRequired = "validation_error_action_required"
    
    
    // MARK: - Localized Message
    var localizedMessage: String {
        return NSLocalizedString(
            self.rawValue,
            tableName: "Localizable",
            bundle: .main,
            value: self.defaultMessage,
            comment: ""
        )
    }
    
    
    // MARK: - Default Message (키 누락 시 fallback)
    private var defaultMessage: String {
        switch self {
            
        // Emotion 관련
        case .emotionRequired:
            return "오늘 느낀 감정을 선택해 주세요."
        case .selectionLimit:
            return "최대 3개까지만 선택할 수 있어요!"
        case .categoryMismatch:
            return "다른 카테고리 감정은 함께 선택할 수 없어요!"
        case .minimumEmotionSelection:
            return "최소한 1개의 감정을 선택해주세요!"
            
        // Situation
        case .situationRequired:
            return "상황을 입력해 주세요."
            
        // Thought
        case .thoughtRequired:
            return "생각 / 원인을 입력해 주세요."
            
        // Re-evaluate
        case .reevaluateRequired:
            return "새로운 시각 / 반박을 입력해 주세요."
            
        // Action
        case .actionRequired:
            return "다음 행동을 입력해 주세요."
        }
    }
}


// MARK: ✅ Enum -> DiaryContent 내의 텍스트뷰 유효성 검사 모걱
enum DiaryField {
    case situation
    case thought
    case reeval
    case action
}


// MARK: ✅ Struct -> 각 필드의 값고 메시지 담당
struct DiaryValidationError {
    let field: DiaryField
    let message: String
}
// 예: DiaryValidationError(field: .situation, message: "상황을 입력해주세요.")


// MARK: ✅ Struct -> 여러 개의 필드의 값을 담는 담당
struct DiaryValidationResult {
    let errors: [DiaryValidationError]   // 여러 개 필드 동시 오류 가능
    var isValid: Bool { errors.isEmpty }
}
