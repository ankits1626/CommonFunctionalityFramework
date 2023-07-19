//
//  PreviewablePost.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 29/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import RewardzCommonComponents
import UIKit



class PreviewableLocalMediaItem : MediaItemProtocol{
    func getGiphy() -> String? {
        return ""
    }
    
    func getImagePK() -> Int? {
        return 0
    }
    
    func getMediaType() -> FeedMediaItemType {
        return .Image
    }
    
    func getCoverImageUrl() -> String? {
        return localMediaUrl.absoluteString
    }
    
    func getRemoteId() -> Int {
        return -1
    }
    
    let localMediaUrl : URL
    init(_ localMediaUrl : URL) {
        self.localMediaUrl = localMediaUrl
    }
}


class PreviewablePost : FeedsItemProtocol{
    func getOrganizationName() -> String? {
        return ""
    }
    
    func getOrganizationLogo() -> String? {
        return ""
    }
    
    func getHomeUserCreatedName() -> String? {
        return ""
    }
    
    func getHomeUserReceivedName() -> String? {
        return ""
    }
    
    func getGivenTabUserImg() -> String? {
        return ""
    }
    
    func getHomeUserReceivedImg() -> String? {
        return ""
    }
    
    func toUserName() -> String? {
        return ""
    }
    
    func getNominatedByUserName() -> String? {
        return ""
    }
    
    func getfeedCreationMonthDay() -> String? {
        return ""
    }
    
    func getfeedCreationMonthYear() -> String? {
        return ""
    }
    
    func getAppreciationCreationMonthDate() -> String? {
        return ""
    }
    
    func updateNumberOfComments() -> String {
        return ""
    }
    
    func getGiphy() -> String? {
        return editablePost.getNetworkPostableFormat()["gif"] as? String
    }
    
    func getEcardUrl() -> String? {
        return editablePost.getNetworkPostableFormat()["ecardImageUrl"] as? String
    }
    
    func getStrengthData() -> NSDictionary {
        return NSDictionary()
    }
    
    func getPostType() -> FeedPostType {
        return .Appreciation
    }
    
    func getBadgesData() -> NSDictionary {
        return NSDictionary()
    }
    
    func getUserReactionType() -> Int {
        return -1
    }
    
    func getReactionsData() -> NSArray? {
        return []
    }
    
    func getReactionCount() -> Int64 {
        return 0
    }
    
    func getFeedHeight() -> CGFloat {
        return 0
    }
    
    func geteCardHeight() -> CGFloat {
        if let ecardImageUrl = editablePost.getNetworkPostableFormat()["ecardImageUrl"] as? String {
            return CGFloat(imageDimenssions(url: ecardImageUrl))
        }
        return 250
    }
    
    func getSingleImageHeight() -> CGFloat {
        if let mediaList = mediaRepository?.getMediaListForPreview(editablePost){
            if mediaList.count == 1 {
                if let imageUrl = mediaList[0].getCoverImageUrl() as? String {
                    return CGFloat(imageDimenssions(url: imageUrl))
                }
            }
        }
        return 250
    }
    
    func getGifImageHeight() -> CGFloat {
        if let gifUrl = editablePost.getNetworkPostableFormat()["gif"] as? String {
            return CGFloat(imageDimenssions(url: gifUrl))
        }
        return 250
    }
    
    func getGreeting() -> GreetingAnniAndBday? {
        return nil
    }
    
