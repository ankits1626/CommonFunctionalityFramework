////
////  SaveCertificateNetworkHandler.swift
////  CommonFunctionalityFramework
////
////  Created by Puneeeth on 01/04/23.
////  Copyright © 2023 Rewardz. All rights reserved.
////
//
import Foundation

typealias feedCertificateDownloadHandler = (APICallResult<[String : Any]>) -> Void

class feedCertificateDownload  {
    typealias ResultType = [String : Any]
    var commonAPICall : CommonAPICall<feedCertificateDownloadDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func downloadFeddCertificate(url: String, completionHandler: @escaping feedCertificateDownloadHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: feedCertificateDownloadRequestGenerator(url: url, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: feedCertificateDownloadDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class feedCertificateDownloadRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    private var url : String

    init(url : String, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.url = url
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url:  self.urlBuilder.getURL(endpoint: url, parameters: nil
                ),
                method: .GET ,
                httpBodyDict: nil
            )
            return req
        }
    }
}

class feedCertificateDownloadDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = [String : Any]

    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}
