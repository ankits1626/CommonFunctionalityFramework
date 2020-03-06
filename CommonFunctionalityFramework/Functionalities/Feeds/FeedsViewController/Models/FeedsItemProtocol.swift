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

protocol FeedsItemProtocol {
    init(_ rawfeedItem : [String:Any])
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
}

enum FeedType{
    case Poll
    case Post
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




