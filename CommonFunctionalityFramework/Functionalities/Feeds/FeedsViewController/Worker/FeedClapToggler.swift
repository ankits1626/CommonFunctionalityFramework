//
//  FeedClapToggler.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 22/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

protocol Likeable {
    func getLikeToggleUrl() -> URL
}

struct LikeToggleResult {
    var isLiked : Bool
    var totalLikeCount : Int64
}

typealias FeedClapTogglerResultHandler = (APICallResult<LikeToggleResult>) -> Void

class FeedClapToggler  {
    typealias ResultType = LikeToggleResult
    var commonAPICall : CommonAPICall<FeedClapTogglerDataParser>?
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func toggleLike(_ input : Likeable,completionHandler: @escaping FeedClapTogglerResultHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedClapTogglerRequestGenerator(likeableElement: input, networkRequestCoordinator: networkRequestCoordinator),
                dataParser: FeedClapTogglerDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class FeedClapTogglerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    var likeableElement : Likeable
    init( likeableElement : Likeable, networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.likeableElement = likeableElement
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url: likeableElement.getLikeToggleUrl(),
                method: .POST,
                httpBodyDict: nil
            )
            return req
        }
    }
}

class FeedClapTogglerDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = LikeToggleResult
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        if let likedState = fetchedData["liked"] as? Bool,
            let count = fetchedData["count"] as? Int64{
            return .Success(result: LikeToggleResult(isLiked: likedState, totalLikeCount: count))
        }else{
            return .Failure(error: APIError.Others("Unexpected response"))
        }
    }
}
