//
//  FeedDepartment.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

class FeedDepartment: NSObject{
    static func == (lhs: FeedDepartment, rhs: FeedDepartment) -> Bool {
        return lhs.pk == rhs.pk
    }
    
    let rawFeedDepartment: [String : Any]
    weak var parentOrganisation: FeedOrgnaisation!
    
    init(_ rawFeedDepartment: [String : Any], parentOrganisation: FeedOrgnaisation!){
        self.rawFeedDepartment = rawFeedDepartment
        self.parentOrganisation = parentOrganisation
    }
    
    var pk : Int{
        return rawFeedDepartment["pk"] as! Int
    }
    
    func getDisplayName() -> String{
        return rawFeedDepartment["name"] as? String ?? "No Name"
    }
}
