//
//  FeedsItemProtocol.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 03/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit



struct FeedVideoItem :  MediaItemProtocol{
    func getRemoteId() -> Int {
        return rawVideo["id"] as! Int
    }
    
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

struct FeedImageItem :  MediaItemProtocol{
    func getRemoteId() -> Int {
        return rawImage["id"] as! Int
    }
    
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

enum FeedType : Int{
    case Poll = 2
    case Post = 1
}



enum MediaCountState {
    case None
    case OneMediaItemPresent(mediaType : FeedMediaItemType)
    case TwoMediaItemPresent
    case MoreThanTwoMediItemPresent
}




