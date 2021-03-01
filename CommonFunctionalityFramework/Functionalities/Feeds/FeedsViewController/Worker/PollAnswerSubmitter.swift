//
//  PollAnswerSubmitter.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

typealias PollAnswerSubmitterHandler = (APICallResult<RawFeed>) -> Void

class PollAnswerSubmitter  {
    typealias ResultType = RawFeed
    var commonAPICall : CommonAPICall<PollAnswerSubmitDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    private let feedIdentifier : Int64
    private let answer: PollOption
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, feedIdentifier : Int64, answer: PollOption) {
        self.networkRequestCoordinator = networkRequestCoordinator
        self.feedIdentifier = feedIdentifier
        self.answer = answer
    }
    func submitAnswer(completionHandler: @escaping PollAnswerSubmitterHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: PollAnswerSubmitRequestGenerator(
                    feedIdentifier: feedIdentifier,
                    answer: answer,
                    networkRequestCoordinator: networkRequestCoordinator
                ),
                dataParser: PollAnswerSubmitDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class PollAnswerSubmitRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var feedIdentifier : Int64
    var answer: PollOption
    init( feedIdentifier : Int64, answer: PollOption, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.feedIdentifier = feedIdentifier
        self.answer = answer
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            //URL(string: "https://demo.flabulessdev.com/feeds/api/posts/\(feedIdentifier)/appreciate/")!
            if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: baseUrl + "feeds/api/posts/\(feedIdentifier)/vote/"),
                    method: .POST,
                    httpBodyDict: answer.getNewtowrkPostableAnswer() as NSDictionary
                )
                return req
            }
            return nil
        }
    }
}

class PollAnswerSubmitDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = RawFeed
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: RawFeed(input: fetchedData))
    }
}
