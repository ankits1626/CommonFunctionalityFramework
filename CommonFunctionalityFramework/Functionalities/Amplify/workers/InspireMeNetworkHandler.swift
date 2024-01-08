//
//  InspireMeNetworkHandler.swift
//  SKOR
//
//  Created by Puneeeth on 31/01/23.
//  Copyright © 2023 Rewradz Private Limited. All rights reserved.
//

import Foundation

typealias  InspireMeFormWorkerCompletionHandler = (APICallResult<NSDictionary>) -> Void
class  InspireMeFormWorker  {
    typealias ResultType = NSDictionary
    var commonAPICall : CommonAPICall<InspireMeFormDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    
    func getInspireMe(model: AmplifyRequestHelperProtocol, language: String, completionHandler: @escaping InspireMeFormWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider:  InspireMeFormWorkerRequestGenerator(
                    model: model,
                    language: language,
                    networkRequestCoordinator: networkRequestCoordinator
                ),
                dataParser: InspireMeFormDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
    
}

class  InspireMeFormWorkerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    var language = ""
    var model: AmplifyRequestHelperProtocol

    var sandBoxInspireMeURL = "https://sandbox-api.inspireme.ai/b2b/api/v1.1/lan/generate-ai"
//    var sandBoxInspireEditToneURL = "https://sandbox-api.inspireme.ai/b2b/api/v1.1/lan/generate-ai/edit-tone"
    var productionInspireMeURL = UserDefaults.standard.value(forKey: "base_url_for_image_height") as? String ?? ""
//    var productionInspireEditToneURL = "https://api.inspireme.ai/b2b/api/v1.1/lan/generate-ai/edit-employee-recognition-tone"
    
    init(model: AmplifyRequestHelperProtocol, language: String, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.model = model
        self.language = language
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            let urlStr = String(format: "%@/%@", productionInspireMeURL, model.endPoint)
            let req = self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url:  URL(string: urlStr),
                method: .POST ,
                httpBodyDict: prepareHttpBodyDict() as NSDictionary
            )
            return req
        }
    }
    
    private func prepareHttpBodyDict() -> NSDictionary{
        var mutableBodyDict = model.requestParamas //NSMutableDictionary()
        if mutableBodyDict["messageTone"] == nil{
            mutableBodyDict["messageTone"] = "One paragraph casual tone"
        }
        mutableBodyDict["language"] = language
        return NSDictionary(dictionary: mutableBodyDict)
    }
    
}

class InspireMeFormDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = NSDictionary
    typealias ResultType = NSDictionary
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}
