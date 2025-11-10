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
    private let mode: DiaryMode
    
    
    // MARK: ✅ Published Properties (UI에 바인딩)
    @Published var diary: EmotionDiaryModel
    @Published var navigationTitle: String = ""
    @Published var saveButtonTitle: String = ""
    
    
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
            saveButtonTitle = "저장완료"
            navigationTitle = NSLocalizedString("diary_editor_title_create", comment: "Navigation title for creating a new diary entry")
        case .edit(let existing):
            diary = existing
            saveButtonTitle = "수정완료"
            navigationTitle = NSLocalizedString("diary_editor_title_edit", comment: "Navigation title for editing an existing diary entry")
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


// MARK: ✅ enum - Diary Mode
enum DiaryMode {
    case create
    case edit(EmotionDiaryModel)
}
