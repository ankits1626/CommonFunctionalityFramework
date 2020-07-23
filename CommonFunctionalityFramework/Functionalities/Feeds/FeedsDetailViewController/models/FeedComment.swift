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

struct FeedComment : RawObjectProtocol,Likeable {
    func getLikeToggleUrl(_ baseUrl: String) -> URL {
        return URL(string: baseUrl + "feeds/api/comments/\(getComentId())/like/")!
    }
    
    
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
        managedPost.isLikedByMe = isLiked
        managedPost.commentId = getComentId()
        managedPost.numberOfLikes = numberOfLikes
        return managedPost
    }
    
    init(managedObject : NSManagedObject) {
        self.rawFeedComment = (managedObject as! ManagedPostComment).commentRawDictionary as! [String : Any]
        self.isLiked = (managedObject as! ManagedPostComment).isLikedByMe
        numberOfLikes = (managedObject as! ManagedPostComment).numberOfLikes
    }
    
    private let rawFeedComment : [String : Any]
    private var isLiked : Bool
    private var numberOfLikes : Int64
    
    init(input : [String : Any]) {
        self.rawFeedComment = input
        self.isLiked = rawFeedComment["has_liked"] as? Bool ?? false
        numberOfLikes = rawFeedComment["liked_count"] as? Int64 ?? 0
    }
    
    func getCommentDate() -> String {
        if let rawDate = rawFeedComment["created_on"] as? String{
            return CommonFrameworkDateUtility.getDisplayableDate(input: rawDate, dateFormat: "yyyy-MM-dd HH:mm:ss") ?? ""
        }
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
    
    func isLikedByMe() -> Bool {
        return isLiked
    }
    
    func likeCount() -> Int64 {
        return numberOfLikes
    }
    
    func presentableLikeCount() -> String {
        if numberOfLikes == 1{
            return "1 Like"
        }else{
            return "\(numberOfLikes) Likes"
        }
        
    }
}
