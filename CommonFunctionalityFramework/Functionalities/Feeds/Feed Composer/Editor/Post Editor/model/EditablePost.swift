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
    var title: String?
    
    var postDesciption: String?
    
    var attachedMedia: [FeedMediaItemProtocol]?
    
    var selectedMediaItems : [LocalSelectedMediaItem]?
    
}
