//
//  PostPublisher.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

typealias PostPublisherHandler = (APICallResult<[String : Any]>) -> Void

class PostPublisher  {
    typealias ResultType = [String : Any]
    var commonAPICall : CommonAPICall<PostPublisherDataParser>?
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func publisPost(post: EditablePostProtocol, completionHandler: @escaping PostPublisherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: PostPublisherRequestGenerator(post: post, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: PostPublisherDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class PostPublisherRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    var post : EditablePostProtocol
    init( post: EditablePostProtocol, networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.post = post
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            switch post.postType {
            case .Poll:
                return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                    url: URL(string: "https://demo.flabulessdev.com/feeds/api/posts/create_poll/"),
                    method: .POST,
                    httpBodyDict: post.getNetworkPostableFormat() as NSDictionary
                )
            case .Post:
                return nil
            }
        }
    }
}

class PostPublisherDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = [String : Any]
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}
