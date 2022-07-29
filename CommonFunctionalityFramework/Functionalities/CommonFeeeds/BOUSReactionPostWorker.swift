//
//  BOUSReactionPostWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
typealias BOUSReactionPostWorkerResultHandler = (APICallResult<Any?>) -> Void

class BOUSReactionPostWorker  {
    typealias ResultType = Any?
    var commonAPICall : CommonAPICall<ReportAbuseDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func postReaction(postId: Int, reactionType: Int, completionHandler: @escaping BOUSReactionPostWorkerResultHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: BOUSReactionPostWorkerRequestGenerator(feedIdentifier: postId, reactionType: reactionType, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: ReportAbuseDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class BOUSReactionPostWorkerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var feedIdentifier : Int
    var reactionType : Int
    
    init(feedIdentifier: Int, reactionType: Int, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.feedIdentifier = feedIdentifier
        self.reactionType = reactionType
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: baseUrl + "feeds/api/posts/\(feedIdentifier)/appreciate/"),
                    method: .POST,
                    httpBodyDict: [
                        "type" : reactionType
                    ]
                )
                return req
            }
            return nil
        }
    }
}

class BOUSReactionPostWorkerDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = Any?
    typealias ResultType = Any?
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return .Success(result: nil)
    }
}

