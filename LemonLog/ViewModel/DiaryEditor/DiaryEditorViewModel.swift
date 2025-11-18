//
//  DiaryEditorViewModel.swift
//  LemonLog
//
//  Created by 권정근 on 11/5/25.
//

import Foundation
import Combine
import UIKit


@MainActor
final class DiaryEditorViewModel: ObservableObject {
    
    
    // MARK: ✅ Dependencies
    private let store: DiaryProviding
    
    
    // MARK: ✅ State
    let mode: DiaryMode
    
    
    // MARK: ✅ Published Properties (UI에 바인딩)
    @Published var diary: EmotionDiaryModel
    @Published var navigationTitle: String = ""
    @Published var saveButtonTitle: String = ""
    
    @Published var validationResult: DiaryValidationResult? = nil    // 유효성 검사 결과를 VC로 전달
    
    @Published var saveCompleted: Bool = false    // 유효성 검사 통과 유무 확인
    
    @Published var contentSections = ContentSections(
        situation: "",
        thought: "",
        reeval: "",
        action: ""
    )
    
    
    // MARK: ✅ Init
    init(mode: DiaryMode, store: DiaryProviding? = nil) {
        self.store = store ?? DiaryStore.shared
        self.mode = mode
        
        switch mode {
        case .create:
          diary = EmotionDiaryModel(
            id: UUID(),
            emotion: "",
            content: "",
            createdAt: Date(),
            images: []
          )
            saveButtonTitle =  NSLocalizedString("save_button_title", comment: "")
            navigationTitle = NSLocalizedString("diary_editor_title_create", comment: "Navigation title for creating a new diary entry")
        case .edit(let existing):
            diary = existing
            saveButtonTitle = NSLocalizedString("update_button_title", comment: "")
            navigationTitle = NSLocalizedString("diary_editor_title_edit", comment: "Navigation title for editing an existing diary entry")
            
            if let data = existing.content.data(using: .utf8),
               let decoded = try? JSONDecoder().decode(ContentSections.self, from: data) {
                contentSections = decoded
            } else {
                // 예전 버전 호환 (혹은 JSON이 아니면 그냥 내용 전체 넣기)
                contentSections = ContentSections(
                    situation: existing.content,
                    thought: "",
                    reeval: "",
                    action: ""
                )
            }
        }
    }
}


// MARK: ✅ Extension - mode에 따라 저장 로직 분기
extension DiaryEditorViewModel {
    
    func saveDiary() {
        switch mode {
        case .create:
            store.save(diary)
        case .edit:
            store.update(diary)
        }
    }
    
    func deleteDiary() {
        store.delete(id: diary.id.uuidString)
    }
}


// MARK: ✅ Extension - 유효성 검사 함수
extension DiaryEditorViewModel {
    
    // 유효성 검사 확인 호출
    func attemptSaveDiary(
        situation: String,
        thought: String,
        reeval: String,
        action: String
    ) {
        
        let result = validateDiaryInputs(
            situation: situation,
            thought: thought,
            reeval: reeval,
            action: action
        )
        
        guard result.isValid else {
            validationResult = result
            return
        }
        
        // JSON으로 content 직렬화
        let content = ContentSections(
            situation: situation,
            thought: thought,
            reeval: reeval,
            action: action
        )
        
        if let jsonData = try? JSONEncoder().encode(content),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            diary.content = jsonString
        }
        
        saveDiary()
        saveCompleted = true 

    }
    
    // 일기 작성, 수정 시 입력값 유효성 검사
    func validateDiaryInputs(
        situation: String,
        thought: String,
        reeval: String,
        action: String
    ) -> DiaryValidationResult {

        var errors: [DiaryValidationError] = []
        
        let trimmedEmotion   = diary.emotion.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSituation = situation.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedThought   = thought.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedReeval    = reeval.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAction    = action.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1) 감정 선택 여부
        if trimmedEmotion.isEmpty {
            errors.append(
                DiaryValidationError(
                    field: .emotion,
                    message: NSLocalizedString(
                        "validation_error_emotion_required",
                        comment: "Message shown when emotion is not selected"
                    )
                )
            )
        }

        // 2) [상황]
        if trimmedSituation.isEmpty {
            errors.append(
                DiaryValidationError(
                    field: .situation,
                    message: NSLocalizedString(
                        "validation_error_situation_required",
                        comment: "Message shown when situation is empty"
                    )
                )
            )
        }

        // 3) [생각 / 원인]
        if trimmedThought.isEmpty {
            errors.append(
                DiaryValidationError(
                    field: .thought,
                    message: NSLocalizedString(
                        "validation_error_thought_required",
                        comment: "Message shown when thought is empty"
                    )
                )
            )
        }

        // 4) [새로운 시각 / 반박]
        if trimmedReeval.isEmpty {
            errors.append(
                DiaryValidationError(
                    field: .reeval,
                    message: NSLocalizedString(
                        "validation_error_reeval_required",
                        comment: "Message shown when reeval is empty"
                    )
                )
            )
        }

        // 5) [다음 행동]
        if trimmedAction.isEmpty {
            errors.append(
                DiaryValidationError(
                    field: .action,
                    message: NSLocalizedString(
                        "validation_error_action_required",
                        comment: "Message shown when action is empty"
                    )
                )
            )
        }

        return DiaryValidationResult(errors: errors)
    }

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


// MARK: ✅ Struct -> 기존 통합하여 보낸 데이터를
struct ContentSections: Codable {
    let situation: String
    let thought: String
    let reeval: String
    let action: String
}
