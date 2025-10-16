//
//  EmotionDiaryEntity+CoreDataProperties.swift
//  LemonLog
//
//  Created by 권정근 on 10/16/25.
//
//

import Foundation
import CoreData


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
    
    
    func toModel() -> EmotionDiaryModel? {
        guard
            let idString = id,
            let uuid = UUID(uuidString: idString),
            let emotion = self.emotion,
            let content = self.content,
            let createdAt = self.createdAt
        else {
#if DEBUG
            print("❌ toModel 변환 실패: 필수 값 누락")
#endif
            return nil
        }
        
        return EmotionDiaryModel(
            id: uuid,
            emotion: emotion,
            content: content,
            createdAt: createdAt,
            images: <#T##[UIImage]?#>
        )
    }
}
