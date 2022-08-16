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
        if selectedOrganisation.contains(organisation){
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
        return selectedOrganisation.contains(organisation)
    }
    
    func checkIfDepartmentIsSelected(_ department: FeedDepartment) -> Bool{
        return selectedDepartment.contains(department)
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
        if selectedOrganisation.contains(organisation){
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
