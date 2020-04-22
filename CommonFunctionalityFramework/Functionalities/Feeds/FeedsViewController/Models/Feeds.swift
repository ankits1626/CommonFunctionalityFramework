//
//  Feeds.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation
import CoreData

protocol FeedBaseUser{
    var rawUserDictionary : [String : Any] {get}
    func getAuthorName() -> String
    func getAuthorDepartmentName() -> String
    func getAuthorProfileImageUrl() -> String?
}

extension FeedBaseUser{
    
    func getAuthorDepartmentName() -> String {
        if let departments = rawUserDictionary["departments"] as? [[String : String]]{
            var departmentValues = [String]()
            departments.forEach { (aDictionary) in
                if let unwrappedDepartment = aDictionary["name"]{
                    departmentValues.append(unwrappedDepartment)
                }
            }
            return departmentValues.joined(separator: ", ")
        }else{
            return ""
        }
    }
    
    func getAuthorName() -> String {
        return getFullName()
    }
    
    private func getFullName() -> String{
        var name = ""
        name.append(getFirstName())
        if name.isEmpty{
            name.append(getLastName())
        }else{
            name.append(" \(getLastName())")
        }
        return name
    }
    
    private func getFirstName() -> String {
        return rawUserDictionary["first_name"] as? String ?? ""
    }
    
    private func getLastName() -> String {
        return rawUserDictionary["last_name"] as? String ?? ""
    }
    
    func getAuthorProfileImageUrl() -> String? {
        return rawUserDictionary["profile_img"] as? String
    }
}


struct FeedAuthor : FeedBaseUser {
    internal let rawUserDictionary : [String : Any]
    init(rawAuthorDictionary : [String : Any]) {
        self.rawUserDictionary = rawAuthorDictionary
    }
}

struct Poll {
    private let rawPoll : [String : Any]
    init(rawPoll : [String : Any]) {
        self.rawPoll = rawPoll
    }
}

public struct RawFeed : FeedsItemProtocol, RawObjectProtocol {
    func getLikeToggleUrl() -> URL {
        return URL(string: "https://demo.flabulessdev.com/feeds/api/posts/\(feedIdentifier)/appreciate/")!
    }
    private let rawFeedDictionary : [String : Any]
    private var numberOfLikes: Int64
    private var isLikedByMe : Bool
    init(input : [String : Any]){
        self.rawFeedDictionary = input
        isLikedByMe = rawFeedDictionary["has_appreciated"] as? Bool ?? false
        numberOfLikes = rawFeedDictionary["appreciation_count"] as? Int64 ?? 0
    }
    
    init(managedObject : NSManagedObject){
        self.rawFeedDictionary = (managedObject as! ManagedPost).postRawDictionary as! [String : Any]
        self.isLikedByMe = (managedObject as! ManagedPost).isLikedByMe
        self.numberOfLikes = (managedObject as! ManagedPost).numberOfLikes
    }
    
    @discardableResult func getManagedObject() -> NSManagedObject{
        let managedPost : ManagedPost!
        let fetchRequest : NSFetchRequest<ManagedPost> = ManagedPost.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "postId = %d && postId != -1", self.feedIdentifier)
        
