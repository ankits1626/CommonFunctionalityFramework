//
//  FeedComment.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation
import CoreData

struct CommentUser : FeedBaseUser{
    var rawUserDictionary: [String : Any]
    
    init(_ rawCommentUser : [String : Any]) {
        self.rawUserDictionary = rawCommentUser
    }
    
}

struct FeedComment : RawObjectProtocol {
    
    @discardableResult func getManagedObject() -> NSManagedObject{
        let managedPost : ManagedPostComment!
        let fetchRequest : NSFetchRequest<ManagedPostComment> = ManagedPostComment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "commentId = %d && commentId != -1", self.getComentId())
        
        let fetchedFeeds = CFFCoreDataManager.sharedInstance.manager.fetchManagedObject(
            type: ManagedPostComment.self,
            fetchRequest: fetchRequest,
            context: CFFCoreDataManager.sharedInstance.manager.privateQueueContext
        )
        if let firstFetchedManagedFeed = fetchedFeeds.fetchedObjects?.first{
            managedPost = firstFetchedManagedFeed
        }else{
            managedPost = CFFCoreDataManager.sharedInstance.manager.insertManagedObject(type: ManagedPostComment.self)
            managedPost.createdTimeStamp = NSDate()
        }
        managedPost.commentRawDictionary = rawFeedComment as NSDictionary
        managedPost.commentId = getComentId()
        return managedPost
    }
    
    init(managedObject : NSManagedObject) {
        self.rawFeedComment = (managedObject as! ManagedPostComment).commentRawDictionary as! [String : Any]
    }
    
    private let rawFeedComment : [String : Any]
    init(input : [String : Any]) {
        self.rawFeedComment = input
    }
    
    func getCommentDate() -> String {
        return rawFeedComment["created_on"] as? String ?? ""
    }
    
    func getCommentText() -> String? {
        return rawFeedComment["content"] as? String
    }
    
    func getCommentUser() -> CommentUser {
        return CommentUser(rawFeedComment["commented_by_user_info"] as? [String : Any] ?? [String : Any]())
    }
    
    func getComentId() -> Int64 {
        return rawFeedComment["id"] as? Int64 ?? -1
    }
}
