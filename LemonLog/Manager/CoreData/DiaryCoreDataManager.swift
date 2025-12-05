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
    @discardableResult
    func saveContext() -> Bool {
        guard context.hasChanges else {
            LogManager.print(.warning, "저장할 변경사항이 없습니다.")
            return false
        }
        
        do {
            try context.save()
            LogManager.print(.success, "Core Data 저장 성공")
            return true
        } catch {
            LogManager.print(.error, "Core Data 저장 실패: \(error.localizedDescription)")
            return false
        }
    }
    
}

// MARK: ✅ Extension (encode & decode 메서드)
extension DiaryCoreDataManager {
    
    // EmotionSelection → JSON String 변환
    private func encodeEmotionSelection(_ emotion: EmotionSelection) -> String {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(emotion),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
    
    // ContentSections → JSON String 변환
    private func encodeContent(_ content: ContentSections) -> String {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(content),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
    
    // String -> EmotionSelection 변환
    private func decodeEmotionSelection(_ jsonString: String) -> EmotionSelection? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(EmotionSelection.self, from: data)
    }

    // String -> ContentSections 변환
    private func decodeContent(_ jsonString: String) -> ContentSections? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ContentSections.self, from: data)
    }

}


// MARK: - CRUD for EmotionDiaryEntity
extension DiaryCoreDataManager {
    
    
    // MARK: ✅ Create - 감정일기 저장
    @discardableResult
    func saveDiary(_ model: EmotionDiaryModel) -> Bool {
        let diary = EmotionDiaryEntity(context: context)
        diary.id = model.id.uuidString
        diary.emotion = encodeEmotionSelection(model.emotion)
        diary.content = encodeContent(model.content)
        diary.createdAt = model.createdAt
        
        // 이미지 저장
        if let images = model.images {
            for (index, image) in images.enumerated() {
                if let path = DiaryImageFileManager.shared.saveImage(
                    image,
                    diaryID: model.id.uuidString,
                    index: index
                ) {
                    let imageEntity = DiaryImageEntity(context: context)
                    imageEntity.id = UUID().uuidString
                    imageEntity.imagePath = path
                    imageEntity.diary = diary
                    diary.addToImages(imageEntity)
                } else {
                    LogManager.print(.warning, "이미지 저장 실패 (index \(index)")
                }
            }
        }
        
        // 저장 시도 (성공 / 실패 결과 반영)
        let success = saveContext()
        if success {
            LogManager.print(.success, "감정일기 저장 성공 (\(model.id))")
        } else {
            LogManager.print(.error, "감정일기 저장 실패 (\(model.id)")
        }
        return success
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
            context.perform { // Core Data 전용 안전 스레드
                let result = self.fetchDiaries(mode: mode)
                continuation.resume(returning: result)
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
    @discardableResult
    func updateDiary(_ model: EmotionDiaryModel) -> Bool {
        let request: NSFetchRequest<EmotionDiaryEntity> = EmotionDiaryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", model.id.uuidString)
        
        guard let diary = try? context.fetch(request).first else {
            LogManager.print(.warning, "수정할 일기 찾을 수 없음: \(model.id)")
            return false
        }
        
        diary.emotion = encodeEmotionSelection(model.emotion)
        diary.content = encodeContent(model.content)
        diary.createdAt = model.createdAt
        
        // 이미지 저장 관리
        DiaryImageFileManager.shared.deleteDiaryFolder(for: model.id.uuidString)
        diary.images = nil
        
        if let newImages = model.images {
            for (index, image) in newImages.enumerated() {
                if let path = DiaryImageFileManager.shared.saveImage(
                    image,
                    diaryID: model.id.uuidString,
                    index: index
                ) {
                    let imageEntity = DiaryImageEntity(context: context)
                    imageEntity.id = UUID().uuidString
                    imageEntity.imagePath = path
                    imageEntity.diary = diary
                    diary.addToImages(imageEntity)
                } else {
                    LogManager.print(.warning, "이미지 저장 실패 (index \(index))")
                }
            }
        }
        
        // 저장 시도 (성공 / 실패 결과 반영)
        let success = saveContext()
        if success {
            LogManager.print(.success, "감정일기 수정 성공 (\(model.id))")
        } else {
            LogManager.print(.error, "감정일기 수정 실패 (\(model.id))")
        }
        return success
    }
    
    
    // MARK: ✅ Delete - 감정일기 삭제
    @discardableResult
    func deleteDiary(by id: String) -> Bool {
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
                
                let success = saveContext()
                if success {
                    LogManager.print(.success, "감정읽기 삭제 완료 [\(id)]")
                } else {
                    LogManager.print(.error, "감정일기 삭제 실패 [\(id)] - Core Data 저장 실패")
                }
                return success
                
            } else {
                LogManager.print(.warning, "삭제할 일기를 찾을 수 없음 [\(id)]")
                return false
            }
        } catch {
            LogManager.print(.error, "삭제 중 오류 발생: \(error.localizedDescription)")
            return false 
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
    
    
    // MARK: ✅ 요일 별 감정 데이터 가져오기 (요일 - 감정)
    func fetchWeeklySummary(for date: Date = Date()) -> [Weekday: [EmotionCategory]] {
        let calendar = Calendar.current

        // 주간 범위 계산
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [:] }
        let startOfWeek = weekInterval.start
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        // 1) 엔티티 fetch
        let request = makeBaseFetchRequest()
        request.predicate = NSPredicate(
            format: "createdAt >= %@ AND createdAt <= %@",
            startOfWeek as NSDate, endOfWeek as NSDate
        )

        let entities = performFetch(request)

        // 2) 엔티티 → 모델 변환
        //let diaries: [EmotionDiaryModel] = entities.compactMap { $0.toModel() }

        // 3) 요일별 감정 그룹화
        var summary: [Weekday: [EmotionCategory]] = [:]

        for diary in entities {

            let weekdayIndex = calendar.component(.weekday, from: diary.createdAt)

            let weekday: Weekday
            switch weekdayIndex {
            case 1: weekday = .sun
            case 2: weekday = .mon
            case 3: weekday = .tue
            case 4: weekday = .wed
            case 5: weekday = .thu
            case 6: weekday = .fri
            case 7: weekday = .sat
            default: continue
            }

            summary[weekday, default: []].append(diary.emotion.category)
        }

        return summary
    }

}


// MARK: - extension (주간 감정 요약에 쓰일 Weekday)
extension DiaryCoreDataManager {
    enum Weekday: String, CaseIterable {
        case sun, mon, tue, wed, thu, fri, sat
    }
}


extension DiaryCoreDataManager.Weekday {
    init?(weekdayIndex: Int) {
        switch weekdayIndex {
        case 1: self = .sun
        case 2: self = .mon
        case 3: self = .tue
        case 4: self = .wed
        case 5: self = .thu
        case 6: self = .fri
        case 7: self = .sat
        default: return nil
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
