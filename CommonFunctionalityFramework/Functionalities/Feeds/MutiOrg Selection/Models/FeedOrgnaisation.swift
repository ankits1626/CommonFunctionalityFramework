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
        return rawFeedOrgansation["name"] as? String ?? "No name"
    }
    
    var departments : [FeedDepartment]{
        var fetchedDapartments = [FeedDepartment]()
        if let rawDepartments = rawFeedOrgansation["departments"] as? [[String : Any]]{
            for rawDepartment in rawDepartments {
                fetchedDapartments.append(FeedDepartment(rawDepartment))
            }
        }
        return fetchedDapartments
    }
    
    
}
