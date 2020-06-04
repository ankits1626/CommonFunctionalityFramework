//
//  PostDeleteWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

typealias PostDeleteWorkerResultHandler = (APICallResult<Any?>) -> Void

class PostDeleteWorker  {
    typealias ResultType = Any?
    var commonAPICall : CommonAPICall<PostDeleteDataParser>?
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func deletePost(_ feedIdentifier: Int64,completionHandler: @escaping PostDeleteWorkerResultHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: PostDeleteRequestGenerator(feedIdentifier: feedIdentifier, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: PostDeleteDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class PostDeleteRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    var feedIdentifier : Int64
    init( feedIdentifier: Int64, networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.feedIdentifier = feedIdentifier
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: baseUrl + "feeds/api/posts/\(feedIdentifier)/"),
                    method: .DELETE,
                    httpBodyDict: nil
                )
                return req
            }
            return nil
        }
    }
}

class PostDeleteDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = Any?
    typealias ResultType = Any?
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return .Success(result: nil)
    }
}
