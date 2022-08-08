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
    
    func fetchFeeds(nextPageUrl : String?, feedType: String?, searchText: String?, completionHandler: @escaping FeedFetcherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedFetchRequestGenerator(
                    feedID: nil,
                    nextPageUrl: nextPageUrl, feedType: feedType, searchText: searchText,
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
    
    func fetchFeedDetail(_ feedID: Int,feedType: String, completionHandler: @escaping FeedFetcherHandler){
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedFetchRequestGenerator(
                    feedID: feedID,
                    nextPageUrl: nil, feedType: feedType, searchText: "",
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
    private var feedType : String?
    private var searchText : String?
    
    init( feedID: Int?, nextPageUrl : String?, feedType: String?, searchText: String?, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
         self.feedID = feedID
        self.nextPageUrl = nextPageUrl
        self.feedType = feedType
        self.searchText = searchText
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            if let searchedText = searchText {
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + "feeds/api/user_feed/?feed=\(feedType!)&search=\(searchedText)"),
                        method: .GET,
                        httpBodyDict: nil
                    )
                    return req
                }
                return nil
            }else if let unwrappedFeedId = feedID{
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + "feeds/api/user_feed/\(unwrappedFeedId)/"),
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
                        url: URL(string: baseUrl + "feeds/api/user_feed/?feed=\(feedType!)"),
                        method: .GET,
                        httpBodyDict: nil
                    )
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
