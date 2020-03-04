//
//  Feeds.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

struct FeedAuthor {
    private let rawAuthorDictionary : [String : Any]
    init(rawAuthorDictionary : [String : Any]) {
        self.rawAuthorDictionary = rawAuthorDictionary
    }
    
    func getAuthorName() -> String {
        return rawAuthorDictionary["name"] as? String ?? ""
    }
    
    func getAuthorProfileImageUrl() -> URL? {
        return nil
    }
    
    func getAuthorDepartmentName() -> String {
        return rawAuthorDictionary["department"] as? String ?? ""
    }
}

struct Poll {
    private let rawPoll : [String : Any]
    init(rawPoll : [String : Any]) {
        self.rawPoll = rawPoll
    }
}

struct RawFeed : FeedsItemProtocol {
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
        return .Post
    }
    
    private func getFeedAuthor() -> FeedAuthor?{
        if let rawAuthor = rawFeedDictionary["author"] as? [String:Any]{
            return FeedAuthor(rawAuthorDictionary: rawAuthor)
        }else{
            return nil
        }
    }
    
    func getUserImageUrl() -> URL? {
        return nil
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
        return true
    }
    
    func getFeedTitle() -> String? {
        return rawFeedDictionary["title"] as? String
    }
    
    func getFeedDescription() -> String? {
        return rawFeedDictionary["description"] as? String
    }
    
    func getMediaList() -> [FeedMediaItemProtocol]? {
        var mediaElements = [FeedMediaItemProtocol]()
        if let videos = rawFeedDictionary["videos"] as? [String]{
            videos.forEach { (aVideo) in
                mediaElements.append(FeedVideoItem(aVideo))
            }
        }
        
        if let videos = rawFeedDictionary["images"] as? [String]{
            videos.forEach { (anImage) in
                mediaElements.append(FeedImageItem(anImage))
            }
        }
        return mediaElements.isEmpty ? nil : mediaElements
    }
    
    func isClappedByMe() -> Bool {
        return rawFeedDictionary["isClappedByMe"] as? Bool ?? false
    }
    
    func getNumberOfClaps() -> String {
        let claps = rawFeedDictionary["claps"] as? Int ?? 0
        return "\(claps) Clap".appending(claps == 1 ? "" : "s")
    }
    
    func getNumberOfComments() -> String {
        let comments = rawFeedDictionary["comments"] as? Int ?? 0
        return "\(comments) Comment".appending(comments == 1 ? "" : "s")
    }
    
    private let rawFeedDictionary : [String : Any]
    
    init(_ rawFeedDictionary : [String : Any]) {
        self.rawFeedDictionary = rawFeedDictionary
    }
}
