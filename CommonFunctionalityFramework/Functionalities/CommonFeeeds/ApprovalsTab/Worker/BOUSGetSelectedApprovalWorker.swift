//
//  BOUSGetSelectedApprovalWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 20/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

typealias BOUSGetSelectedApproverWorkerCompletionHandler = (APICallResult<NSDictionary>) -> Void

class BOUSGetSelectedApproverWorker  {
    typealias ResultType = NSDictionary
    var commonAPICall : CommonAPICall<BOUSGetSelectedApproverDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func getApproverData(searchString: String, nextUrl: String, approverId: Int, completionHandler: @escaping BOUSGetSelectedApproverWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: BOUSGetSelectedApproverWorkerRequestGenerator( searchString: searchString, nextUrl: nextUrl,approverId: approverId, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: BOUSGetSelectedApproverDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class BOUSGetSelectedApproverWorkerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var searchString : String
    var nextUrl: String
    var approverId: Int
    
    init(searchString: String, nextUrl: String,approverId: Int, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.searchString = searchString
        self.nextUrl = nextUrl
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
        self.approverId = approverId
    }
    
    var apiRequest: URLRequest?{
        get{
            if searchString.isEmpty && nextUrl.isEmpty {
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url:  self.urlBuilder.getURL(endpoint: "feeds/api/posts/\(approverId)/", parameters: nil
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

class BOUSGetSelectedApproverDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = NSDictionary
    typealias ResultType = NSDictionary
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}




