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
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func postComment(comment:PostbaleComment,isPostEditing : Bool,commentID : Int64, completionHandler: @escaping PostPublisherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedCommentPosRequestGenerator(
                    comment: comment,
                    networkRequestCoordinator: networkRequestCoordinator,
                    _isEditingComment: isPostEditing,
                    _commentID: commentID
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
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    private var comment:PostbaleComment
    private lazy var feedPostRequestBodyGenerator : PostRequestBodyGenerator = {
        return PostRequestBodyGenerator()
    }()
    var isEditingComment : Bool
    var commentID : Int64
    init( comment:PostbaleComment, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, _isEditingComment : Bool, _commentID : Int64) {
        self.comment = comment
        self.isEditingComment = _isEditingComment
        self.commentID = _commentID
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            if self.isEditingComment {
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + "/feeds/api/comments/\(self.commentID)/"),
                        method: .PATCH,
                        httpBodyDict: comment.getNetworkPostableFormat() as NSDictionary
                    )
                    return req
                }
                return nil
            }else{
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + "feeds/api/posts/\(comment.feedId)/comments/"),
                        method: .POST,
                        httpBodyDict: comment.getNetworkPostableFormat() as NSDictionary
                    )
                    return req
                }
                return nil
            }
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
