//
//  FeedCommentsFetcher.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 09/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

struct FeedCommentsFetchResult {
    var fetchedComments : [FeedComment]?
    var nextPageUrl : String?
}


typealias FeedCommentFetchHandler = (APICallResult<FeedCommentsFetchResult>) -> Void

class FeedCommentsFetcher  {
    typealias ResultType = FeedCommentsFetchResult
    var commonAPICall : CommonAPICall<FeedCommentFetchDataParser>?
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func fetchComments(feedId : Int64, nextpageUrl: String?, completionHandler: @escaping FeedCommentFetchHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedCommentFetchRequestGenerator(
                    feedId: feedId,
                    nextpageUrl: nextpageUrl,
                    networkRequestCoordinator: networkRequestCoordinator
                ),
                dataParser: FeedCommentFetchDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class FeedCommentFetchRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    private var feedId : Int64
    private lazy var feedPostRequestBodyGenerator : PostRequestBodyGenerator = {
        return PostRequestBodyGenerator()
    }()
    private var nextpageUrl: String?
    init(feedId : Int64, nextpageUrl: String?, networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.feedId = feedId
        self.nextpageUrl = nextpageUrl
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url: URL(string: nextpageUrl ?? "https://demo.flabulessdev.com/feeds/api/posts/\(feedId)/comments/"),
                method: .GET,
                httpBodyDict: nil
            )
            
            return req
        }
    }
}

class FeedCommentFetchDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = FeedCommentsFetchResult
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        var comments = [FeedComment]()
        if let results = fetchedData["results"] as? [[String : Any]]{
            for aRawComment in results {
                comments.append(FeedComment(input: aRawComment))
            }
        }
        
        
        return APICallResult.Success(
            result: FeedCommentsFetchResult(
                fetchedComments: comments.isEmpty ? nil : comments,
                nextPageUrl: fetchedData["next"] as? String
            )
        )
    }
}
