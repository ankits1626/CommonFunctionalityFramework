//
//  FeedEcardCategoryWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 12/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import CommonFunctionalityFramework

typealias GetEcardCategoryFormWorkerCompletionHandler = (APICallResult<NSDictionary>) -> Void
class GetEcardCategoryFormWorker  {
    typealias ResultType = NSDictionary
    var commonAPICall : CommonAPICall<GetEcardCategoryFormDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func getGetEcardCategory(completionHandler: @escaping GetEcardCategoryFormWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: GetEcardCategoryFormWorkerRequestGenerator(networkRequestCoordinator: networkRequestCoordinator),
                dataParser: GetEcardCategoryFormDataParser(), logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class GetEcardCategoryFormWorkerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url:  self.urlBuilder.getURL(endpoint: "/feeds/api/ecard_category/", parameters: nil),
                method: .GET ,
                httpBodyDict: nil
            )
        }
    }
}

class GetEcardCategoryFormDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = NSDictionary
    typealias ResultType = NSDictionary
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}

