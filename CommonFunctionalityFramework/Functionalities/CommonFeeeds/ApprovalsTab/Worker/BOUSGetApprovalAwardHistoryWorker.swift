//
//  BOUSGetApprovalAwardHistoryWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 29/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

typealias BOUSGetAprrovalAwardHistoryWorkerCompletionHandler = (APICallResult<NSDictionary>) -> Void

class BOUSGetAprrovalAwardHistoryWorker  {
    typealias ResultType = NSDictionary
    var commonAPICall : CommonAPICall<BOUSGetAprrovalAwardHistoryDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func getApproverAwardHistoryData(nominationId: Int, completionHandler: @escaping BOUSGetAprrovalAwardHistoryWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: BOUSGetAprrovalAwardHistoryWorkerRequestGenerator(nominationId: nominationId, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: BOUSGetAprrovalAwardHistoryDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class BOUSGetAprrovalAwardHistoryWorkerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var nominationId: Int
    
    init(nominationId: Int, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
        self.nominationId = nominationId
    }
    
    var apiRequest: URLRequest?{
        get{
            let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url:  self.urlBuilder.getURL(endpoint: "nominations/api/nominations_history/?nomination=\(nominationId)", parameters: nil
                ),
                method: .GET ,
                httpBodyDict: nil
            )
            return req
        }
    }
}

class BOUSGetAprrovalAwardHistoryDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = NSDictionary
    typealias ResultType = NSDictionary
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}




