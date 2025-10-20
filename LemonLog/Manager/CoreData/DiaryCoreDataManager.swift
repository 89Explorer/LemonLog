//
//  DiaryCoreDataManager.swift
//  LemonLog
//
//  Created by 권정근 on 10/18/25.
//

import Foundation
import CoreData
import UIKit


// MARK: - DiaryCoreDataManager (Singleton)
@MainActor
final class DiaryCoreDataManager {
    
    // MARK: ✅ Singleton
    static let shared = DiaryCoreDataManager()
    private init() {}
    
    
    // MARK: ✅ Persistent Container
    private lazy var persistentContainer: NSPersistentContainer = {
        // "LemonLog" -> "Core Data 모델을 담은 파일명"
        let container = NSPersistentContainer(name: "LemonLog")
        container.loadPersistentStores { _, error in
            if let error = error {
                LogManager.print(.error, "Core Data 초기화 실패: \(error.localizedDescription)")
            } else {
                LogManager.print(.success, "Core Data 초기화 성공")
            }
        }
        return container
    }()
    
    
    // MARK: ✅ Context
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    
    // MARK: ✅ Save Context
    func saveContext() {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            LogManager.print(.success, "Core Data 저장 성공")
        } catch {
            LogManager.print(.error, "Core Data 저장 실패: \(error.localizedDescription)")
        }
    }
    
}


// MARK: - CRUD for EmotionDiaryEntity
extension DiaryCoreDataManager {
    
    
    // MARK: ✅ Create - 감정일기 저장
    func saveDiary(_ model: EmotionDiaryModel) {
        let diary = EmotionDiaryEntity(context: context)
        diary.id = model.id.uuidString
        diary.emotion = model.emotion
        diary.content = model.content
        diary.createdAt = model.createdAt
        
        // 이미지 저장
        if let images = model.images {
            for (index, image) in images.enumerated() {
                if let path = DiaryImageFileManager.shared.saveImage(image, diaryID: model.id.uuidString, index: index) {
                    let imageEntity = DiaryImageEntity(context: context)
                    imageEntity.id = UUID().uuidString
                    imageEntity.imagePath = path
                    imageEntity.diary = diary
                    diary.addToImages(imageEntity)
                }
            }
        }
        saveContext()
    }
    
    
    // MARK: ✅ Read - 감정일기 불러오기
    enum FetchMode {
        case all
        case paged(limit: Int, offset: Int)
    }
    
