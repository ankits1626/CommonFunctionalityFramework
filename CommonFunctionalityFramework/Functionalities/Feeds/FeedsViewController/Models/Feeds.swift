//
//  Feeds.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import CoreData

protocol FeedsItemProtocol : Likeable, AnyObject {

    var feedIdentifier : Int64{get}
    func getUserImageUrl() -> String?
    func getUserName() -> String?
    func getOrganizationName() -> String?
    func getOrganizationLogo() -> String?
    func getHomeUserCreatedName() -> String?
    func getHomeUserReceivedName() -> String?
    func getGivenTabUserImg() -> String?
    func getHomeUserReceivedImg() -> String?
    func toUserName() -> String?
    func getNominatedByUserName() -> String?
    func getDepartmentName() -> String?
    func getfeedCreationDate() -> String?
    func getfeedCreationMonthDay() -> String?
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
    func getEcardUrl() -> String?
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
    func getNewFeedType() -> NewFeedPostType 
    func getBadgesData() -> NSDictionary
    func getUserReactionType() -> Int
    func getReactionsData() -> NSArray?
    func getReactionCount() -> Int64
    func getFeedHeight() -> CGFloat
    func geteCardHeight() -> CGFloat
    func getSingleImageHeight() -> CGFloat
    func getGifImageHeight() -> CGFloat
    func getGreeting() -> GreetingAnniAndBday?
    func getCreatorUserPK() -> Int
    func getReceiverUserPK() -> Int
}

