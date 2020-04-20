//
//  ManagedPostComment+CoreDataProperties.swift
//  
//
//  Created by Rewardz on 20/04/20.
//
//

import Foundation
import CoreData


extension ManagedPostComment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedPostComment> {
        return NSFetchRequest<ManagedPostComment>(entityName: "ManagedPostComment")
    }

    @NSManaged public var commentId: Int64
    @NSManaged public var commentRawDictionary: NSObject?
    @NSManaged public var post: ManagedPost?
    @NSManaged public var createdTimeStamp: NSDate

}
