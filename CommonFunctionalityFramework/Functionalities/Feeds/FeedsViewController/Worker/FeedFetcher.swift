//
//  FeedFetcher.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

typealias FeedFetcherHandler = (APICallResult<FetchedFeedModel>) -> Void

class FeedFetcher  {
    typealias ResultType = FetchedFeedModel
    var commonAPICall : CommonAPICall<FeedFetchDataParser>?
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func fetchFeeds(nextPageUrl : String?,completionHandler: @escaping FeedFetcherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedFetchRequestGenerator(
                    nextPageUrl: nextPageUrl,
                    networkRequestCoordinator: networkRequestCoordinator
                ),
                dataParser: FeedFetchDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class FeedFetchRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    var nextPageUrl : String?
    init( nextPageUrl : String?, networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.nextPageUrl = nextPageUrl
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            if let unwrappedNextPageUrl = nextPageUrl {
                return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(url: URL(string: unwrappedNextPageUrl), method: .GET, httpBodyDict: nil)
            }else{
                //            return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(url: URL(string: getServiceURL()+"event_galleries/?event_pk=\(self.eventPk)"), method: .GET, httpBodyDict: nil)
                
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: "https://demo.flabulessdev.com/feeds/api/posts/"),
                    method: .GET,
                    httpBodyDict: nil
                )
                return req
            }
        }
    }
}

class FeedFetchDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = FetchedFeedModel
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(
            result: FetchedFeedModel(
                fetchedRawFeeds: fetchedData,
                error: nil,
                nextPageUrl: fetchedData["next"] as? String
            )
        )
    }
}
