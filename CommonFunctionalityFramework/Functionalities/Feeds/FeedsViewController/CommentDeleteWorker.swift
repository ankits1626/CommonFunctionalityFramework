//
//  CommentDeleteWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 05/09/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

typealias CommentDeleteWorkerResultHandler = (APICallResult<Any?>) -> Void

class CommentDeleteWorker  {
    typealias ResultType = Any?
    var commonAPICall : CommonAPICall<CommentDeleteDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func deleteComment(_ feedIdentifier: Int64,completionHandler: @escaping CommentDeleteWorkerResultHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: CommentDeleteRequestGenerator(feedIdentifier: feedIdentifier, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: CommentDeleteDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class CommentDeleteRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var feedIdentifier : Int64
    init( feedIdentifier: Int64, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.feedIdentifier = feedIdentifier
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: baseUrl + "feeds/api/comments/\(feedIdentifier)/"),
                    method: .DELETE,
                    httpBodyDict: nil
                )
                return req
            }
            return nil
        }
    }
}

class CommentDeleteDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = Any?
    typealias ResultType = Any?
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return .Success(result: nil)
    }
}

