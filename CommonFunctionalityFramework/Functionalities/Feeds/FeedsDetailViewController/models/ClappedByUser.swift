//
//  ClappedByUser.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

struct ClappedByUser : FeedBaseUser  {
    var rawUserDictionary: [String : Any]
    var reactionType : Int
    
    init(_ rawClappedByUser : [String : Any], reactionType : Int) {
        self.rawUserDictionary = rawClappedByUser
        self.reactionType = reactionType
    }
    
//    func getUserName() -> String?{
//        return "Test"
//    }
//    func getDepartmentName() -> String? {
//        return "Test Department"
//    }
//    func gerProfilePictureImageEndpoint() -> String?{
//        return "Test"
//    }
}
