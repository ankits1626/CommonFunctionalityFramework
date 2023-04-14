//
//  GreetingsWishesFetcher.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 20/02/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation

typealias GreetingsWishesFetcherHandler = (APICallResult<FetchedFeedModel>) -> Void

class GreetingsWishesFetcher  {
    typealias ResultType = FetchedFeedModel
    var commonAPICall : CommonAPICall<GreetingsWishesFetcherDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    
    func fetchFeeds(greetingID: Int, nextPageUrl : String?, feedType: String?, searchText: String?,feedTypePk : Int = 0,organisationPK : Int = 0,departmentPK : Int = 0,dateRangePK : Int = 0,coreValuePk : Int = 0,isComingFromProfile : Bool = false, completionHandler: @escaping GreetingsWishesFetcherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: GreetingsWishesFetcherRequestGenerator(
                    feedID: nil,
                    nextPageUrl: nextPageUrl, feedType: feedType, searchText: searchText,
                    networkRequestCoordinator: networkRequestCoordinator,
                    _feedTypePk: feedTypePk,
                    _organisationPK: organisationPK,
                    _departmentPK: departmentPK,
                    _dateRangePK: dateRangePK,
                    _coreValuePk: coreValuePk,
                    _isComingFromProfile: isComingFromProfile, _greetingID: greetingID
                ),
                dataParser: GreetingsWishesFetcherDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
    
    func fetchFeedDetail(_ feedID: Int,feedType: String,feedTypePk : Int = 0,organisationPK : Int = 0,departmentPK : Int = 0,dateRangePK : Int = 0,coreValuePk : Int = 0,greetingID : Int = 0, completionHandler: @escaping GreetingsWishesFetcherHandler){
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: GreetingsWishesFetcherRequestGenerator(
                    feedID: feedID,
                    nextPageUrl: nil, feedType: feedType, searchText: nil,
                    networkRequestCoordinator: networkRequestCoordinator,
                    _feedTypePk: feedTypePk,
                    _organisationPK: organisationPK,
                    _departmentPK: departmentPK,
                    _dateRangePK: dateRangePK,
                    _coreValuePk: coreValuePk,
                    _isComingFromProfile: false, _greetingID: greetingID
                ),
                dataParser: GreetingsWishesFetcherDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class GreetingsWishesFetcherRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    private var nextPageUrl : String?
    private var feedID : Int?
    private var feedType : String?
    private var searchText : String?
    private var isComingFromProfile : Bool = false
    
    var feedTypePk : Int = 0
    var organisationPK : Int = 0
    var departmentPK : Int = 0
    var dateRangePK : Int = 0
    var coreValuePk : Int = 0
    var greetingID : Int = 0

    
    init( feedID: Int?, nextPageUrl : String?, feedType: String?, searchText: String?, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, _feedTypePk : Int, _organisationPK : Int, _departmentPK : Int, _dateRangePK : Int, _coreValuePk : Int, _isComingFromProfile : Bool, _greetingID :Int) {
         self.feedID = feedID
        self.nextPageUrl = nextPageUrl
        self.feedType = feedType
        self.searchText = searchText
        self.networkRequestCoordinator = networkRequestCoordinator
        self.feedTypePk = _feedTypePk
        self.organisationPK = _organisationPK
        self.departmentPK = _departmentPK
        self.dateRangePK = _dateRangePK
        self.coreValuePk = _coreValuePk
        self.isComingFromProfile = _isComingFromProfile
        self.greetingID = _greetingID
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            var url = "feeds/api/user_feed/"
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + "feeds/api/user_feed/organization_recognitions/?greeting=\(self.greetingID)"),
                        method: .GET,
                        httpBodyDict: nil
                    )
                    return req
                }
                return nil
            
//            else if let unwrappedNextPageUrl = nextPageUrl {
//                return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(url: URL(string: unwrappedNextPageUrl), method: .GET, httpBodyDict: nil)
//            }else{
//                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
//                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
//                        url: URL(string: baseUrl),
//                        method: .GET,
//                        httpBodyDict: nil
//                    )
//                    return req
//                }
//                return nil
//            }
        }
    }
}

class GreetingsWishesFetcherDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = [String : Any]
    typealias ResultType = FetchedFeedModel
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        return APICallResult.Success(
            result: FetchedFeedModel(
                fetchedRawFeeds: fetchedData,
                error: nil,
                nextPageUrl: fetchedData["next"] as? String
            )
        )
    }
}

