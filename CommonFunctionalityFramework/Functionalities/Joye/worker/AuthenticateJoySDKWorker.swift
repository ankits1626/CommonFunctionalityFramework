//
//  AuthenticateJoySDKWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 20/08/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation

typealias AuthenticateJoySDKWorkerHandler = (APICallResult<JoySdkDataModel>) -> Void
class AuthenticateJoySDKWorker  {
    typealias ResultType = JoySdkDataModel
    var commonAPICall : CommonAPICall<AuthenticateJoyDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func postBulkStepData(orgRequestBody : [String : String],completionHandler: @escaping AuthenticateJoySDKWorkerHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: AuthenticateJoySDKDataRequestGenerator(
                    _orgData: orgRequestBody,
                    networkRequestCoordinator: networkRequestCoordinator
                ),
                dataParser: AuthenticateJoyDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<JoySdkDataModel>) in
            completionHandler(result)
        })
    }
}

class AuthenticateJoySDKDataRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var orgData : [String : String]
    init(_orgData : [String : String], networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.orgData = _orgData
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var stepData = Data()
    var apiRequest: URLRequest?{
        
        get{
            return self.requestBuilder.apiRequestWithSubscriptionInAuthorizationHeader(url: URL(string: UserDefaults.standard.value(forKey: "joyeUrl") as? String ?? ""),
                                                                                       method: .POST , httpBodyDict: self.orgData as NSDictionary,
                                                                                       opmKey: UserDefaults.standard.value(forKey: "joyeKey") as? String ?? "")
        }
    }
}
class AuthenticateJoyDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = NSDictionary
    typealias ResultType = JoySdkDataModel
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        let id = fetchedData.object(forKey: "id") as? String ?? ""
        let url = fetchedData.object(forKey: "url") as? String ?? ""
        let data = JoySdkDataModel(_id: id, _url: url)
        return APICallResult.Success(result: data)
    }
    
}



struct JoySdkDataModel {
    var id : String
    var url : String
    
    init(_id : String, _url : String) {
        self.id = _id
        self.url = _url
    }
}
