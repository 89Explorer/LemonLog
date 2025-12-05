//
//  EmotionDiaryEntity+CoreDataProperties.swift
//  LemonLog
//
//  Created by 권정근 on 10/16/25.
//
//

import Foundation
import CoreData
import UIKit


extension EmotionDiaryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmotionDiaryEntity> {
        return NSFetchRequest<EmotionDiaryEntity>(entityName: "EmotionDiaryEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var emotion: String?
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for images
extension EmotionDiaryEntity {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: DiaryImageEntity)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: DiaryImageEntity)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

extension EmotionDiaryEntity : Identifiable {

}

extension EmotionDiaryEntity {
    
    // MARK: ✅ Method (EmotionDiaryEntity → EmotionDiaryModel 로 변환)
    func toModel() -> EmotionDiaryModel? {
        guard
            let idString = id,
            let uuid = UUID(uuidString: idString),
            let emotionString = self.emotion,
            let contentString = self.content,
            let createdAt = self.createdAt
        else {
            LogManager.print(.error, "toModel 변환 실패: 필수 값 누락")
            return nil
        }
        
        // EmotionSelectiong 디코딩
        let emotion: EmotionSelection
        if let data = emotionString.data(using: .utf8),
           let decodedEmotion = try? JSONDecoder().decode(EmotionSelection.self, from: data) {
            emotion = decodedEmotion
        } else {
            LogManager.print(.error, "EmotionSelection JSON 디코딩 실패")
            return nil
        }
        
        // ContentSections 디코딩
        let content: ContentSections
        if let data = contentString.data(using: .utf8),
           let decodedContent = try? JSONDecoder().decode(ContentSections.self, from: data) {
            content = decodedContent
        } else {
            LogManager.print(.error, "ContentSections JSON 디코딩 실패")
            return nil
        }
        
        // 이미지 디코딩
        var loadedImages: [UIImage] = []
        
        if let imageEntities = images as? Set<DiaryImageEntity> {
            for entity in imageEntities {
                if let path = entity.imagePath,
                   let image = DiaryImageFileManager.shared.loadImage(from: path) {
                    loadedImages.append(image)
                } else {
                    LogManager.print(.warning, "이미지 로드 실패 또는 경로 없음")
                }
            }
        } else {
            LogManager.print(.warning, "images NSSet 변환 실패 ")
        }
        
        return EmotionDiaryModel(
            id: uuid,
            emotion: emotion,      // 구조체로 전달
            content: content,      // 구조체로 전달
            createdAt: createdAt,
            images: loadedImages.isEmpty ? nil : loadedImages
        )
    }
}
