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
    func getHomeUserCreatedName() -> String?
    func getHomeUserReceivedName() -> String?
    func getGivenTabUserImg() -> String?
    func getHomeUserReceivedImg() -> String?
    func toUserName() -> String?
    func getNominatedByUserName() -> String?
    func getDepartmentName() -> String?
    func getfeedCreationDate() -> String?
    func getfeedCreationMonthYear() -> String?
    func getAppreciationCreationMonthDate() -> String?
    func getIsEditActionAllowedOnFeedItem() -> Bool
    func getFeedTitle() -> String?
    func getFeedDescription() -> String?
    func getMediaList() -> [MediaItemProtocol]?
    func isClappedByMe() -> Bool
    func getNumberOfClaps() -> String
    func getNumberOfComments() -> String
    func updateNumberOfComments() -> String
    func getPollState() -> PollState
    func getMediaCountState() -> MediaCountState
    func getGiphy() -> String?
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
    func getStrengthData() -> NSDictionary
    func getPostType() -> FeedPostType
    func getBadgesData() -> NSDictionary
    func getUserReactionType() -> Int
    func getReactionsData() -> NSArray?
    func getReactionCount() -> Int64
}

public struct RawFeed : FeedsItemProtocol, RawObjectProtocol {
    
    func isPinToPost() -> Bool {
        return isPriority
    }
    
    func isLoggedUserAdmin() -> Bool {
        return isAdminUser
    }
    
    func getStrengthData() -> NSDictionary {
        var dataDic = NSDictionary()

        var strengthName = ""
        var strengthIcon = ""
        var strengthMessage = ""
        var badgeBackgroundColor = ""
        var illustration = ""
        var points = "0"
        if let userStrength = rawFeedDictionary["nomination"] as? [String : Any]{
            if let userStengthDic = userStrength["user_strength"] as? NSDictionary {
                if let userName = userStengthDic["name"] as? String, !userName.isEmpty {
                    strengthMessage = rawFeedDictionary["description"] as! String
                   // strengthIcon = userStengthDic["icon"] as! String
                    badgeBackgroundColor = userStengthDic["background_color"] as! String
                    
                    if let pts = rawFeedDictionary["points"] as? String {
                        points = pts
                    }
                    
                    
                    dataDic = ["strengthName" : userName, "strengthMessage" : strengthMessage, "strengthIcon" : strengthIcon, "badgeBackgroundColor" : badgeBackgroundColor, "points" : points, "illustration" : ""]
                }else {
                    if let userStengthDic = rawFeedDictionary["user_strength"] as? NSDictionary {
                        if let pts = rawFeedDictionary["points"] as? String {
                            points = pts
                        }
                        
                        strengthName = userStengthDic["name"] as! String
                        strengthMessage = rawFeedDictionary["description"] as! String
                        strengthIcon = userStengthDic["icon"] as! String
                        badgeBackgroundColor = userStengthDic["background_color"] as! String
                        illustration = userStengthDic["illustration"] as! String
                        dataDic = ["strengthName" : strengthName, "strengthMessage" : strengthMessage, "strengthIcon" : strengthIcon, "badgeBackgroundColor" : badgeBackgroundColor, "points" : points, "illustration" : illustration]
                    }
                }
            }
        }

        return dataDic
    }
    
