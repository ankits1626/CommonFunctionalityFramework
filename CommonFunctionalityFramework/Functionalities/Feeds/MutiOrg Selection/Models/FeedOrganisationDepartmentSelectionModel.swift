//
//  FeedOrganisationDepartmentSelectionModel.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 10/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

/**
 model to encapsulate selected organisation and departments while creating a post
 will be useful only when multi-org post is enabled
 */
struct FeedOrganisationDepartmentSelectionModel{
    var selectedOrganisations = Set<FeedOrgnaisation>()
    var selectedDepartments = Set<FeedDepartment>()
    
    func getupdatePostDictionary( _ postDictionary : inout [String : Any]){
        var selectedOrganisationsPks = [Int]()
        for org in selectedOrganisations{
            selectedOrganisationsPks.append(org.pk)
        }
        if !selectedOrganisationsPks.isEmpty{
            postDictionary["organizations"] = selectedOrganisationsPks
        }
        
        var selectedDepartmentPks = [Int]()
        for department in selectedDepartments{
            selectedDepartmentPks.append(department.pk)
        }
        
        if !selectedDepartmentPks.isEmpty{
            postDictionary["departments"] = selectedDepartmentPks
        }
    }
}
