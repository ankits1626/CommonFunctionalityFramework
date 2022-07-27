//
//  GetBOUSNominationWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

typealias GetBOUSNominationWorkerCompletionHandler = (APICallResult<NSDictionary>) -> Void

class GetBOUSNominationWorker  {
    typealias ResultType = NSDictionary
    var commonAPICall : CommonAPICall<GetBOUSNominationWorkerDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func getNominationList(statusType: String, nextUrl: String, completionHandler: @escaping GetBOUSNominationWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: GetBOUSNominationWorkerRequestGenerator(_statusType: statusType, _nextUrl: nextUrl, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: GetBOUSNominationWorkerDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class GetBOUSNominationWorkerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var statusType : String
    var nextUrl: String
    
    init(_statusType: String, _nextUrl: String, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.statusType = _statusType
        self.nextUrl = _nextUrl
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            if nextUrl.isEmpty {
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url:  self.urlBuilder.getURL(endpoint: "feeds/api/user_feed/?feed=my_nomination&post_type=7&nom_status=\(statusType)", parameters: nil
                    ),
                    method: .GET ,
                    httpBodyDict: nil
                )
                return req
            }else {
                return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: nextUrl),
                    method: .GET ,
                    httpBodyDict: nil
                )
            }
        }
    }
}

class GetBOUSNominationWorkerDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = NSDictionary
    typealias ResultType = NSDictionary
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}




