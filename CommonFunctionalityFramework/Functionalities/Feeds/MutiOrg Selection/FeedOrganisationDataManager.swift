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
    
    init(_ initModel: FeedOrganisationDataManagerInitModel){
        self.initModel = initModel
    }
    
    
    func fetchFeedOrganisations(_ completion: ()-> Void){
        /**
         TODO: call the organisation fetch api and call the completion
         */
        completion()
    }
}

extension FeedOrganisationDataManager{
    func getOrganisations() -> [FeedOrgnaisation]{
        return [
            FeedOrgnaisation([String : Any]()),
            FeedOrgnaisation([String : Any]()),
            FeedOrgnaisation([String : Any]()),
            FeedOrgnaisation([String : Any]())
        ]
    }
    
}