public class RawFeed : FeedsItemProtocol, RawObjectProtocol {
    
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
        var backGroundLite = ""
        var illustration = ""
        var points = "0"
        if let userStrength = rawFeedDictionary["nomination"] as? [String : Any]{
            if let userStengthDic = userStrength["user_strength"] as? NSDictionary {
                if let userName = userStengthDic["name"] as? String, !userName.isEmpty {
                    strengthMessage = rawFeedDictionary["description"] as! String
                    // strengthIcon = userStengthDic["icon"] as! String
                    badgeBackgroundColor = userStengthDic["background_color"] as? String ?? "#EBEBEB"
                    backGroundLite = userStengthDic["background_color_lite"] as? String ?? "#EBEBEB"
                    
                    if let pts = rawFeedDictionary["points"] as? String {
                        points = pts
                    }
                    
                    
                    dataDic = ["strengthName" : userName, "strengthMessage" : strengthMessage, "strengthIcon" : strengthIcon, "badgeBackgroundColor" : badgeBackgroundColor, "points" : points, "illustration" : "","background_color_lite" : backGroundLite]
                }else {
                    if let userStengthDic = rawFeedDictionary["user_strength"] as? NSDictionary {
                        if let pts = rawFeedDictionary["points"] as? String {
                            points = pts
                        }
                        
                        strengthName = userStengthDic["name"] as! String
                        strengthMessage = rawFeedDictionary["description"] as! String
                        strengthIcon = userStengthDic["icon"] as? String ?? ""
                        if let unwrappedBgColor = userStengthDic["background_color"] as? String,
                           !unwrappedBgColor.isEmpty {
                            badgeBackgroundColor = unwrappedBgColor
                        }else {
                            badgeBackgroundColor = "#EBEBEB"
                        }
                        
                        if let unwrappedBgColorLite = userStengthDic["background_color_lite"] as? String,
                           !unwrappedBgColorLite.isEmpty {
                            backGroundLite = unwrappedBgColorLite
                        }else {
                            backGroundLite = "#EBEBEB"
                        }
                        
                        illustration = userStengthDic["illustration"] as? String ?? ""
                        dataDic = ["strengthName" : strengthName, "strengthMessage" : strengthMessage, "strengthIcon" : strengthIcon, "badgeBackgroundColor" : badgeBackgroundColor, "points" : points, "illustration" : illustration,"background_color_lite" : backGroundLite]
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
    
    func getGreeting() -> GreetingAnniAndBday? {
        if let unwrappedRawPoll = rawFeedDictionary["greeting_info"] as? [String : Any]{
            let date = unwrappedRawPoll["date"] as? String ?? ""
            let department_name = unwrappedRawPoll["department_name"] as? String ?? ""
            let profile_pic = unwrappedRawPoll["profile_pic"] as? String ?? ""
            let thumbnail = unwrappedRawPoll["thumbnail"] as? String ?? ""
            let type = unwrappedRawPoll["type"] as? String ?? ""
            let user_email = unwrappedRawPoll["user_email"] as? String ?? ""
            let user_first_name = unwrappedRawPoll["user_first_name"] as? String ?? ""
            let user_last_name = unwrappedRawPoll["user_last_name"] as? String ?? ""
            let user_pk = unwrappedRawPoll["user_pk"] as! Int
            let yearCompleted = unwrappedRawPoll["years_completed"] as? Int ?? 0

            return GreetingAnniAndBday(date: date, department_name: department_name, profile_pic: profile_pic, thumbnail: thumbnail, type: type, userPk: user_pk, user_email: user_email, user_first_name: user_first_name, user_last_name: user_last_name, yearCompleted: yearCompleted)
        }
        return nil
    }
    
    func getReactionsData() -> NSArray? {
        //        if let images = rawFeedDictionary["reaction_type"] as? NSArray{
        //                return images
        //        }
        return reactionTypeData
    }
    
    func getFeedHeight() -> CGFloat {
        return CGFloat(feedImageHeight)
    }
    
    func getGifImageHeight() -> CGFloat {
        return CGFloat(gifImageHeight)
    }
    
    func geteCardHeight() -> CGFloat {
        return CGFloat(ecardImageHeight)
    }
    
    func getSingleImageHeight() -> CGFloat {
        return CGFloat(singleImageHeight)
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
    private var feedImageHeight: Float
    private var ecardImageHeight: Float
    private var singleImageHeight: Float
    private var gifImageHeight: Float
    var defaultFeedImageHeight: Float = 250
    let serverUrl = UserDefaults.standard.value(forKey: "base_url_for_image_height") as? String ?? ""

    required public init(input : [String : Any]){
        self.rawFeedDictionary = input
        isLikedByMe = rawFeedDictionary["has_appreciated"] as? Bool ?? false
        numberOfComments = rawFeedDictionary["comments_count"] as? Int64 ?? 0
        isPriority = rawFeedDictionary["priority"] as? Bool ?? false
        isAdminUser = rawFeedDictionary["is_admin"] as? Bool ?? false
        reactionType = rawFeedDictionary["user_reaction_type"] as? Int64 ?? -1 // -1 indicates no reaction

        if let ecardData = rawFeedDictionary["images_with_ecard"] as? [[String : Any]] {
            if ecardData.count == 1 {
                let eCardImg = ecardData[0] as? NSDictionary
                let eImage = eCardImg!["display_img_url"] as? String ?? ""
                self.ecardImageHeight =  Float(FTImageSize.shared.getImageSizeFromImageURL(serverUrl+eImage, perferdWidth: UIScreen.main.bounds.width).height)
                self.singleImageHeight = self.ecardImageHeight
            }else {
                self.ecardImageHeight = defaultFeedImageHeight
                self.singleImageHeight = defaultFeedImageHeight
            }
        }else {
            self.ecardImageHeight = defaultFeedImageHeight
            self.singleImageHeight = defaultFeedImageHeight
        }
        
        if let gifData = rawFeedDictionary["gif"] as? String, !gifData.isEmpty {
            self.gifImageHeight =  Float(FTImageSize.shared.getImageSizeFromImageURL(gifData, perferdWidth: UIScreen.main.bounds.width).height)
        }else {
            self.gifImageHeight = defaultFeedImageHeight
        }

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
        
        self.feedImageHeight = 140.0
//        self.gifImageHeight = 140.0
//        self.ecardImageHeight = 140.0
//        self.singleImageHeight = 140.0

    }
    
    required public init(managedObject : NSManagedObject){
        self.rawFeedDictionary = (managedObject as! ManagedPost).postRawDictionary as! [String : Any]
        self.isLikedByMe = (managedObject as! ManagedPost).isLikedByMe
        self.numberOfLikes = (managedObject as! ManagedPost).numberOfLikes
        numberOfComments = (managedObject as! ManagedPost).numberOfComments
        isPriority = (managedObject as! ManagedPost).isPriority
        isAdminUser = (managedObject as! ManagedPost).isAdmin
        reactionType = (managedObject as! ManagedPost).messageType
        reactionTypeData = (managedObject as! ManagedPost).reactionTypesData as! NSArray
        feedImageHeight = (managedObject as! ManagedPost).feedImageHeight
        ecardImageHeight = (managedObject as! ManagedPost).ecardImageHeight
        singleImageHeight = (managedObject as! ManagedPost).singleImageHeight
        gifImageHeight = (managedObject as! ManagedPost).gifImageHeight
    }
    
    func imageDimenssions(url: String) -> CGFloat{
        if let imageSource = CGImageSourceCreateWithURL(URL(string: url)! as CFURL, nil) {
            if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
                //                let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as? CGFloat ?? 0.0
                let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat ?? 0.0
                return pixelHeight
            }
        }
        return 0.0
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
        managedPost.feedImageHeight = feedImageHeight
        managedPost.ecardImageHeight = ecardImageHeight
        managedPost.singleImageHeight = singleImageHeight
        managedPost.gifImageHeight = gifImageHeight
        return managedPost
    }
    
    
    func getEditablePost() -> EditablePostProtocol {
        if let unrappedDescription = getFeedDescription(){
            let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(
                feedId: feedIdentifier,
                description: unrappedDescription
            )
            
            var post =  EditablePost(
                postSharedChoice: sharedWith(),
                postType: getFeedType(),
                pollOptions: nil,
                title: getFeedTitle(),
                postDesciption:  model?.displayableDescription.string,
                remoteAttachedMedia: getMediaList(),
                selectedMediaItems: nil,
                remotePostId: feedIdentifier != -1 ? "\(feedIdentifier)" : nil,
                selectedOrganisationsAndDepartments: getSharedOption()
            )
            post.parentFeedItem = self
            if let unwrappedGifSource = model?.attachedGif{
                post.attachedGif = RawGif(sourceUrl: unwrappedGifSource)
            }
            
            if let giphy = getGiphy(),
                     !giphy.isEmpty{
                post.attachedGiflyGif = giphy
            }
            if let cardPK = getEcardPK(),
               cardPK > 0 {
                post.currentEcardPK = cardPK
            }
            
            return post
            
        }else{
            
            var post =  EditablePost(
                postSharedChoice: sharedWith(),
                postType: getFeedType(),
                pollOptions: nil,
                title: getFeedTitle(),
                postDesciption:  getFeedDescription(),
                remoteAttachedMedia: getMediaList(),
                selectedMediaItems: nil,
                remotePostId: feedIdentifier != -1 ? "\(feedIdentifier)" : nil,
                selectedOrganisationsAndDepartments: getSharedOption()
            )
            post.parentFeedItem = self
            if let giphy = getGiphy(),
                     !giphy.isEmpty{
                post.attachedGiflyGif = giphy
            }
            if let cardPK = getEcardPK(),
               cardPK > 0 {
                post.currentEcardPK = cardPK
            }
            return post
        }
        
    }
    
    private func getSharedOption() -> FeedOrganisationDepartmentSelectionModel?{
        if sharedWith() == .MultiOrg{
            var orgs = Set<Int>()
            var departments =  Set<Int>()
            var jobFamilies =  Set<Int>()
            if let selectedOrgs = rawFeedDictionary["organizations"] as? [Int]{
                orgs = Set(selectedOrgs)
            }
            if let selectedDepartments = rawFeedDictionary["departments"] as? [Int]{
                departments = Set(selectedDepartments)
            }
            if let selectedJobFamilies = rawFeedDictionary["job_families"] as? [Int]{
                jobFamilies = Set(selectedJobFamilies)
            }
            return FeedOrganisationDepartmentSelectionModel(orgs, departments, jobFamilies)
        }
        
        return nil
    }
    
    private func sharedWith() -> SharePostOption{
        if let rawSharedWithValue = rawFeedDictionary["shared_with"] as? Int,
            let departmentSharedChoice = SharePostOption(rawValue: rawSharedWithValue) {
            return departmentSharedChoice
        //    let departmentSharedChoice = DepartmentSharedChoice(rawValue: rawSharedWithValue) {
        //     return departmentSharedChoice == .SelfDepartment
        }else{
            return .MyOrg
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
    
    func getEcardPK() -> Int?  {
        return  rawFeedDictionary["ecard"] as? Int ?? 0
    }
    
    func getEcardUrl() -> String? {
        if let ecardData = rawFeedDictionary["ecard"] as? NSDictionary {
            return ecardData["display_img_url"] as? String ?? ""
        }
        return nil
    }
    
    func getEcard() -> EcardListResponseValues? {
        if let ecardData = rawFeedDictionary["ecard"] as? NSDictionary {
            let id = ecardData.object(forKey: "pk") as? Int ?? 0
            let categoryId = ecardData.object(forKey: "category") as? Int ?? 0
            let ecardImages = ecardData.object(forKey: "image") as? String ?? ""
            return EcardListResponseValues(category: categoryId, image: ecardImages, pk: id)
        }
        return nil
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
            }else if type == 9 {
                return .Greeting
            } else {
                return .Nomination
            }
        }else{
            return .Appreciation
        }
    }
    
    func getNewFeedType() -> NewFeedPostType {
        if let type = rawFeedDictionary["post_type"] as? Int,
           let pollType = NewFeedPostType(rawValue: type){
            return pollType
        }else{
            return .Nomination
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
        
    func getReceiverUserPK() -> Int {
        if let userDic = rawFeedDictionary["user"] as? NSDictionary {
            return userDic["pk"] as? Int ?? 0
        }
        return 0
    }
    
    func getOrganizationName() -> String? {
        var userImg : String?
        if let userDic = rawFeedDictionary["user"] as? NSDictionary {
            userImg = userDic["organization_name"] as? String ?? nil
        }
        return userImg
    }
    
    func getOrganizationLogo() -> String? {
        var userImg : String?
        if let userDic = rawFeedDictionary["user"] as? NSDictionary {
            userImg = userDic["organization_logo"] as? String ?? nil
        }
        return userImg
    }
    
    func getCreatorUserPK() -> Int {
        if let userDic = rawFeedDictionary["created_by_user_info"] as? NSDictionary {
            return userDic["pk"] as? Int ?? 0
        }
        return 0
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
            userName = userDic["full_name"] as? String ?? ""
        }
        
        return userName
    }
    
    func getNominatedByUserName() -> String? {
        var userName = ""
        if let userDic = rawFeedDictionary["user"] as? NSDictionary {
            userName = userDic["full_name"] as? String ?? ""
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
    
    func getfeedCreationMonthDay() -> String? {
        //hello
        if let rawDate = rawFeedDictionary["greeting_info"] as? [String : Any] {
            let date = rawDate["date"] as? String ?? ""
            return CommonFrameworkDateUtility.getDisplayedDateInFormatMMMDD(input: date, dateFormat: "yyyy-MM-dd") ?? ""
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
