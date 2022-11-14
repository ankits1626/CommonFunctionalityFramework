//
//  FeedOrganisationDepartmentSelectionModel.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 10/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

struct FeedOrganisationDepartmentSelectionDisplayModel{
    var fetchedOrganisations = [FeedOrganisation]()
    var selectionModel : FeedOrganisationDepartmentSelectionModel
    
    func displayables() -> [String]{
        var retval = [String]()
        for org in fetchedOrganisations{
            if selectionModel.selectedOrganisations.contains(org.pk){
                retval.append("\(org.displayName) - All")
            }else{
                var deps = [String]()
                for department in org.departments{
                    if selectionModel.selectedDepartments.contains(department.pk){
                        deps.append(department.getDisplayName())
                    }
                }
                if !deps.isEmpty{
                    retval.append("\(org.displayName) - \(deps.joined(separator: ","))")
                }
            }
            
        }
        
        return retval
    }
}

/**
 model to encapsulate selected organisation and departments while creating a post
 will be useful only when multi-org post is enabled
 */
struct FeedOrganisationDepartmentSelectionModel{
    var selectedOrganisations = Set<Int>()
    var selectedDepartments = Set<Int>()
    
    init(_ selectedOrganisations:Set<Int> , _ selectedDepartments:Set<Int>){
        self.selectedOrganisations = selectedOrganisations
        self.selectedDepartments = selectedDepartments
    }
    
    func getupdatePostDictionary( _ postDictionary : inout [String : Any]){
        var selectedOrganisationsPks = [Int]()
        for orgPk in selectedOrganisations{
            selectedOrganisationsPks.append(orgPk)
        }
        postDictionary["organizations"] = selectedOrganisationsPks
        
        var selectedDepartmentPks = [Int]()
        for departmentPk in selectedDepartments{
            selectedDepartmentPks.append(departmentPk)
        }
        
        postDictionary["departments"] = selectedDepartmentPks
    }
    
}
