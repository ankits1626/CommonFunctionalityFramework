//
//  FeedOrganisationDataManager.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import UIKit
import RewardzCommonComponents

struct FeedOrganisationDataManagerInitModel {
    weak var requestCoordinator: CFFNetworkRequestCoordinatorProtocol?
    var selectionModel: FeedOrganisationDepartmentSelectionModel?
}

enum SelectionOperation{
    case Selected
    case DeSelected
}

class FeedOrganisationDataManager{
    private let initModel: FeedOrganisationDataManagerInitModel
    private var fetchedOrganisations = [FeedOrganisation]()
    private var fetchedDepartment = [FeedDepartment]()
    
    var selectedOrganisation = Set<Int>()
    var selectedDepartment = Set<Int>()
    var selectedJobFamily = Set<Int>()
    
    var departmentIndex : [[Int]] = [[]]
    var jobFamilyIndex : [[Int]] = [[]]
    
    private var isSearchEnabled = false
    
    init(_ initModel: FeedOrganisationDataManagerInitModel){
        self.initModel = initModel
        if let unwrappedSelectedOrgDepartment = initModel.selectionModel{
            self.selectedOrganisation = unwrappedSelectedOrgDepartment.selectedOrganisations
            self.selectedDepartment = unwrappedSelectedOrgDepartment.selectedDepartments
            self.selectedJobFamily = unwrappedSelectedOrgDepartment.selectedJobFamily
        }
    }
    
    
    func fetchFeedOrganisations(_ completion: @escaping (_ error: String?)-> Void){
        FeedsOrganisationFetcher(networkRequestCoordinator: initModel.requestCoordinator!).fetchFeedOrganisations { [weak self] result in
            DispatchQueue.main.async {
                completion(self?.handleOrganisationFetchResult(result))
                
            }
        }
    }
    
    func updateSearchState(_ isSearchEnabled : Bool){
        if !isSearchEnabled{
            for organisation in fetchedOrganisations {
                organisation.isDisplayable = true
                for department in organisation.departments {
                    department.isDisplayable = true
                }
            }
        }
        self.isSearchEnabled = isSearchEnabled
    }
    
    func performSearch(_ searchKey: String, completion:()-> Void){
        for org in fetchedOrganisations{
            var displayableDepartmentCount = 0
            for department in org.departments {
                if department.getDisplayName().lowercased().contains(searchKey.lowercased()){
                    department.isDisplayable = true
                    displayableDepartmentCount = displayableDepartmentCount + 1
                }else{
                    department.isDisplayable = false
                }
            }
            
            if org.displayName.lowercased().contains(searchKey.lowercased()) || displayableDepartmentCount>0{
                org.isDisplayable = true
            }else{
                org.isDisplayable = false
            }
        }
        completion()
    }
    
    
}

extension FeedOrganisationDataManager{
    
    private func handleOrganisationFetchResult(_ result: APICallResult<[FeedOrganisation]>) -> String?{
        switch result{
        case .Success(result: let result):
            self.fetchedOrganisations = result
            var refreshedSelectedOrg = Set<Int>()
            var refreshedSelectedDepartment = Set<Int>()
            var refreshedSelectedJobFamily = Set<Int>()
            for org in result {
                if !(selectedOrganisation.filter{$0 == org.pk}).isEmpty{
                    refreshedSelectedOrg.insert(org.pk)
                }
                
                for dep in org.departments {
                    if !(selectedDepartment.filter{$0 == dep.pk}).isEmpty{
                        if !dep.isJobFamily {
                            refreshedSelectedDepartment.insert(dep.pk)
                        }
                        
                    }
                }
                
                for jobFamily in org.departments {
                    if !(selectedJobFamily.filter{$0 == jobFamily.pk}).isEmpty{
                        if jobFamily.isJobFamily {
                            refreshedSelectedJobFamily.insert(jobFamily.pk)
                        }
                    }
                }
                
            }
            selectedDepartment = refreshedSelectedDepartment
            selectedOrganisation = refreshedSelectedOrg
            selectedJobFamily = refreshedSelectedJobFamily
            return nil
        case .SuccessWithNoResponseData:
            return "Unexpected response while fetching organisations"
        case .Failure(error: let error):
            return error.localizedDescription
        }
    }
}

extension FeedOrganisationDataManager{
    func getOrganisations() -> [FeedOrganisation]{
        return fetchedOrganisations.filter{$0.isDisplayable}
    }
    
