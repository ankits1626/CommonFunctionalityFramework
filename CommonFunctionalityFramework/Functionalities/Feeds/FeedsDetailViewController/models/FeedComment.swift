//
//  FeedComment.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

struct CommentUser {
    private let rawCommentUser : [String : Any]
    init(_ rawCommentUser : [String : Any]) {
        self.rawCommentUser = rawCommentUser
    }
    
    func getUserName() -> String {
        return "Hashim Amla" //rawCommentUser[]
    }
    
    func getUserDepartmentName() -> String {
        return "Finance" //rawCommentUser[]
    }
}

struct FeedComment {
    private let rawFeedComment : [String : Any]
    init(_ rawFeedComment : [String : Any]) {
        self.rawFeedComment = rawFeedComment
    }
    
    func getCommentDate() -> String {
        return "12:30pm"
    }
    
    func getCommentText() -> String? {
        return rawFeedComment["text"] as? String
    }
    
    func getCommentUser() -> CommentUser {
        return CommentUser([String : Any]())
    }
}
