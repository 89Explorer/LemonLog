//
//  DiaryImageEntity+CoreDataProperties.swift
//  LemonLog
//
//  Created by 권정근 on 10/16/25.
//
//

import Foundation
import CoreData


extension DiaryImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiaryImageEntity> {
        return NSFetchRequest<DiaryImageEntity>(entityName: "DiaryImageEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var imagePath: String?
    @NSManaged public var diary: EmotionDiaryEntity?

}

extension DiaryImageEntity : Identifiable {

}
