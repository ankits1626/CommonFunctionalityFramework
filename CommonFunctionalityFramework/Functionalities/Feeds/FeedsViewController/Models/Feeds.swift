//
//  Feeds.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import CoreData

protocol FeedsItemProtocol : Likeable {

    var feedIdentifier : Int64{get}
    func getUserImageUrl() -> String?
    func getUserName() -> String?
    func getDepartmentName() -> String?
    func getfeedCreationDate() -> String?
    func getIsEditActionAllowedOnFeedItem() -> Bool
    func getFeedTitle() -> String?
    func getFeedDescription() -> String?
    func getMediaList() -> [MediaItemProtocol]?
    func isClappedByMe() -> Bool
    func getNumberOfClaps() -> String
    func getNumberOfComments() -> String
    func getPollState() -> PollState
    func getMediaCountState() -> MediaCountState
    func getFeedType() -> FeedType
    //func getPollOptions() -> [PollOption]?
    func getEditablePost() -> EditablePostProtocol
    func hasOnlyMedia() -> Bool
    func getPoll() -> Poll?
    func shouldShowDetail() -> Bool
    func isFeedEditAllowed() -> Bool
    func isFeedDeleteAllowed() -> Bool
    func isFeedReportAbuseAllowed() -> Bool
    func isActionsAllowed() -> Bool
    func isPinToPost() -> Bool
    func isLoggedUserAdmin() -> Bool
}

public struct RawFeed : FeedsItemProtocol, RawObjectProtocol {
    
    func isPinToPost() -> Bool {
        return isPriority
    }
    
    func isLoggedUserAdmin() -> Bool {
        return isAdminUser
    }
    
    func shouldShowDetail() -> Bool {
        return true
//        if let unwrappedPoll = getPoll(){
//            return !unwrappedPoll.isPollActive()
//        }else{
//            return true
//        }
    }
    
    func getPoll() -> Poll? {
        if let unwrappedRawPoll = rawFeedDictionary["poll_info"] as? [String : Any]{
            return Poll(rawPoll: unwrappedRawPoll)
        }else{
            return nil
        }
    }
    
    func getLikeToggleUrl(_ baseUrl : String) -> URL {
        return URL(string: baseUrl + "feeds/api/posts/\(feedIdentifier)/appreciate/")!
    }
    private let rawFeedDictionary : [String : Any]
    private var numberOfLikes: Int64
    private var isLikedByMe : Bool
    private var numberOfComments : Int64
    private let isPriority : Bool
    private let isAdminUser : Bool
    
    public init(input : [String : Any]){
        self.rawFeedDictionary = input
        isLikedByMe = rawFeedDictionary["has_appreciated"] as? Bool ?? false
        numberOfLikes = rawFeedDictionary["appreciation_count"] as? Int64 ?? 0
        numberOfComments = rawFeedDictionary["comments_count"] as? Int64 ?? 0
        isPriority = rawFeedDictionary["priority"] as? Bool ?? false
        isAdminUser = rawFeedDictionary["is_admin"] as? Bool ?? false
    }
    
    public init(managedObject : NSManagedObject){
        self.rawFeedDictionary = (managedObject as! ManagedPost).postRawDictionary as! [String : Any]
        self.isLikedByMe = (managedObject as! ManagedPost).isLikedByMe
        self.numberOfLikes = (managedObject as! ManagedPost).numberOfLikes
        numberOfComments = (managedObject as! ManagedPost).numberOfComments
        isPriority = (managedObject as! ManagedPost).isPriority
        isAdminUser = (managedObject as! ManagedPost).isAdmin
    }
    
    @discardableResult public func getManagedObject() -> NSManagedObject{
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
            managedPost.createdTimeStamp = NSDate()
        }
        managedPost.postRawDictionary = rawFeedDictionary as NSDictionary
        managedPost.postId = feedIdentifier
        managedPost.isLikedByMe = isLikedByMe
        managedPost.numberOfLikes = numberOfLikes
        managedPost.numberOfComments = numberOfComments
        managedPost.isPriority = isPriority
        managedPost.isAdmin = isAdminUser
        return managedPost
    }
    
    
    func getEditablePost() -> EditablePostProtocol {
        if let unrappedDescription = getFeedDescription(){
            let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(
                feedId: feedIdentifier,
                description: unrappedDescription
            )
            
            var post =  EditablePost(
                isShareWithSameDepartmentOnly: isSharedWithDepartment(),
                postType: getFeedType(),
                pollOptions: nil,
                title: getFeedTitle(),
                postDesciption:  model?.displayableDescription.string,
                remoteAttachedMedia: getMediaList(),
                selectedMediaItems: nil,
                remotePostId: feedIdentifier != -1 ? "\(feedIdentifier)" : nil
            )
            if let unwrappedGifSource = model?.attachedGif{
               post.attachedGif = RawGif(sourceUrl: unwrappedGifSource)
            }
            
            return post
            
        }else{
            return EditablePost(
                isShareWithSameDepartmentOnly: isSharedWithDepartment(),
                postType: getFeedType(),
                pollOptions: nil,
                title: getFeedTitle(),
                postDesciption:  getFeedDescription(),
                remoteAttachedMedia: getMediaList(),
                selectedMediaItems: nil,
                remotePostId: feedIdentifier != -1 ? "\(feedIdentifier)" : nil
            )
        }
        
    }
    
    private func isSharedWithDepartment() -> Bool{
        if let rawSharedWithValue = rawFeedDictionary["shared_with"] as? Int,
            let departmentSharedChoice = DepartmentSharedChoice(rawValue: rawSharedWithValue) {
            return departmentSharedChoice == .SelfDepartment
        }else{
            return false
        }
    }
    
    var feedIdentifier: Int64{
        return rawFeedDictionary["id"] as? Int64 ?? -1
    }
    
    static var EMPTY_FEED : FeedsItemProtocol {
        return RawFeed(input: [String : Any]())
    }
    func getPollState() -> PollState {
        return .NotActive
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
    
    func isFeedEditAllowed() -> Bool {
        return rawFeedDictionary["can_edit"] as? Bool ?? false
    }
    
    func isFeedDeleteAllowed() -> Bool {
        return rawFeedDictionary["can_delete"] as? Bool ?? false
    }
    
    func isFeedReportAbuseAllowed() -> Bool {
        return !getIsEditActionAllowedOnFeedItem()
    }
    
    func isActionsAllowed() -> Bool {
        return isFeedEditAllowed() || isFeedDeleteAllowed() || isFeedReportAbuseAllowed()
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
        //hello
        if let rawDate = rawFeedDictionary["created_on"] as? String{
            return CommonFrameworkDateUtility.getDisplayedDateInFormatDMMMYYYY(input: rawDate, dateFormat: "yyyy-MM-dd") ?? ""
        }
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
        return "\(claps) \("Clap".localized)".appending(claps == 1 ? "" : "s".localized)
    }
    
    func getNumberOfComments() -> String {
        return "\(numberOfComments) \("Comment".localized)".appending(numberOfComments == 1 ? "" : "s".localized)
    }
    
    func hasOnlyMedia() -> Bool {
        return getFeedTitle() == nil && getFeedDescription() == nil
    }
}
