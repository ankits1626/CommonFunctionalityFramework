//
//  FeedOrgnaisation.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

class FeedOrganisation : NSObject{
    static func == (lhs: FeedOrganisation, rhs: FeedOrganisation) -> Bool {
        return lhs.pk == rhs.pk
    }
    
    let rawFeedOrgansation: [String : Any]
    var isDisplayable : Bool = true
    
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
                fetchedDapartments.append(FeedDepartment(rawDepartment, parentOrganisation: self,_isJobFamily: false))
            }
        }
        if let rawDepartments = rawFeedOrgansation["job_families"] as? [[String : Any]]{
            for rawDepartment in rawDepartments {
                fetchedDapartments.append(FeedDepartment(rawDepartment, parentOrganisation: self,_isJobFamily: true))
            }
        }
        return fetchedDapartments
    }()
    
    lazy var jobFamily: [JobFamily] = {
        var fetchedDapartments = [JobFamily]()
        if let rawDepartments = rawFeedOrgansation["departments"] as? [[String : Any]]{
            for rawDepartment in rawDepartments {
                fetchedDapartments.append(JobFamily(rawDepartment, parentOrganisation: self))
            }
        }
        return fetchedDapartments
    }()
    
    
}