    func fetchDiaries(mode: FetchMode) -> [EmotionDiaryModel] {
        let request: NSFetchRequest<EmotionDiaryEntity> = EmotionDiaryEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        switch mode {
        case .all:
            break
        case .paged(let limit, let offset):
            request.fetchLimit = limit
            request.fetchOffset = offset
        }
        
        do {
            let entities = try context.fetch(request)
            let models = entities.compactMap { $0.toModel() }
            LogManager.print(.success, "총 \(models.count)개의 감정일기 로드 완료")
            return models
        } catch {
            LogManager.print(.error, "감정일기 불러오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchDiairesAsync(mode: FetchMode) async -> [EmotionDiaryModel] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                Task { @MainActor in   // 메인 액터로 되돌려 실행
                    let result  = self.fetchDiaries(mode: mode)
                    continuation.resume(returning: result)
                }
            }
        }
    }
    
    func fetchDiary(by id: UUID) -> EmotionDiaryModel? {
        let request: NSFetchRequest<EmotionDiaryEntity> = EmotionDiaryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        request.fetchLimit = 1
        
        do {
            guard let entity = try context.fetch(request).first else {
                LogManager.print(.warning, "해당 ID의 감정일기를 찾을 수 없습니다.")
                return nil
            }
            return entity.toModel()
        } catch {
            LogManager.print(.error, "특정 감정일길 로드 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchAllDiaryImages() async -> [(image: UIImage, diaryID: String)] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var results: [(UIImage, String)] = []
                let baseFolder = DiaryImageFileManager.shared.folderURL
                
                do {
                    let diaryFolders = try FileManager.default.contentsOfDirectory(at: baseFolder, includingPropertiesForKeys: nil)
                    
                    for diaryFolder in diaryFolders {
                        let diaryID = diaryFolder.lastPathComponent
                        let imageFiles = try FileManager.default.contentsOfDirectory(at: diaryFolder, includingPropertiesForKeys: nil)
                        
                        for file in imageFiles {
                            if let image = UIImage(contentsOfFile: file.path(percentEncoded: true)) {
                                results.append((image, diaryID))
                            }
                        }
                    }
                    
                    LogManager.print(.success, "총 \(results.count)개의 이미지 로드 완로")
                    continuation.resume(returning: results)
                } catch {
                    LogManager.print(.error, "이미지 로드 실패, \(error.localizedDescription)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    func fetchFirstImages() async -> [(image: UIImage?, diaryID: String)] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var results: [(UIImage?, String)] = []
                let baseFolder = DiaryImageFileManager.shared.folderURL
                
                do {
                    let diaryFolders = try FileManager.default.contentsOfDirectory(
                        at: baseFolder,
                        includingPropertiesForKeys: nil,
                        options: .skipsHiddenFiles
                    )
                    
                    for diaryFolder in diaryFolders {
                        let diaryID = diaryFolder.lastPathComponent
                        let imageFiles = try FileManager.default.contentsOfDirectory(
                            at: diaryFolder,
                            includingPropertiesForKeys: nil,
                            options: .skipsHiddenFiles
                        )
                        
                        if let firstFile = imageFiles.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }).first,
                           let image = UIImage(contentsOfFile: firstFile.path(percentEncoded: true)) {
                            results.append((image, diaryID))
                        } else{
                            // 이미지가 없을 때 nil 저장
                            results.append((nil, diaryID))
                        }
                    }
                    
                    LogManager.print(.success, "총 \(results.count)개의 대표 이미지 로드 완료")
                    continuation.resume(returning: results)
                } catch {
                    LogManager.print(.error, "대표 이미지 로드 실패 \(error.localizedDescription)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    
    // MARK: ✅ Update - 감정일기 수정
    func updateDiary(_ model: EmotionDiaryModel) {
        let request: NSFetchRequest<EmotionDiaryEntity> = EmotionDiaryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", model.id.uuidString)
        
        guard let diary = try? context.fetch(request).first else {
            LogManager.print(.warning, "수정할 일기 찾을 수 없음: \(model.id)")
            return
        }
        
        diary.emotion = model.emotion
        diary.content = model.content
        diary.createdAt = model.createdAt
        
        // 이미지 저장 관리
        DiaryImageFileManager.shared.deleteDiaryFolder(for: model.id.uuidString)
        diary.images = nil
        
        if let newImages = model.images {
            for (index, image) in newImages.enumerated() {
                if let path = DiaryImageFileManager.shared.saveImage(image, diaryID: model.id.uuidString, index: index) {
                    let imageEntity = DiaryImageEntity(context: context)
                    imageEntity.id = UUID().uuidString
                    imageEntity.imagePath = path
                    imageEntity.diary = diary
                    diary.addToImages(imageEntity)
                }
            }
        }
        saveContext()
    }
    
    
    // MARK: ✅ Delete - 감정일기 삭제
    func deleteDiary(by id: String) {
        let request: NSFetchRequest<EmotionDiaryEntity> = EmotionDiaryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            if let entity = try context.fetch(request).first {
                // 이미지 폴더 삭제
                if let diaryID = entity.id {
                    DiaryImageFileManager.shared.deleteDiaryFolder(for: diaryID)
                }
                
                // Core Data 삭제
                context.delete(entity)
                saveContext()
                LogManager.print(.success, "감정일기 삭제 완료 [\(id)]")
            }
        } catch {
            LogManager.print(.error, "삭제 실패: \(error.localizedDescription)")
        }
    }
    
}


// MARK: Additional Fetch Functions
extension DiaryCoreDataManager {
    
    
    // MARK: ✅ Private Helper
    private func makeBaseFetchRequest() -> NSFetchRequest<EmotionDiaryEntity> {
        let request: NSFetchRequest<EmotionDiaryEntity> = EmotionDiaryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }
        
    private func performFetch(_ request: NSFetchRequest<EmotionDiaryEntity>) -> [EmotionDiaryModel] {
        do {
            let entities = try context.fetch(request)
            let models = entities.compactMap { $0.toModel() }
            LogManager.print(.success, "총 \(models.count)개의 감정일기 로드 완료")
            return models
        } catch {
            LogManager.print(.error, "감정일기 불러오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    
    // MARK: ✅ 특정 감정 검색
    func fetchDiaries(by emotion: String) -> [EmotionDiaryModel] {
        let request = makeBaseFetchRequest()
        request.predicate = NSPredicate(format: "emotion == %@", emotion)
        return performFetch(request)
    }
    
    
    // MARK: ✅ 키워드 검색 (내용 + 감정)
    func searchDiaries(by keyword: String) -> [EmotionDiaryModel] {
        let request = makeBaseFetchRequest()
        let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", keyword)
        let emotionPredicate = NSPredicate(format: "emotion CONTAINS[c] %@", keyword)
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [contentPredicate, emotionPredicate])
        return performFetch(request)
    }
    
    
    // MARK: ✅ 최신 일기 1개 가져오기
    func fetchLatestDiary() -> EmotionDiaryModel? {
        let request = makeBaseFetchRequest()
        request.fetchLimit = 1
        
        do {
            guard let entity = try context.fetch(request).first else {
                LogManager.print(.warning, "최근 감정일기를 찾을 수 없습니다.")
                return nil
            }
            LogManager.print(.success, "최근 감정일기 불러오기완료")
            return entity.toModel()
        } catch {
            LogManager.print(.error, "최근 ㄱ감정일기 불러오기 실패: \(error.localizedDescription)")
            return nil
        }
        
    }
    
}


/* 리팩토리 전 메서드
// MARK: - Additional Fetch Functions
extension DiaryCoreDataManager {
    
    
    // MARK: ✅ 특정 감정 검색
    func fetchDiaries(by emotion: String) -> [EmotionDiaryModel] {
        let request: NSFetchRequest<EmotionDiaryEntity> = EmotionDiaryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "emotion == %@", emotion)
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let entities = try context.fetch(request)
            let models = entities.compactMap { $0.toModel() }
            LogManager.print(.success, "총 \(models.count)개의 감정일기 로드 완료")
            return models
        } catch {
            LogManager.print(.error, "감정일기 불러오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    
    // MARK: ✅ 키워드 검색 (내용 기반)
    func searchDiaries(by keyword: String) -> [EmotionDiaryModel] {
        let request: NSFetchRequest<EmotionDiaryEntity> = EmotionDiaryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "content CONTAINS[c] %@", keyword)
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let entities = try context.fetch(request)
            let models = entities.compactMap { $0.toModel() }
            LogManager.print(.success, "총 \(models.count)개의 감정일기 로드 완료")
            return models
        } catch {
            LogManager.print(.error, "감정일기 검색 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    
    // MARK: ✅ 최근 일기 1개 가져오기
    func fetchLatestDiary() -> EmotionDiaryModel? {
        let request: NSFetchRequest<EmotionDiaryEntity> = EmotionDiaryEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let entities = try context.fetch(request)
            let models = entities.compactMap { $0.toModel() }
            let lastestDiary = models.first
            LogManager.print(.success, "최근 감정읽기 불러오기 완료")
            return lastestDiary
        } catch {
            LogManager.print(.error, "최근 감정일기 불러옥기 실패: \(error.localizedDescription)")
            return nil
        }
    }
}
*/
