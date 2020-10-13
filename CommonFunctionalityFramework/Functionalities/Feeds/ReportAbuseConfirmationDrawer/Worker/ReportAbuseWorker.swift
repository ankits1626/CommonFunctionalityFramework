//
//  ReportAbuseWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit Sachan on 11/10/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation
typealias ReportAbuseWorkerResultHandler = (APICallResult<Any?>) -> Void

class ReportAbuseWorker  {
    typealias ResultType = Any?
    var commonAPICall : CommonAPICall<ReportAbuseDataParser>?
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func reportAbusePost(_ feedIdentifier: Int64, notes: String?, completionHandler: @escaping ReportAbuseWorkerResultHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: ReportAbuseRequestGenerator(feedIdentifier: feedIdentifier, notes: notes, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: ReportAbuseDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class ReportAbuseRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    var feedIdentifier : Int64
    var notes: String?
    init( feedIdentifier: Int64, notes: String?, networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.feedIdentifier = feedIdentifier
        self.notes = notes
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: baseUrl + "feeds/api/posts/\(feedIdentifier)/flag/"),
                    method: .POST,
                    httpBodyDict: notes == nil ? nil :  ["notes" : notes!]
                )
                return req
            }
            return nil
        }
    }
}

class ReportAbuseDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = Any?
    typealias ResultType = Any?
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return .Success(result: nil)
    }
}
