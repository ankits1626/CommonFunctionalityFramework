//
//  EditablePost.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import Photos

struct LocalSelectedMediaItem : Equatable {
    static func ==(_ lhs: LocalSelectedMediaItem, _ rhs: LocalSelectedMediaItem) -> Bool {
      return lhs.identifier == rhs.identifier
    }
    var identifier : String
    var asset: PHAsset?
    var mediaType : PHAssetMediaType
}

struct EditablePost : EditablePostProtocol{
    var deletedRemoteMediaArray = [Int]()
    var postableLocalMediaUrls: [URL]?
    
    var postableMediaMap: [Int : Data]?
    
    func getNetworkPostableFormat() -> [String : Any] {
        switch postType {
        case .Poll:
            return getPollDictionary()
        case .Post:
            return getPostDictionary()
        }
    }
    
    private func getPollDictionary() -> [String : Any]{
        var pollDictionary = [String : Any]()
        if let unwrappedTitle = title{
            pollDictionary["title"] = unwrappedTitle
        }
        if let options = pollOptions{
           pollDictionary["answers"] = options
        }
        return pollDictionary
    }
    
    private func getPostDictionary() -> [String : Any]{
        var postDictionary = [String : Any]()
        if let unwrappedTitle = title{
            postDictionary["title"] = unwrappedTitle
        }
        if let unwrappedDescription = postDesciption{
            postDictionary["description"] = unwrappedDescription
        }
        if !deletedRemoteMediaArray.isEmpty{
            postDictionary["delete_image_ids"] = deletedRemoteMediaArray
        }
        return postDictionary
    }
    
    var postType: FeedType
    
    var pollOptions: [String]?
    
    var title: String?
    
    var postDesciption: String?
    
    var remoteAttachedMedia: [MediaItemProtocol]?
    
    var selectedMediaItems : [LocalSelectedMediaItem]?
    
    let remotePostId : String?
    
    func getEditablePostNetworkModel() -> EditablePostNetworkModel{
        return EditablePostNetworkModel(
            url: getEditablePostNetworkUrl(),
            method: getEditablePostNetworkMethod(),
            postHttpBodyDict: getNetworkPostableFormat() as NSDictionary
        )
    }
    
    private func getEditablePostNetworkUrl() -> URL?{
        if let unwrappedRemotePostId = remotePostId{
            switch postType {
            case .Poll:
                return nil
            case .Post:
                return URL(string: "https://demo.flabulessdev.com/feeds/api/posts/\(unwrappedRemotePostId)/")
            }
        }else{
            switch postType {
            case .Poll:
                return URL(string: "https://demo.flabulessdev.com/feeds/api/posts/create_poll/")
            case .Post:
                return URL(string: "https://demo.flabulessdev.com/feeds/api/posts/")
            }
        }
    }
    
    private func getEditablePostNetworkMethod () -> HTTPMethod{
        return  remotePostId == nil ? .POST : .PUT
    }
    
}


struct EditablePostNetworkModel {
    var url : URL?
    var method : HTTPMethod
    var postHttpBodyDict : NSDictionary?
}
