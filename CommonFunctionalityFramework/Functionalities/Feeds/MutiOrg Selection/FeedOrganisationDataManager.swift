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
    
    private var selectedOrganisation = Set<Int>()
    private var selectedDepartment = Set<IndexPath>()
    
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
    
    func toggleOrganisationSelection(_ orgIndex: Int){
        if selectedOrganisation.contains(orgIndex){
            selectedOrganisation.remove(orgIndex)
            for (index , _) in fetchedOrganisations[orgIndex].departments.enumerated(){
                selectedDepartment.remove(IndexPath(row: index, section: orgIndex))
            }
        }else{
            selectedOrganisation.insert(orgIndex)
            for (index , _) in fetchedOrganisations[orgIndex].departments.enumerated(){
                selectedDepartment.insert(IndexPath(row: index, section: orgIndex))
            }
            
        }
    }
    
    func checkIfOrganisationIsSelected(_ orgIndex: Int) -> Bool{
        return selectedOrganisation.contains(orgIndex)
    }
    
    func checkIfDepartmentIsSelected(_ departmentIndexPath: IndexPath) -> Bool{
        return selectedDepartment.contains(departmentIndexPath)
    }
    
    func toggleDepartmentSelection(_ departmentIndexPath: IndexPath){
        if selectedDepartment.contains(departmentIndexPath){
            if selectedOrganisation.contains(departmentIndexPath.section){
                print("<<<<< removed \(departmentIndexPath.section)")
                selectedOrganisation.remove(departmentIndexPath.section)
            }
            print("<<<<< removed \(departmentIndexPath)")
            selectedDepartment.remove(departmentIndexPath)
            
        }else{
            selectedDepartment.insert(departmentIndexPath)
        }
    }
 
    func getSelectionDetails(_ section: Int) -> String?{
        if selectedOrganisation.contains(section){
            return "All departments selected"
        }else{
            let filteredSelectedDepartments = selectedDepartment.filter({ indexpath in
                return indexpath.section == section
            })
            if !filteredSelectedDepartments.isEmpty{
                var retval : String?
                if let firstDepartmentIndexpath = filteredSelectedDepartments.first{
                    retval =  "\(fetchedOrganisations[section].departments[firstDepartmentIndexpath.row].getDisplayName())"
                }
                if filteredSelectedDepartments.count > 1{
                    retval = retval! + " + \(filteredSelectedDepartments.count - 1) selected"
                }
                return retval
            }
        }
        return nil
    }
}
