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
    weak var parentOrganisation: FeedOrganisation!
    var isDisplayable : Bool = true
    var isJobFamily : Bool = false
    
    init(_ rawFeedDepartment: [String : Any], parentOrganisation: FeedOrganisation!, _isJobFamily : Bool ){
        self.rawFeedDepartment = rawFeedDepartment
        self.parentOrganisation = parentOrganisation
        self.isJobFamily = _isJobFamily
    }
    
    var pk : Int{
        if let unwrappedPk = rawFeedDepartment["pk"] as? Int {
            return unwrappedPk
        }else {
            return rawFeedDepartment["id"] as? Int ?? 0
        }
    }
    
    func getDisplayName() -> String{
        return rawFeedDepartment["name"] as? String ?? "No Name"
    }
}

class JobFamily: NSObject{
    static func == (lhs: JobFamily, rhs: JobFamily) -> Bool {
        return lhs.id == rhs.id
    }
    
    let rawFeedDepartment: [String : Any]
    weak var parentOrganisation: FeedOrganisation!
    var isDisplayable : Bool = true
    
    init(_ rawFeedDepartment: [String : Any], parentOrganisation: FeedOrganisation!){
        self.rawFeedDepartment = rawFeedDepartment
        self.parentOrganisation = parentOrganisation
    }
    
    var id : Int{
        return rawFeedDepartment["pk"] as! Int
    }
    
    func getJobFamilyName() -> String{
        return rawFeedDepartment["name"] as? String ?? "No Name"
    }
}
