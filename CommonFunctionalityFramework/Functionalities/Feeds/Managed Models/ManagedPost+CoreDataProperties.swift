//
//  ManagedPost+CoreDataProperties.swift
//  
//
//  Created by Rewardz on 20/04/20.
//
//

import Foundation
import CoreData


extension ManagedPost {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedPost> {
        return NSFetchRequest<ManagedPost>(entityName: "ManagedPost")
    }

    @NSManaged public var postId: Int64
    @NSManaged public var postRawDictionary: NSObject?
    @NSManaged public var comments: NSSet?
    @NSManaged public var createdTimeStamp: NSDate
    @NSManaged public var isLikedByMe: Bool
    @NSManaged public var numberOfLikes: Int64
    @NSManaged public var numberOfComments: Int64
    @NSManaged public var pollUpdatedTrigger: NSDate
    @NSManaged public var isPriority: Bool
    @NSManaged public var isAdmin: Bool
    @NSManaged public var messageType: Int64
}

// MARK: Generated accessors for comments
extension ManagedPost {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: ManagedPostComment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: ManagedPostComment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
