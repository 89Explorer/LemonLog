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

        if diary.emotion.category == .none {
            errors.append(.init(field: .emotion,
                message: NSLocalizedString("validation_error_emotion_required", comment: "")))
        }

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
            triggerError("최대 3개까지만 선태할 수 있어요!")
            return false
        }
        
        // 다른 카테고리 선택 불가
        let currentCategory = editableDiary.emotion.category
        if currentCategory != .none && currentCategory != emotion.category {
            triggerError("다른 카테고리는 함께 선택할 수 없어요!")
            return false
        }
        
        // 정상 선택 -> viewModel 업데이트
        //canSelectEmotion = true
        updateEmotion(emotion)
        return true
    }

    // 에러메세지를 전달하는 메서드
    private func triggerError(_ message: String) {
        errorMessage = message
    }
    
    @discardableResult
    func canProceedToNextStep(currentStep: DiaryWriteStep) -> Bool {

        switch currentStep {

        case .emotion:
            // 최소 1개 subEmotion 선택했는지 검사
            if editableDiary.emotion.subEmotion.isEmpty {
                triggerError("최소한 1개의 감정을 선택해주세요!")
                return false
            }
            return true

        default:
            return true
        }
    }

}


// MARK: ✅ Struct (화면용 UI 상태 + 저장용 상태를 담는 구조체)
struct DiaryEditorUIState {
    var navigationTitle: String
    var saveButtonTitle: String
    var saveCompleted: Bool = false
    var validationResult: DiaryValidationResult? = nil
}


// MARK: ✅ enum - Diary Mode
enum DiaryMode {
    case create
    case edit(EmotionDiaryModel)
}


// MARK: ✅ Enum -> DiaryContent 내의 텍스트뷰 유효성 검사 모걱
enum DiaryField {
    case emotion
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
