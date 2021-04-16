//
//  PostPinWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 15/04/21.
//  Copyright © 2021 Rewardz. All rights reserved.
//

import Foundation
typealias PinPostWorkerResultHandler = (APICallResult<Any?>) -> Void

class PostPinWorker  {
    typealias ResultType = Any?
    var commonAPICall : CommonAPICall<ReportAbuseDataParser>?
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func postPin(_ postId: Int64, frequency: Int?, completionHandler: @escaping PinPostWorkerResultHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: PinPostRequestGenerator(_feedIdentifier: postId, _selectedFrequency: frequency, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: ReportAbuseDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class PinPostRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    var feedIdentifier : Int64
    var selectedFrequency: Int?
    init(_feedIdentifier: Int64, _selectedFrequency: Int?, networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.feedIdentifier = _feedIdentifier
        self.selectedFrequency = _selectedFrequency
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: baseUrl + "feeds/api/posts/pinned_post/"),
                    method: .POST,
                    httpBodyDict: [
                        "post_id" : self.feedIdentifier,
                        "prior_till" : self.selectedFrequency == 0 ? nil : self.selectedFrequency ?? nil
                    ]
                )
                return req
            }
            return nil
        }
    }
}

class PinPostDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = Any?
    typealias ResultType = Any?
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return .Success(result: nil)
    }
}

