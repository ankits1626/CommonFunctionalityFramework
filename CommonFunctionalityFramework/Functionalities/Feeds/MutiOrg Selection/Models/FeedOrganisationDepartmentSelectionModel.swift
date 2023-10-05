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
                var JobFamily = [String]()
                for department in org.departments{
                    if selectionModel.selectedDepartments.contains(department.pk){
                        deps.append(department.getDisplayName())
                    }else if selectionModel.selectedJobFamily.contains(department.pk){
                        JobFamily.append(department.getDisplayName())
                    }
                }
                if !deps.isEmpty{
                    let jobFamilyData = !JobFamily.isEmpty ?  "- \(JobFamily.joined(separator: ","))"  : ""
                    retval.append("\(org.displayName) - \(deps.joined(separator: ","))")
                    if !JobFamily.isEmpty {
                        retval.append("jobfamily\(org.displayName) \(jobFamilyData)")
                    }
                }else if !JobFamily.isEmpty{
                    retval.append("jobfamily\(org.displayName) - \(JobFamily.joined(separator: ","))")
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
    var selectedJobFamily = Set<Int>()
    
    init(_ selectedOrganisations:Set<Int> , _ selectedDepartments:Set<Int>, _ selectedJobFamily:Set<Int>){
        self.selectedOrganisations = selectedOrganisations
        self.selectedDepartments = selectedDepartments
        self.selectedJobFamily = selectedJobFamily
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
        
        var selectedJobFamilies = [Int]()
        for jobFamilyPk in selectedJobFamily{
            selectedJobFamilies.append(jobFamilyPk)
        }
        
        postDictionary["job_families"] = selectedJobFamilies
        
    }
    
}
