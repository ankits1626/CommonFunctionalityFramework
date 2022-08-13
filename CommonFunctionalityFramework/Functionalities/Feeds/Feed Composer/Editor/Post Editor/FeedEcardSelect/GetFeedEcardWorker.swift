//
//  GetFeedEcardWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 12/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import CommonFunctionalityFramework

typealias GetEcardWorkerCompletionHandler = (APICallResult<NSDictionary>) -> Void

class GetEcardWorker  {
    typealias ResultType = NSDictionary
    var commonAPICall : CommonAPICall<GetEcardDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    
    func getEcard(categoryId: Int, searchString: String, nextUrl: String, completionHandler: @escaping GetEcardWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: GetEcardWorkerRequestGenerator( searchString: searchString, nextUrl: nextUrl, categoryId: categoryId, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: GetEcardDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class GetEcardWorkerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    var searchString : String
    var nextUrl: String
    var categoryId: Int
    
    init(searchString: String, nextUrl: String, categoryId: Int, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.searchString = searchString
        self.nextUrl = nextUrl
        self.categoryId = categoryId
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            if searchString.isEmpty && nextUrl.isEmpty {
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url:  self.urlBuilder.getURL(endpoint: "/feeds/api/ecard/?category=\(self.categoryId)", parameters: nil
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
                        endpoint: "/feeds/api/ecard/?search=\(searchString)",
                        parameters: [
                            "search" : searchString,
                            "category_id" : "\(self.categoryId)"
                        ]
                    ),
                    method: .GET ,
                    httpBodyDict: nil
                )
            }
        }
    }
}

class GetEcardDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = NSDictionary
    typealias ResultType = NSDictionary
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}




