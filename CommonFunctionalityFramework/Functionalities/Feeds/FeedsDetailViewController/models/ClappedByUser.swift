//
//  ClappedByUser.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

struct ClappedByUser  {
    private let rawClappedByUser : [String : Any]
    init(_ rawClappedByUser : [String : Any]) {
        self.rawClappedByUser = rawClappedByUser
    }
    
    func getUserName() -> String?{
        return "Test"
    }
    func getDepartmentName() -> String? {
        return "Test Department"
    }
    func gerProfilePictureImageEndpoint() -> String?{
        return "Test"
    }
}
