//
//  TopMonthlyHeroesWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 30/03/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation

typealias TopHeroesDataHandler = (APICallResult<(fetchedHeroes:[TopRecognitionHero], slug: String, userRemainingPoints : Double, userMonthlyAppreciationLimit : Int)>) -> Void
class TopMonthlyHeroesWorker  {
    typealias ResultType = (fetchedHeroes:[TopRecognitionHero], slug: String, userRemainingPoints : Double, userMonthlyAppreciationLimit : Int)
    var commonAPICall : CommonAPICall<TopHeroesDataParser>?
    private var slug : String
    private var recognitionType : String
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(_ slug : String,networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, _recognitionType : String) {
        self.slug = slug
        self.networkRequestCoordinator = networkRequestCoordinator
        self.recognitionType = _recognitionType
    }

    func fetchHeroes(completionHandler: @escaping TopHeroesDataHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: TopHeroesFetcherRequestGenerator(slug,networkRequestCoordinator: networkRequestCoordinator, _recognitionType: recognitionType),
                dataParser: TopHeroesDataParser(slug: slug, _recognitionType: recognitionType),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class TopHeroesFetcherRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    private var slug : String
    private var recognitionType : String
    init(_ slug : String,networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, _recognitionType : String) {
        self.slug = slug
        self.recognitionType = _recognitionType
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url: self.urlBuilder.getURL(
                    endpoint: "profiles/api/recognition-heros/?type=\(slug)&recognition_type=\(self.recognitionType)",
                    parameters: nil
                ),
                method: .GET ,
                httpBodyDict: nil
            )
            return req
        }
    }
}




class TopHeroesDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = (fetchedHeroes:[TopRecognitionHero], slug: String, userRemainingPoints : Double, userMonthlyAppreciationLimit : Int)
    
    private let slug: String
    private var recognitionType : String
    
    init(slug: String, _recognitionType : String) {
        self.slug = slug
        self.recognitionType = _recognitionType
    }
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        var items = [TopRecognitionHero]()
        if let rawHeroes = fetchedData["users"] as? [[String : Any]]{
            for aHero in rawHeroes{
                var hero = TopRecognitionHero(aHero, recognitionTye: self.recognitionType)
              hero.category = fetchedData["name"] as! String
                items.append(TopRecognitionHero(aHero, recognitionTye: self.recognitionType))
            }
            let remainingPoints = fetchedData["remaining_points"] as? Double ?? 0
            let monthlyAppreciationLimit = fetchedData["monthly_appreciation_left_count"] as? Int ?? 0
            let result : ResultType = (fetchedHeroes: items, slug:slug,userRemainingPoints : remainingPoints, userMonthlyAppreciationLimit :  monthlyAppreciationLimit)
            return APICallResult.Success(result: result)
            
        }else{
            return APICallResult.Failure(error: APIError.UnexpectedResult)
        }
        
    }
}

