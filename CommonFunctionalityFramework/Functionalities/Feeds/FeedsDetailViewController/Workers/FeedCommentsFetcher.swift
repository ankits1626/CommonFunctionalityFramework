//
//  FeedCommentsFetcher.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 09/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

typealias FeedCommentFetchHandler = (APICallResult<[FeedComment]>) -> Void

class FeedCommentsFetcher  {
    typealias ResultType = [FeedComment]
    var commonAPICall : CommonAPICall<FeedCommentFetchDataParser>?
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func fetchComments(feedId : Int64, completionHandler: @escaping FeedCommentFetchHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedCommentFetchRequestGenerator(
                    feedId: feedId,
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
    init(feedId : Int64, networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.feedId = feedId
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url: URL(string: "https://demo.flabulessdev.com/feeds/api/posts/\(feedId)/comments/"),
                method: .GET,
                httpBodyDict: nil
            )
        }
    }
}

class FeedCommentFetchDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [[String : Any]]
    typealias ResultType = [FeedComment]
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        var comments = [FeedComment]()
        for aRawComment in fetchedData {
            comments.append(FeedComment(aRawComment))
        }
        return APICallResult.Success(result: comments)
    }
}
