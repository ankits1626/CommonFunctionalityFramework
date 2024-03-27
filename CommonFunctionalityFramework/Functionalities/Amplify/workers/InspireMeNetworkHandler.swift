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
    
    func getInspireMe(model: AmplifyRequestHelperProtocol, language: String, isRequestJson : Bool,editToneData : [String : Any], completionHandler: @escaping InspireMeFormWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider:  InspireMeFormWorkerRequestGenerator(
                    model: model,
                    language: language,
                    networkRequestCoordinator: networkRequestCoordinator, 
                    requestJson: isRequestJson,
                    _editToneData: editToneData
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
    var requestJson : Bool = true
    var model: AmplifyRequestHelperProtocol
    var editToneData : [String : Any]

    var sandBoxInspireMeURL = "https://sandbox-api.inspireme.ai/b2b/api/v1.1/lan/generate-ai"
//    var sandBoxInspireEditToneURL = "https://sandbox-api.inspireme.ai/b2b/api/v1.1/lan/generate-ai/edit-tone"
    var productionInspireMeURL = "https://api.inspireme.ai/b2b/api/v1.1/lan/generate-ai"
//    var productionInspireEditToneURL = "https://api.inspireme.ai/b2b/api/v1.1/lan/generate-ai/edit-employee-recognition-tone"
    let serverUrl = UserDefaults.standard.value(forKey: "base_url_for_image_height") as? String ?? ""
    
    init(model: AmplifyRequestHelperProtocol, language: String, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, requestJson : Bool, _editToneData : [String : Any]) {
        self.model = model
        self.language = language
        self.editToneData = _editToneData
        self.requestJson = requestJson
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            let urlStr = String(format: "%@%@", serverUrl, model.endPoint)
            let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url:  URL(string: urlStr),
                method: .POST ,
                httpBodyDict: prepareHttpBodyDict() as NSDictionary
            )
            return req
        }
    }
    
    private func prepareHttpBodyDict() -> NSDictionary{
        if self.editToneData.count > 0 {
            return NSDictionary(dictionary: self.editToneData)
        }
        var mutableBodyDict = model.requestParamas //NSMutableDictionary()
        if mutableBodyDict["messageTone"] == nil{
            mutableBodyDict["messageTone"] = "One paragraph casual tone"
        }
        mutableBodyDict["language"] = language
        if requestJson {
            mutableBodyDict["formatResponse"] = "json"
        }
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
