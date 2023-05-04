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
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(_ slug : String,networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.slug = slug
        self.networkRequestCoordinator = networkRequestCoordinator
    }

    func fetchHeroes(completionHandler: @escaping TopHeroesDataHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: TopHeroesFetcherRequestGenerator(slug,networkRequestCoordinator: networkRequestCoordinator),
                dataParser: TopHeroesDataParser(slug: slug),
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
    init(_ slug : String,networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.slug = slug
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    var apiRequest: URLRequest?{
        get{
            let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url: self.urlBuilder.getURL(
                    endpoint: "profiles/api/recognition-heros/?type=\(slug)",
                    parameters: nil
                ),
                method: .GET ,
                httpBodyDict: nil
            )
            print("<<<<<<<<<<<<<<<<< \(req?.url)")
            return req
        }
    }
}




class TopHeroesDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = (fetchedHeroes:[TopRecognitionHero], slug: String, userRemainingPoints : Double, userMonthlyAppreciationLimit : Int)
    
    private let slug: String
    
    init(slug: String) {
        self.slug = slug
    }
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        var items = [TopRecognitionHero]()
        if let rawHeroes = fetchedData["users"] as? [[String : Any]]{
            for aHero in rawHeroes{
              var hero = TopRecognitionHero(aHero)
              hero.category = fetchedData["name"] as! String
                items.append(TopRecognitionHero(aHero))
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

