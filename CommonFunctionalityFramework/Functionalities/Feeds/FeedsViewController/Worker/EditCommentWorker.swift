//
//  EditCommentWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 05/09/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

typealias EditCommentWorkerResultHandler = (APICallResult<Any?>) -> Void

class EditCommentWorker  {
    typealias ResultType = Any?
    var commonAPICall : CommonAPICall<EditCommentDeleteDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func deleteComment(_ feedIdentifier: Int64,commentMessage : String, completionHandler: @escaping EditCommentWorkerResultHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: EditCommentDeleteRequestGenerator(feedIdentifier: feedIdentifier, _commentData: commentMessage, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: EditCommentDeleteDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class EditCommentDeleteRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var feedIdentifier : Int64
    var commentData : String
    init( feedIdentifier: Int64, _commentData : String, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.feedIdentifier = feedIdentifier
        self.commentData = _commentData
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: baseUrl + "feeds/api/comments/\(feedIdentifier)/"),
                    method: .PATCH,
                    httpBodyDict: nil
                )
                return req
            }
            return nil
        }
    }
}

class EditCommentDeleteDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = Any?
    typealias ResultType = Any?
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return .Success(result: nil)
    }
}


