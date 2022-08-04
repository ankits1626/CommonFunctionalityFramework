//
//  FeedsOrganisationFetcher.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 02/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import RewardzCommonComponents

typealias FeedsOrganisationFetcherHandler = (APICallResult<[FeedOrgnaisation]>) -> Void

class FeedsOrganisationFetcher  {
    typealias ResultType = [FeedOrgnaisation]
    var commonAPICall : CommonAPICall<FeedsOrganisationFetchDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    
    func fetchFeedOrganisations(_ completionHandler: @escaping FeedsOrganisationFetcherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedsOrganisationFetchRequestGenerator(
                    networkRequestCoordinator: networkRequestCoordinator
                ),
                dataParser: FeedsOrganisationFetchDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
    
}

class FeedsOrganisationFetchRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: baseUrl + "profiles/api/org_departments/"),
                    method: .GET,
                    httpBodyDict: nil
                )
                return req
            }
            return nil
        }
    }
}

class FeedsOrganisationFetchDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [[String : Any]]
    typealias ResultType = [FeedOrgnaisation]
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        var fetchedOrganisation = [FeedOrgnaisation]()
        for rawOrganisation in fetchedData{
            fetchedOrganisation.append(FeedOrgnaisation(rawOrganisation))
        }
        return APICallResult.Success(result: fetchedOrganisation)
    }
}