    func getDepartmentBackgroundColor() -> UIColor {
        return RCCThemeDetailProvider.shared.coordinator.getBackgroundColor().withAlphaComponent(0.1)
    }
    
    func getJobFamilyBackgroundColor() -> UIColor {
        return UIColor(red: 52/255, green: 170/255, blue: 220/255, alpha: 0.1)
    }
    
    func getDepartmentTitleColor() -> UIColor {
        return RCCThemeDetailProvider.shared.coordinator.getBackgroundColor().withAlphaComponent(1.0)
    }
    
    func getJobFamilyTitleColor() -> UIColor {
        return UIColor(red: 52/255, green: 170/255, blue: 220/255, alpha: 1.0)
    }
    
    
     
    func getDepartment() -> [FeedDepartment] {
        return fetchedDepartment.filter{$0.isDisplayable}
    }
    
    func isDepartmentEnabled(section : Int) -> Bool {
        for department in  fetchedOrganisations[section].departments {
            if !department.isJobFamily {
                return true
            }
        }
        return false
    }
    
    func isJobFamilyEnabled(section : Int) -> Bool {
        for department in  fetchedOrganisations[section].departments {
            if department.isJobFamily {
                return true
            }
        }
        return false
    }
    
    func isDepartmentDataMatch(departmentData : [FeedDepartment]) -> Bool {
        for department in departmentData {
            if selectedDepartment.contains(department.pk) {
                return true
            }
        }
        return false
    }
    
    func isJobFamilyDataMatch(departmentData : [FeedDepartment]) -> Bool {
        for department in departmentData {
            if selectedJobFamily.contains(department.pk) {
                return true
            }
        }
        return false
    }
    
    func getDepartmentCount(organisation: FeedOrganisation) ->  Bool{
        if isDepartmentDataMatch(departmentData: organisation.departments) {
            for deparment in organisation.departments {
                if !deparment.isJobFamily {
                    return true
                }
            }
        }
        return false
    }
    
    func getJobFamiliesCount(organisation: FeedOrganisation) ->  Bool{
        if isJobFamilyDataMatch(departmentData: organisation.departments) {
            for deparment in organisation.departments {
                if deparment.isJobFamily {
                    return true
                }
            }
        }
        return false
    }
    
    func toggleOrganisationSelection(_ organisation: FeedOrganisation, _ completion: ()-> Void){
        if checkIfOrganisationIsSelected(organisation){
            selectedOrganisation.remove(organisation.pk)
        }
        
        if isDepartmentDataMatch(departmentData: organisation.departments) {
            for deparment in organisation.departments {
                if !deparment.isJobFamily {
                    selectedDepartment.remove(deparment.pk)
                }
            }
        }else{
            for deparment in organisation.departments {
                if deparment.isDisplayable && !deparment.isJobFamily{
                    selectedDepartment.insert(deparment.pk)
                }
            }
            var selectedDepartmentsFromSameOrgCount = 0
            for department in organisation.departments{
                if selectedDepartment.contains(department.pk) || selectedJobFamily.contains(department.pk){
                    selectedDepartmentsFromSameOrgCount = selectedDepartmentsFromSameOrgCount + 1
                }
            }
            if selectedDepartmentsFromSameOrgCount == organisation.departments.count{
                selectedOrganisation.insert(organisation.pk)
            }
        }
        completion()
    }
    
    func toggleJobFamilySelection(_ organisation: FeedOrganisation, _ completion: ()-> Void){
        if checkIfOrganisationIsSelected(organisation){
            selectedOrganisation.remove(organisation.pk)
        }
        if isJobFamilyDataMatch(departmentData: organisation.departments) {
            for deparment in organisation.departments {
                if deparment.isJobFamily {
                    selectedJobFamily.remove(deparment.pk)
                }
            }
        }else{
            for deparment in organisation.departments {
                if deparment.isDisplayable && deparment.isJobFamily{
                    selectedJobFamily.insert(deparment.pk)
                }
            }
            
            var selectedDepartmentsFromSameOrgCount = 0
            for department in organisation.departments{
                if selectedDepartment.contains(department.pk) || selectedJobFamily.contains(department.pk){
                    selectedDepartmentsFromSameOrgCount = selectedDepartmentsFromSameOrgCount + 1
                }
            }
            if selectedDepartmentsFromSameOrgCount == organisation.departments.count{
                selectedOrganisation.insert(organisation.pk)
            }
        }
        completion()
    }
    
