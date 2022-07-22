//
//  BOUSReactionListWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

typealias BOUSGetReactionListWorkerCompletionHandler = (APICallResult<NSDictionary>) -> Void

class BOUSGetReactionListWorker  {
    typealias ResultType = NSDictionary
    var commonAPICall : CommonAPICall<BOUSGetReactionListDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    
    func getReactionList(postId : Int, reactionId: String, nextUrl: String, completionHandler: @escaping BOUSGetReactionListWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: BOUSGetReactionListWorkerRequestGenerator(postId : postId, reactionId: reactionId, nextUrl: nextUrl, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: BOUSGetReactionListDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class BOUSGetReactionListWorkerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var nextUrl: String
    var reactionId : String
    var postId : Int
    init(postId : Int, reactionId: String, nextUrl: String, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.reactionId = reactionId
        self.nextUrl = nextUrl
        self.postId = postId
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            if nextUrl.isEmpty && reactionId.isEmpty {
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url:  self.urlBuilder.getURL(endpoint: "feeds/api/posts/\(postId)/post_appreciations/", parameters: nil
                    ),
                    method: .GET ,
                    httpBodyDict: nil
                )
                return req
            }else if !reactionId.isEmpty {
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url:  self.urlBuilder.getURL(endpoint: "feeds/api/posts/\(postId)/post_appreciations/?reaction_type=\(reactionId)", parameters: nil
                    ),
                    method: .GET ,
                    httpBodyDict: nil
                )
                return req
            } else {
                return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: nextUrl),
                    method: .GET ,
                    httpBodyDict: nil
                )
            }
        }
    }
}

class BOUSGetReactionListDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = NSDictionary
    typealias ResultType = NSDictionary
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}
