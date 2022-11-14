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
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    
    func fetchFeeds(nextPageUrl : String?,completionHandler: @escaping FeedFetcherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedFetchRequestGenerator(
                    feedID: nil,
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
    
    func fetchFeedDetail(_ feedID: Int, completionHandler: @escaping FeedFetcherHandler){
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedFetchRequestGenerator(
                    feedID: feedID,
                    nextPageUrl: nil,
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
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    private var nextPageUrl : String?
    private var feedID : Int?
    
    init( feedID: Int?, nextPageUrl : String?, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
         self.feedID = feedID
        self.nextPageUrl = nextPageUrl
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            if let unwrappedFeedId = feedID{
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + "feeds/api/posts/\(unwrappedFeedId)/"),
                        method: .GET,
                        httpBodyDict: nil
                    )
                    return req
                }
                return nil
            }
            else if let unwrappedNextPageUrl = nextPageUrl {
                return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(url: URL(string: unwrappedNextPageUrl), method: .GET, httpBodyDict: nil)
            }else{
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + "feeds/api/posts/"),
                        method: .GET,
                        httpBodyDict: nil
                    )
                    
                    print("here \(req)")
                    return req
                }
                return nil
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
