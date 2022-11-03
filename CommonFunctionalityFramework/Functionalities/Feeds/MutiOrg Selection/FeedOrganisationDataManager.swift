//
//  FeedOrganisationDataManager.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

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
    private var fetchedOrganisations = [FeedOrgnaisation]()
    
    private var selectedOrganisation = Set<FeedOrgnaisation>()
    private var selectedDepartment = Set<FeedDepartment>()
    
    init(_ initModel: FeedOrganisationDataManagerInitModel){
        self.initModel = initModel
        if let unwrappedSelectedOrgDepartment = initModel.selectionModel{
            self.selectedOrganisation = unwrappedSelectedOrgDepartment.selectedOrganisations
            self.selectedDepartment = unwrappedSelectedOrgDepartment.selectedDepartments
        }
    }
    
    
    func fetchFeedOrganisations(_ completion: @escaping (_ error: String?)-> Void){
        FeedsOrganisationFetcher(networkRequestCoordinator: initModel.requestCoordinator!).fetchFeedOrganisations { [weak self] result in
            DispatchQueue.main.async {
                completion(self?.handleOrganisationFetchResult(result))
                
            }
        }
    }
}

extension FeedOrganisationDataManager{
    
    private func handleOrganisationFetchResult(_ result: APICallResult<[FeedOrgnaisation]>) -> String?{
        switch result{
        case .Success(result: let result):
            self.fetchedOrganisations = result
            var refreshedSelectedOrg = Set<FeedOrgnaisation>()
            var refreshedSelectedDepartment = Set<FeedDepartment>()
            for org in result {
                if !(selectedOrganisation.filter{$0 == org}).isEmpty{
                    refreshedSelectedOrg.insert(org)
                }
                
                for dep in org.departments {
                    if !(selectedDepartment.filter{$0 == dep}).isEmpty{
                        refreshedSelectedDepartment.insert(dep)
                    }
                }
                
            }
            selectedDepartment = refreshedSelectedDepartment
            selectedOrganisation = refreshedSelectedOrg
            return nil
        case .SuccessWithNoResponseData:
            return "Unexpected response while fetching organisations"
        case .Failure(error: let error):
            return error.localizedDescription
        }
    }
}

extension FeedOrganisationDataManager{
    func getOrganisations() -> [FeedOrgnaisation]{
        return fetchedOrganisations
    }
    
    func toggleOrganisationSelection(_ organisation: FeedOrgnaisation, _ completion: ()-> Void){
        if checkIfOrganisationIsSelected(organisation){
            selectedOrganisation.remove(organisation)
            for deparment in organisation.departments {
                selectedDepartment.remove(deparment)
            }
            
        }else{
            selectedOrganisation.insert(organisation)
            for deparment in organisation.departments {
                selectedDepartment.insert(deparment)
            }
        }
        completion()
    }
    
    func checkIfOrganisationIsSelected(_ organisation: FeedOrgnaisation) -> Bool{
        return !selectedOrganisation.filter{$0 == organisation}.isEmpty
    }
    
    func checkIfDepartmentIsSelected(_ department: FeedDepartment) -> Bool{
        return !selectedDepartment.filter{$0 == department}.isEmpty
    }
    
    func toggleDepartmentSelection(_ department: FeedDepartment, _ completion:()->Void){
        if selectedDepartment.contains(department){
            selectedDepartment.remove(department)
            if let parentOrg = department.parentOrganisation,
               selectedOrganisation.contains(parentOrg){
                selectedOrganisation.remove(parentOrg)
            }
        }else{
            selectedDepartment.insert(department)
            var selectedDepartmentsFromSameOrgCount = 0
            if let targetOrganisation = department.parentOrganisation{
                for department in targetOrganisation.departments{
                    if selectedDepartment.contains(department){
                        selectedDepartmentsFromSameOrgCount = selectedDepartmentsFromSameOrgCount + 1
                    }
                }
                if selectedDepartmentsFromSameOrgCount == targetOrganisation.departments.count{
                    selectedOrganisation.insert(targetOrganisation)
                }
            }
        }
        completion()
    }
 
    func getSelectionDetails(_ organisation: FeedOrgnaisation) -> String?{
        if checkIfOrganisationIsSelected(organisation){
            return "All departments selected"
        }else{
            let selectedDepartments = selectedDepartment.filter{$0.parentOrganisation == organisation}
            let filteredSelectedDepartments = selectedDepartment.filter({ department in
                return department.parentOrganisation == organisation
            })
            if !selectedDepartments.isEmpty{
                var retval : String?
                if let firstDepartment = filteredSelectedDepartments.first{
                    retval =  "\(firstDepartment.getDisplayName())"
                }
                if filteredSelectedDepartments.count > 1{
                    retval = retval! + " + \(filteredSelectedDepartments.count - 1) selected"
                }
                return retval
            }
        }
        return nil
    }
    
    func checkIfAnyOrganisationOrDepartmentSelected() -> Bool {
        return !selectedDepartment.isEmpty || !selectedOrganisation.isEmpty
    }
    
    func getSelectedOrganisationsAndDepartments() -> FeedOrganisationDepartmentSelectionModel{
        return FeedOrganisationDepartmentSelectionModel(
            selectedOrganisations: selectedOrganisation,
            selectedDepartments: selectedDepartment
        )
    }
}
