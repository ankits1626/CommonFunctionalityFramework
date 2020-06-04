//
//  PostLikeListFetcher.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

public struct FetchedLikesModel{
    public var fetchedLikes : [String : Any]?
    public var error : String?
    public var nextPageUrl : String?
    
    public init(fetchedLikes: [String : Any]?, error : String?, nextPageUrl : String?) {
        self.fetchedLikes = fetchedLikes
        self.error = error
        self.nextPageUrl = nextPageUrl
    }
}

typealias PostLikeListFetcherHandler = (APICallResult<FetchedLikesModel>) -> Void

class PostLikeListFetcher  {
    typealias ResultType = FetchedLikesModel
    var commonAPICall : CommonAPICall<PostLikeListFetchDataParser>?
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func fetchFeeds(feedIdentifier: Int64, nextPageUrl : String?,completionHandler: @escaping PostLikeListFetcherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: PostLikeListFetchRequestGenerator(
                    feedIdentifier: feedIdentifier,
                    nextPageUrl: nextPageUrl,
                    networkRequestCoordinator: networkRequestCoordinator
                ),
                dataParser: PostLikeListFetchDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class PostLikeListFetchRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    var nextPageUrl : String?
    var feedIdentifier : Int64
    init(feedIdentifier: Int64, nextPageUrl : String?, networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.feedIdentifier = feedIdentifier
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
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + "feeds/api/posts/\(feedIdentifier)/appreciated_by/"),
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

class PostLikeListFetchDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = FetchedLikesModel
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(
            result: FetchedLikesModel(
                fetchedLikes: fetchedData,
                error: nil,
                nextPageUrl: fetchedData["next"] as? String
            )
        )
    }
}
