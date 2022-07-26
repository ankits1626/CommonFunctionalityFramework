//
//  FeedOrgnaisation.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

struct FeedOrgnaisation{
    let rawFeedOrgansation: [String : Any]
    
    init(_ rawFeedOrgansation: [String : Any]){
        self.rawFeedOrgansation = rawFeedOrgansation
    }
    
    var displayName : String{
        return "Test Org"
    }
    
    var departments : [FeedDepartment]{
        return [
            FeedDepartment([String : Any]()),
            FeedDepartment([String : Any]()),
            FeedDepartment([String : Any]()),
            FeedDepartment([String : Any]()),
            FeedDepartment([String : Any]()),
        ]
    }
    
    
}
