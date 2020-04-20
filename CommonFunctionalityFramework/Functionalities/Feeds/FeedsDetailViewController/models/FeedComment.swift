//
//  FeedComment.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

struct CommentUser : FeedBaseUser{
    var rawUserDictionary: [String : Any]
    
    init(_ rawCommentUser : [String : Any]) {
        self.rawUserDictionary = rawCommentUser
    }
    
}

struct FeedComment {
    private let rawFeedComment : [String : Any]
    init(_ rawFeedComment : [String : Any]) {
        self.rawFeedComment = rawFeedComment
    }
    
    func getCommentDate() -> String {
        return rawFeedComment["created_on"] as? String ?? ""
    }
    
    func getCommentText() -> String? {
        return rawFeedComment["content"] as? String
    }
    
    func getCommentUser() -> CommentUser {
        return CommentUser(rawFeedComment["commented_by_user_info"] as? [String : Any] ?? [String : Any]())
    }
}
