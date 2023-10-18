//
//  BOUSNominationAppoveRejectWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//


import Foundation
typealias BOUSNominationAppoveRejectWorkerResultHandler = (APICallResult<Any?>) -> Void

class BOUSNominationAppoveRejectWorker  {
    typealias ResultType = Any?
    var commonAPICall : CommonAPICall<ReportAbuseDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func postnomination(postId: Int, multipleNominations: String?, message: String?,approvalStatus: String,selectedPrivacyvalue : Int,
                        badgeId: Int, points : String,  completionHandler: @escaping BOUSNominationAppoveRejectWorkerResultHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: BOUSNominationAppoveRejectRequestGenerator(feedIdentifier: postId, message: message, multipleNominations: multipleNominations, approvalStatus: approvalStatus, selectedPrivacyvalue: selectedPrivacyvalue, badgeId: badgeId,points: points,networkRequestCoordinator: networkRequestCoordinator),
                dataParser: ReportAbuseDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class BOUSNominationAppoveRejectRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var feedIdentifier : Int
    var message: String?
    var approvalStatus : String
    var multipleNominations: String?
    var selectedPrivacyvalue : Int
    var badgeId: Int
    var points : String
    init(feedIdentifier: Int, message: String?,multipleNominations: String?, approvalStatus: String, selectedPrivacyvalue : Int,
         badgeId: Int, points : String, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.feedIdentifier = feedIdentifier
        self.message = message
        self.approvalStatus = approvalStatus
        self.networkRequestCoordinator = networkRequestCoordinator
        self.multipleNominations = multipleNominations
        self.badgeId = badgeId
        self.points = points
        self.selectedPrivacyvalue = selectedPrivacyvalue
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                
                if let multipleNom = multipleNominations, !multipleNom.isEmpty {
                        let req =  self.requestBuilder.apiRequestWithMultiPartFormHeader(
                            url: URL(string: baseUrl + "nominations/api/nominations/\(feedIdentifier)/update_status/?appreciation=1&nominations=\(multipleNom)"),
                            method: .POST,
                            httpBodyString: self.prepareHttpForMultipleNominationBody()
                        )
                        return req
                }else {
                    let req =  self.requestBuilder.apiRequestWithMultiPartFormHeader(
                        url: URL(string: baseUrl + "nominations/api/nominations/\(feedIdentifier)/update_status/"),
                        method: .POST,
                        httpBodyString: self.prepareHttpBody()
                    )
                    return req
                }
      
            }
            return nil
        }
    }
    
    private func prepareHttpBody() -> String{
        var params = ""
        params = "comment=\(message ?? "")&approval_status=\(approvalStatus)&shared_with=\(selectedPrivacyvalue)&badge=\(self.badgeId)&points=\(self.points)" as String
        return params
    }
    
    private func prepareHttpForMultipleNominationBody() -> String{
        var params = ""
        params = "comment=\(message ?? "")&approval_status=\(approvalStatus)" as String
        return params
    }
}

class BOUSNominationAppoveRejectDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = Any?
    typealias ResultType = Any?
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return .Success(result: nil)
    }
}

