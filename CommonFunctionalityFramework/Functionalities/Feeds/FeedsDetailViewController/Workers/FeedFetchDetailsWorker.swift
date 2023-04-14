//
//  FeedFetchDetailsWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 04/04/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation

typealias FeedDetailsFetcherFormWorkerCompletionHandler = (APICallResult<NSDictionary>) -> Void
class FeedDetailsFetcherFormWorker  {
    typealias ResultType = NSDictionary
    var commonAPICall : CommonAPICall<FeedDetailsFetcherFormDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func getFeedDetailsFetcher(feedId: Int64, completionHandler: @escaping FeedDetailsFetcherFormWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedDetailsFetcherFormWorkerRequestGenerator(networkRequestCoordinator: networkRequestCoordinator, feedId: feedId),
                dataParser: FeedDetailsFetcherFormDataParser(), logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class FeedDetailsFetcherFormWorkerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    let feedId: Int64
    
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, feedId: Int64) {
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
        self.feedId = feedId
    }
    
    var apiRequest: URLRequest?{
        get{
            return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url:  self.urlBuilder.getURL(endpoint: "/feeds/api/posts/" + "\(feedId)/", parameters: nil),
                method: .GET ,
                httpBodyDict: nil
            )
        }
    }
}

class FeedDetailsFetcherFormDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = NSDictionary
    typealias ResultType = NSDictionary
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}

