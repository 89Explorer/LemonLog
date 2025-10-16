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
    @NSManaged public var context: String?
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