    func checkIfOrganisationIsSelected(_ organisation: FeedOrganisation) -> Bool{
        return !selectedOrganisation.filter{$0 == organisation.pk}.isEmpty
    }
    
    func checkIfDepartmentIsSelected(_ department: FeedDepartment) -> Bool{
        return !selectedDepartment.filter{$0 == department.pk}.isEmpty
    }
    
    func checkIfJobFamilyIsSelected(_ department: FeedDepartment) -> Bool{
        return !selectedJobFamily.filter{$0 == department.pk}.isEmpty
    }
    
    func toggleDepartmentSelection(_ department: FeedDepartment, _ completion:()->Void){
        if !department.isJobFamily {
            if selectedDepartment.contains(department.pk){
                selectedDepartment.remove(department.pk)
                if let parentOrg = department.parentOrganisation,
                   selectedOrganisation.contains(parentOrg.pk){
                    selectedOrganisation.remove(parentOrg.pk)
                }
            }else{
                selectedDepartment.insert(department.pk)
                var selectedDepartmentsFromSameOrgCount = 0
                if let targetOrganisation = department.parentOrganisation{
                    for department in targetOrganisation.departments{
                        if selectedDepartment.contains(department.pk){
                            selectedDepartmentsFromSameOrgCount = selectedDepartmentsFromSameOrgCount + 1
                        }
                    }
                    let totalOrgSum = selectedDepartment.count + selectedJobFamily.count
                    if totalOrgSum == targetOrganisation.departments.count{
                        selectedOrganisation.insert(targetOrganisation.pk)
                    }
                }
            }
        }else {
            if selectedJobFamily.contains(department.pk){
                selectedJobFamily.remove(department.pk)
                if let parentOrg = department.parentOrganisation,
                   selectedOrganisation.contains(parentOrg.pk){
                    selectedOrganisation.remove(parentOrg.pk)
                }
            }else{
                selectedJobFamily.insert(department.pk)
                var selectedDepartmentsFromSameOrgCount = 0
                if let targetOrganisation = department.parentOrganisation{
                    for department in targetOrganisation.departments{
                        if selectedJobFamily.contains(department.pk){
                            selectedDepartmentsFromSameOrgCount = selectedDepartmentsFromSameOrgCount + 1
                        }
                    }
                    let totalOrgSum = selectedDepartment.count + selectedJobFamily.count
                    if totalOrgSum == targetOrganisation.departments.count{
                        selectedOrganisation.insert(targetOrganisation.pk)
                    }
                }
            }
        }
        
        completion()
    }
 
    func getSelectionDetails(_ organisation: FeedOrganisation) -> String?{
        if checkIfOrganisationIsSelected(organisation){
            return "All departments selected".localized
        }else{
            var filteredSelectedDepartments = [FeedDepartment]()
            for department in organisation.departments{
                if (self.selectedDepartment.contains(department.pk)){
                    filteredSelectedDepartments.append(department)
                }
            }
            if !filteredSelectedDepartments.isEmpty{
                var retval : String?
                //return retval
                if let firstDepartment = filteredSelectedDepartments.first{
                    retval =  "\(firstDepartment.getDisplayName())"
                }
                if filteredSelectedDepartments.count > 1{
                    retval = retval! + " + \(filteredSelectedDepartments.count - 1) \("selected".localized)"
                }
                return retval
            }
        }
        return nil
    }
    
    func checkIfAnyOrganisationOrDepartmentSelected() -> Bool {
        return !selectedDepartment.isEmpty || !selectedOrganisation.isEmpty ||  !selectedJobFamily.isEmpty
    }
    
    func getSelectedOrganisationsAndDepartments() -> FeedOrganisationDepartmentSelectionModel{
        return FeedOrganisationDepartmentSelectionModel(
            selectedOrganisation,
            selectedDepartment, selectedJobFamily
        )
    }
    
    func getSelectedOrganisationsAndDepartmentsDisplayable() -> FeedOrganisationDepartmentSelectionDisplayModel{
        return FeedOrganisationDepartmentSelectionDisplayModel(
            fetchedOrganisations: fetchedOrganisations,
            selectionModel: getSelectedOrganisationsAndDepartments()
        )
    }
}