        let fetchedFeeds = CFFCoreDataManager.sharedInstance.manager.fetchManagedObject(
            type: ManagedPost.self,
            fetchRequest: fetchRequest,
            context: CFFCoreDataManager.sharedInstance.manager.privateQueueContext
        )
        if let firstFetchedManagedFeed = fetchedFeeds.fetchedObjects?.first{
            managedPost = firstFetchedManagedFeed
        }else{
            managedPost = CFFCoreDataManager.sharedInstance.manager.insertManagedObject(type: ManagedPost.self)
            managedPost.createdTimeStamp = Date()
        }
        managedPost.postRawDictionary = rawFeedDictionary as NSDictionary
        managedPost.postId = feedIdentifier
        managedPost.isLikedByMe = isLikedByMe
        managedPost.numberOfLikes = numberOfLikes
        return managedPost
    }
    
    
    func getEditablePost() -> EditablePostProtocol {
        return EditablePost(
            postType: getFeedType(),
            pollOptions: nil,
            title: getFeedTitle(),
            postDesciption: getFeedDescription(),
            attachedMedia: nil,
            selectedMediaItems: nil)
    }
    
    func getPollOptions() -> [PollOption]? {
        var options = [PollOption]()
        
        if
            let rawPollInfo = rawFeedDictionary["poll_info"] as? [String : Any],
            let rawOptions = rawPollInfo["answers"] as? [[String : Any]]{
            rawOptions.forEach { (aRwaOption) in
                options.append(PollOption(aRwaOption))
            }
        }
        return options.isEmpty ? nil : options
    }
    
    var feedIdentifier: Int64{
        return rawFeedDictionary["id"] as? Int64 ?? -1
    }
    
    static var EMPTY_FEED : FeedsItemProtocol {
        return RawFeed(input: [String : Any]())
    }
    func getPollState() -> PollState {
        return .NotAvailable
    }
    
    func getMediaCountState() -> MediaCountState {
        if let mediaElements = getMediaList(){
            if mediaElements.count == 1{
                return .OneMediaItemPresent(mediaType: mediaElements.first!.getMediaType())
            }else if mediaElements.count == 2{
                return .TwoMediaItemPresent
            }else{
                return .MoreThanTwoMediItemPresent
            }
        }else{
            return .None
        }
    }
    
    func getFeedType() -> FeedType {
        if let type = rawFeedDictionary["post_type"] as? Int,
            let pollType = FeedType(rawValue: type){
            return pollType
        }else{
            return .Post
        }
    }
    
    private func getFeedAuthor() -> FeedAuthor?{
        if let rawAuthor = rawFeedDictionary["created_by_user_info"] as? [String:Any]{
            return FeedAuthor(rawAuthorDictionary: rawAuthor)
        }else{
            return nil
        }
    }
    
    func getUserImageUrl() -> String? {
        return getFeedAuthor()?.getAuthorProfileImageUrl()
    }
    
    func getUserName() -> String? {
        return getFeedAuthor()?.getAuthorName()
    }
    
    func getDepartmentName() -> String? {
        return getFeedAuthor()?.getAuthorDepartmentName()
    }
    
    func getfeedCreationDate() -> String? {
        return rawFeedDictionary["created_on"] as? String
    }
    
    func getIsEditActionAllowedOnFeedItem() -> Bool {
        return rawFeedDictionary["is_owner"] as? Bool ?? false
    }
    
    func getFeedTitle() -> String? {
        if let unwrappedTitle  = rawFeedDictionary["title"] as? String,
            !unwrappedTitle.isEmpty{
            return unwrappedTitle
        }else{
            return nil
        }
    }
    
    func getFeedDescription() -> String? {
        if let unwrappedDescription  = rawFeedDictionary["description"] as? String,
            !unwrappedDescription.isEmpty{
            return unwrappedDescription
        }else{
            return nil
        }
    }
    
    func getMediaList() -> [MediaItemProtocol]? {
        var mediaElements = [MediaItemProtocol]()
        if let videos = rawFeedDictionary["videos"] as? [[String : Any]]{
            for aVideo in videos {
                mediaElements.append(FeedVideoItem(aVideo))
            }
        }
        
        if let images = rawFeedDictionary["images"] as? [[String : Any]]{
            for anImage in images {
                mediaElements.append(FeedImageItem(anImage))
            }
        }
        return mediaElements.isEmpty ? nil : mediaElements
    }
    
    func isClappedByMe() -> Bool {
        return isLikedByMe
    }
    
    func getNumberOfClaps() -> String {
        let claps = numberOfLikes
        return "\(claps) Clap".appending(claps == 1 ? "" : "s")
    }
    
    func getNumberOfComments() -> String {
        let comments = rawFeedDictionary["comments_count"] as? Int ?? 0
        return "\(comments) Comment".appending(comments == 1 ? "" : "s")
    }
    
}
