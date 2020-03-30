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
        return [String : Any]()
    }
    
    var postType: FeedType
    
    var pollOptions: [String]?
    
    var title: String?
    
    var postDesciption: String?
    
    var attachedMedia: [MediaItemProtocol]?
    
    var selectedMediaItems : [LocalSelectedMediaItem]?
    
}
