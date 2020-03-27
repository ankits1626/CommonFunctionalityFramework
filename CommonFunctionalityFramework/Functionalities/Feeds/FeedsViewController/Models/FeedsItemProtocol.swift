//
//  FeedsItemProtocol.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 03/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

enum FeedMediaItemType{
    case Image
    case Video
}

protocol FeedMediaItemProtocol {
    func getMediaType() -> FeedMediaItemType
    func getCoverImageUrl() -> String?
}

struct FeedVideoItem :  FeedMediaItemProtocol{
    private let rawVideo : [String : Any]
    init(_ rawVideo : [String : Any]) {
        self.rawVideo = rawVideo
    }
    
    func getMediaType() -> FeedMediaItemType{
        return .Video
    }
    func getCoverImageUrl() -> String?{
        
        return rawVideo["display_img_url"] as? String
    }
}

struct FeedImageItem :  FeedMediaItemProtocol{
    private let rawImage : [String : Any]
    init(_ rawImage : [String : Any]) {
        self.rawImage = rawImage
    }
    
    func getMediaType() -> FeedMediaItemType{
        return .Image
    }
    func getCoverImageUrl() -> String?{
        return rawImage["display_img_url"] as? String
    }
}

struct PollOption {
    var title : String{
        return rawPollOption["answer_text"] as? String ?? ""
    }
    private let rawPollOption : [String : Any]
    init(_ rawPollOption : [String : Any]) {
        self.rawPollOption = rawPollOption
    }
}

protocol FeedsItemProtocol {
    init(_ rawfeedItem : [String:Any])
    var feedIdentifier : Int64{get}
    func getUserImageUrl() -> URL?
    func getUserName() -> String?
    func getDepartmentName() -> String?
    func getfeedCreationDate() -> String?
    func getIsEditActionAllowedOnFeedItem() -> Bool
    func getFeedTitle() -> String?
    func getFeedDescription() -> String?
    func getMediaList() -> [FeedMediaItemProtocol]?
    func isClappedByMe() -> Bool
    func getNumberOfClaps() -> String
    func getNumberOfComments() -> String
    func getPollState() -> PollState
    func getMediaCountState() -> MediaCountState
    func getFeedType() -> FeedType
    func getPollOptions() -> [PollOption]?
    func getEditablePost() -> EditablePostProtocol
}

enum FeedType : Int{
    case Poll = 2
    case Post = 1
}

enum PollState {
    case NotAvailable
}

enum MediaCountState {
    case None
    case OneMediaItemPresent(mediaType : FeedMediaItemType)
    case TwoMediaItemPresent
    case MoreThanTwoMediItemPresent
}




