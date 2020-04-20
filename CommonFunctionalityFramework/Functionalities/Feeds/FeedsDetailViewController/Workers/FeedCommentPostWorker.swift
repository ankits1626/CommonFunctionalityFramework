//
//  FeedCommentPostWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 09/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

typealias FeedCommentPostHandler = (APICallResult<[String : Any]>) -> Void

struct PostbaleComment {
    var feedId : Int64
    var commentText : String
    
    func getNetworkPostableFormat() -> [String : Any] {
        return ["content" : commentText]
    }
}

class FeedCommentPostWorker  {
    typealias ResultType = [String : Any]
    var commonAPICall : CommonAPICall<FeedCommentPostDataParser>?
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func postComment(comment:PostbaleComment, completionHandler: @escaping PostPublisherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedCommentPosRequestGenerator(
                    comment: comment,
                    networkRequestCoordinator: networkRequestCoordinator
                ),
                dataParser: FeedCommentPostDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class FeedCommentPosRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    private var comment:PostbaleComment
    private lazy var feedPostRequestBodyGenerator : PostRequestBodyGenerator = {
        return PostRequestBodyGenerator()
    }()
    init( comment:PostbaleComment, networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.comment = comment
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url: URL(string: "https://demo.flabulessdev.com/feeds/api/posts/\(comment.feedId)/comments/"),
                method: .POST,
                httpBodyDict: comment.getNetworkPostableFormat() as NSDictionary
            )
        }
    }
}

class FeedCommentPostDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = [String : Any]
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(result: fetchedData)
    }
}
