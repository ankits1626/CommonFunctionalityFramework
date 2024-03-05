//
//  BOUSGetApprovalsListWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 13/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

typealias BOUSGetApprovalsListWorkerCompletionHandler = (APICallResult<NSDictionary>) -> Void

class BOUSGetApprovalsListWorker  {
    typealias ResultType = NSDictionary
    var commonAPICall : CommonAPICall<BOUSGetApprovalsListDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func getApprovalsList(searchString: String, nextUrl: String, completionHandler: @escaping BOUSGetApprovalsListWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: BOUSGetApprovalsListWorkerRequestGenerator( searchString: searchString, nextUrl: nextUrl, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: BOUSGetApprovalsListDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class BOUSGetApprovalsListWorkerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var searchString : String
    var nextUrl: String
    
    init(searchString: String, nextUrl: String, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.searchString = searchString
        self.nextUrl = nextUrl
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            if searchString.isEmpty && nextUrl.isEmpty {
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url:  self.urlBuilder.getURL(endpoint: "feeds/api/user_feed/?feed=approvals", parameters: nil
                    ),
                    method: .GET ,
                    httpBodyDict: nil
                )
                return req
            }else if !nextUrl.isEmpty {
                return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: nextUrl),
                    method: .GET ,
                    httpBodyDict: nil
                )
            }else {
                return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url:  self.urlBuilder.getURL(
                        endpoint: "feeds/api/user_feed/?feed=approvals",
                        parameters: [
                            "search" : searchString
                        ]
                    ),
                    method: .GET ,
                    httpBodyDict: nil
                )
            }
        }
    }
}

class BOUSGetApprovalsListDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = NSDictionary
    typealias ResultType = NSDictionary
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}



