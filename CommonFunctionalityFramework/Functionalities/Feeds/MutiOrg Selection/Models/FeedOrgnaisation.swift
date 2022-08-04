//
//  FeedOrgnaisation.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

class FeedOrgnaisation : NSObject{
    static func == (lhs: FeedOrgnaisation, rhs: FeedOrgnaisation) -> Bool {
        return lhs.pk == rhs.pk
    }
    
    let rawFeedOrgansation: [String : Any]
    
    init(_ rawFeedOrgansation: [String : Any]){
        self.rawFeedOrgansation = rawFeedOrgansation
    }
    
    var displayName : String{
        return rawFeedOrgansation["name"] as? String ?? "No name"
    }
    
    var pk : Int{
        return rawFeedOrgansation["pk"] as! Int
    }
    
    lazy var departments: [FeedDepartment] = {
        var fetchedDapartments = [FeedDepartment]()
        if let rawDepartments = rawFeedOrgansation["departments"] as? [[String : Any]]{
            for rawDepartment in rawDepartments {
                fetchedDapartments.append(FeedDepartment(rawDepartment, parentOrganisation: self))
            }
        }
        return fetchedDapartments
    }()
    
    
}