    func imageDimenssions(url: String) -> CGFloat{
        if let imageSource = CGImageSourceCreateWithURL(URL(string: url)! as CFURL, nil) {
            if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
                let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat ?? 0.0
                return pixelHeight
            }
        }
        return 0.0
    }
    
    var feedIdentifier: Int64
    
    private let editablePost : EditablePostProtocol
    weak var mediaRepository : EditablePostMediaRepository?
    weak var mainAppCoordinator : CFFMainAppInformationCoordinator?
    init(_ editablePost : EditablePostProtocol, mediaRepository : EditablePostMediaRepository?, mainppCoordinator: CFFMainAppInformationCoordinator?){
        self.editablePost = editablePost
        self.mediaRepository = mediaRepository
        self.mainAppCoordinator = mainppCoordinator
        feedIdentifier =  -1
    }
    
    func getUserImageUrl() -> String? {
        return editablePost.parentFeedItem?.getUserImageUrl() ?? mainAppCoordinator?.getCurrenUserProfilePicUrl()
    }
    
    func getUserName() -> String? {
        return editablePost.parentFeedItem?.getUserName() ?? mainAppCoordinator?.getCurrentUserName()
    }
    
    func getDepartmentName() -> String? {
        return editablePost.parentFeedItem?.getDepartmentName() ?? mainAppCoordinator?.getCurrentUserDepartment()
    }
    
    func getfeedCreationDate() -> String? {
        return editablePost.parentFeedItem?.getfeedCreationDate() ?? CommonFrameworkDateUtility.getCurrentDateInFormatDMMMYYYY(dateFormat: "yyyy-MM-dd")
    }
    
    func getIsEditActionAllowedOnFeedItem() -> Bool {
        return false
    }
    
    func getFeedTitle() -> String? {
        return editablePost.getNetworkPostableFormat()["title"] as? String
    }
    
    func getFeedDescription() -> String? {
        return editablePost.getNetworkPostableFormat()["description"] as? String
    }
    
    func getMediaList() -> [MediaItemProtocol]? {
        return mediaRepository?.getMediaListForPreview(editablePost)
    }
    
    func isClappedByMe() -> Bool {
        return false
    }
    
    func getNumberOfClaps() -> String {
        return ""
    }
    
    func getNumberOfComments() -> String {
        return ""
    }
    
    func getPollState() -> PollState {
        return .Active(hasVoted: false)
    }
    
    func getMediaCountState() -> MediaCountState {
        if let mediaList = mediaRepository?.getMediaListForPreview(editablePost){
            switch mediaList.count{
            case 0:
                return .None
            case 1:
                return .OneMediaItemPresent(mediaType: .Image)
            case 2:
                return .TwoMediaItemPresent
            default:
                return .MoreThanTwoMediItemPresent
            }
        }else{
            return .None
        }
    }
    
    func getFeedType() -> FeedType {
        return editablePost.postType
    }
    
    func getEditablePost() -> EditablePostProtocol {
        return editablePost
    }
    
    func hasOnlyMedia() -> Bool {
        return false
    }
    
    func getPoll() -> Poll? {
        var pollRawDict = [String : Any]()
        let networkPostableDict = editablePost.getNetworkPostableFormat()
        if let activeDays = networkPostableDict["active_days"] as? Int,
           let options = networkPostableDict["answers"] as?  [String]{
            pollRawDict["is_poll_active"] = true
            var answers = [[String : Any]]()
            for (index, option) in options.enumerated() {
                answers.append(["answer_text" : option, "id" : Int64(index)])
            }
            pollRawDict["answers"] = answers
            pollRawDict["active_days"] = activeDays
            if activeDays == 1{
                pollRawDict["poll_remaining_time"] = "24 hrs"
            }else{
                pollRawDict["poll_remaining_time"] = "\(activeDays) days"
            }
            pollRawDict["question"] = (networkPostableDict["title"] as? String) ?? ""
            
            return Poll(rawPoll: pollRawDict)
        }else{
            return nil
        }
    }
    
    func shouldShowDetail() -> Bool {
        return false
    }
    
    func isFeedEditAllowed() -> Bool {
        return false
    }
    
    func isFeedDeleteAllowed() -> Bool {
        return false
    }
    
    func isFeedReportAbuseAllowed() -> Bool {
        return false
    }
    
    func isActionsAllowed() -> Bool {
        return false
    }
    
    func isPinToPost() -> Bool {
        return false
    }
    
    func isLoggedUserAdmin() -> Bool {
        return false
    }
    
    func getLikeToggleUrl(_ baseUrl: String) -> URL {
        return URL(string: "https://google.com/")!
    }
    
    
}