    func getBadgesData() -> NSDictionary {
        var dataDic = NSDictionary()
        var badgeName = ""
        var badgeIcon = ""
        var badgeBackgroundColor = ""
        
        if let userStrength = rawFeedDictionary["nomination"] as? [String : Any]{
            if let badgesDic = userStrength["badges"] as? NSDictionary {
                badgeName = badgesDic["name"] as! String
                badgeIcon = badgesDic["icon"] as! String
                badgeBackgroundColor = badgesDic["background_color"] as! String
                dataDic = ["badgeName" : badgeName, "badgeIcon" : badgeIcon, "badgeBackgroundColor" : badgeBackgroundColor]
            }
        }
        
        return dataDic
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
    
    func getReactionsData() -> NSArray? {
//        if let images = rawFeedDictionary["reaction_type"] as? NSArray{
//                return images
//        }
        return reactionTypeData
    }
    
    func getNumberOfLikesCount() -> Int64 {
        print(rawFeedDictionary)
        return 0
    }
    
    func getReactionCount() -> Int64 {
        return numberOfLikes
    }
    
    func getUserReactionType() -> Int {
        return Int(reactionType) ?? -1 // -1 indicates no reaction
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
    private let reactionType : Int64
    var reactionTypeData : NSArray
    
    public init(input : [String : Any]){
        self.rawFeedDictionary = input
        isLikedByMe = rawFeedDictionary["has_appreciated"] as? Bool ?? false
        numberOfComments = rawFeedDictionary["comments_count"] as? Int64 ?? 0
        isPriority = rawFeedDictionary["priority"] as? Bool ?? false
        isAdminUser = rawFeedDictionary["is_admin"] as? Bool ?? false
        reactionType = rawFeedDictionary["user_reaction_type"] as? Int64 ?? -1 // -1 indicates no reaction
        
        if let likesCount = rawFeedDictionary["appreciation_count"] as? Int64{
            numberOfLikes = likesCount
        }else {
            numberOfLikes = 0
        }
        
        if let reactionData = rawFeedDictionary["reaction_type"] as? NSArray{
                reactionTypeData = reactionData
        }else{
            reactionTypeData = NSArray()
        }
    }
    
    public init(managedObject : NSManagedObject){
        self.rawFeedDictionary = (managedObject as! ManagedPost).postRawDictionary as! [String : Any]
        self.isLikedByMe = (managedObject as! ManagedPost).isLikedByMe
        self.numberOfLikes = (managedObject as! ManagedPost).numberOfLikes
        numberOfComments = (managedObject as! ManagedPost).numberOfComments
        isPriority = (managedObject as! ManagedPost).isPriority
        isAdminUser = (managedObject as! ManagedPost).isAdmin
        reactionType = (managedObject as! ManagedPost).messageType
        reactionTypeData = (managedObject as! ManagedPost).reactionTypesData as! NSArray
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
        managedPost.messageType = reactionType
        managedPost.reactionTypesData = reactionTypeData
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
    
    func getGiphy() -> String?  {
        return  rawFeedDictionary["gif"] as? String
    }
    
    func getFeedType() -> FeedType {
        if let type = rawFeedDictionary["post_type"] as? Int,
            let pollType = FeedType(rawValue: type){
            return pollType
        }else{
            return .Post
        }
    }
    
    func getPostType() -> FeedPostType {
        if let type = rawFeedDictionary["post_type"] as? Int,
            let pollType = FeedPostType(rawValue: type){
            if type == 6 {
                return .Appreciation
            }else {
                return .Nomination
            }
        }else{
            return .Appreciation
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
    
    func getHomeUserImg() -> String? {
        var userImg : String?
        if let userDic = rawFeedDictionary["user"] as? NSDictionary {
            userImg = userDic["profile_img"] as? String ?? nil
        }
        return userImg
    }
    
    func getHomeUserCreatedName() -> String? {
        var userName : String?
        if let userDic = rawFeedDictionary["created_by_user_info"] as? NSDictionary {
            userName = userDic["full_name"] as? String ?? ""
        }
        return userName
    }
    
    func getHomeUserReceivedName() -> String? {
        var userName : String?
        if let userDic = rawFeedDictionary["user"] as? NSDictionary {
            userName = userDic["full_name"] as? String ?? ""
        }
        return userName
    }
    
    
    func getHomeUserReceivedImg() -> String? {
        var userImg : String?
        if let userDic = rawFeedDictionary["user"] as? NSDictionary {
            userImg = userDic["profile_img"] as? String ?? nil
        }
        return userImg
    }

    
    func getGivenTabUserImg() -> String? {
        var userImg : String?
        if let userDic = rawFeedDictionary["created_by_user_info"] as? NSDictionary {
            userImg = userDic["profile_img"] as? String ?? nil
        }
        return userImg
    }
    
    func toUserName() -> String? {
        var userName = ""
        if let userDic = rawFeedDictionary["user"] as? NSDictionary {
            userName = userDic["full_name"] as! String
        }
        
        return userName
    }
    
    func getNominatedByUserName() -> String? {
        var userName = ""
        if let userDic = rawFeedDictionary["user"] as? NSDictionary {
            userName = userDic["full_name"] as! String
        }
        
        return userName
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
    
    func getfeedCreationMonthYear() -> String? {
        //hello
        if let rawDate = rawFeedDictionary["created_on"] as? String{
            return CommonFrameworkDateUtility.getDisplayedDateInFormatMMMYYYY(input: rawDate, dateFormat: "yyyy-MM-dd") ?? ""
        }
        return rawFeedDictionary["created_on"] as? String
    }
    
    func getAppreciationCreationMonthDate() -> String? {
        if let rawDate = rawFeedDictionary["created_on"] as? String{
            return CommonFrameworkDateUtility.getDisplayedDateInFormatMMMDD(input: rawDate, dateFormat: "yyyy-MM-dd") ?? ""
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
        
        if let images = rawFeedDictionary["images_with_ecard"] as? [[String : Any]]{
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
        return "Like"
    }
    
    func getNumberOfComments() -> String {
        return "\(numberOfComments) \("Comment".localized)".appending(numberOfComments == 1 ? "" : "s".localized)
    }
    
    func updateNumberOfComments() -> String {
        return "\(numberOfComments + 1) \("Comment".localized)".appending(numberOfComments == 1 ? "" : "s".localized)
    }
    
    func hasOnlyMedia() -> Bool {
        return getFeedTitle() == nil && getFeedDescription() == nil
    }
}
