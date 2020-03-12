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
    var identifier : String
    var mediaType : PHAssetMediaType
}

struct EditablePost : EditablePostProtocol{
    var title: String?
    
    var postDesciption: String?
    
    var attachedMedia: [FeedMediaItemProtocol]?
    
    var selectedMediaItems : [LocalSelectedMediaItem]?
    
}
