//
//  FeedDepartment.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

struct FeedDepartment{
    let rawFeedDepartment: [String : Any]
    
    init(_ rawFeedDepartment: [String : Any]){
        self.rawFeedDepartment = rawFeedDepartment
    }
    
    func getDisplayName() -> String{
        return "Test Department"
    }
}
