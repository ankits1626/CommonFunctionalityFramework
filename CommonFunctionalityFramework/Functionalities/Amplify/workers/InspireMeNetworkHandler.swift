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
    
    func getInspireMe(model: AmplifyRequestHelperProtocol, messageTone: String, language: String, completionHandler: @escaping InspireMeFormWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider:  InspireMeFormWorkerRequestGenerator(model: model,
                    messageTone: messageTone,
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
    var messageTone = ""
    var language = ""
    var model: AmplifyRequestHelperProtocol

    var sandBoxInspireMeURL = "https://sandbox-api.inspireme.ai/b2b/api/v1.1/lan/generate-ai"
//    var sandBoxInspireEditToneURL = "https://sandbox-api.inspireme.ai/b2b/api/v1.1/lan/generate-ai/edit-tone"
    var productionInspireMeURL = "https://api.inspireme.ai/b2b/api/v1.1/lan/generate-ai"
//    var productionInspireEditToneURL = "https://api.inspireme.ai/b2b/api/v1.1/lan/generate-ai/edit-employee-recognition-tone"
    
    init(model: AmplifyRequestHelperProtocol, messageTone: String, language: String, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.model = model
        self.messageTone = messageTone
        self.language = language
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            let urlStr = String(format: "%@/%@", productionInspireMeURL, model.endPoint)
            if messageTone == "One paragraph casual tone" {
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParamsForInspireMe(
                    url:  URL(string: urlStr),
                    method: .POST ,
                    httpBodyDict: prepareHttpBodyDict() as NSDictionary
                )
                return req
            } else {
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParamsForInspireMe(
                    url:  URL(string: urlStr),
                    method: .POST ,
                    httpBodyDict: prepareMessageToneHttpBodyDict() as NSDictionary
                )
                return req
            }
        }
    }
    
    private func prepareHttpBodyDict() -> NSDictionary{
        var mutableBodyDict = model.requestParamas //NSMutableDictionary()
//        mutableBodyDict.setValue(coreValue, forKey: "companyCoreValue")
        mutableBodyDict["messageTone"] = messageTone //.setValue(messageTone, forKey: "messageTone")
        mutableBodyDict["language"] = language
//        mutableBodyDict.setValue(userText, forKey: "userInputText")
//        mutableBodyDict.setValue(language, forKey: "language")
        return NSDictionary(dictionary: mutableBodyDict)
    }
    
    private func prepareMessageToneHttpBodyDict() -> NSDictionary{
        var mutableBodyDict = model.requestParamas // NSMutableDictionary()
        mutableBodyDict["messageTone"] = messageTone
        mutableBodyDict["language"] = language
//        mutableBodyDict["language"] = language
//        mutableBodyDict.setValue(messageTone, forKey: "messageTone")
//        mutableBodyDict.setValue(userText, forKey: "textToEdit")
//        mutableBodyDict.setValue(language, forKey: "language")
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
