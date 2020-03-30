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

public struct RawFeed : FeedsItemProtocol {
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
        
        if let rawOptions = rawFeedDictionary["answers"] as? [[String : Any]]{
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
        return RawFeed([String : Any]())
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
            videos.forEach { (aVideo) in
                mediaElements.append(FeedVideoItem(aVideo))
            }
        }
        
        if let videos = rawFeedDictionary["images"] as? [[String : Any]]{
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
