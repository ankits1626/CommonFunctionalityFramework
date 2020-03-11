//
//  FeedComment.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

struct FeedComment {
    let rawfeedComment : [String : Any]
    init(_ rawFeedComment : [String : Any]) {
        self.rawfeedComment = rawFeedComment
    }
}
