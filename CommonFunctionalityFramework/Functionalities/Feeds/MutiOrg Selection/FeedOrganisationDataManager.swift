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

class FeedOrganisationDataManager{
    private let initModel: FeedOrganisationDataManagerInitModel
    private var fetchedOrganisations = [FeedOrgnaisation]()
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
    
}
