//
//  FeedFetcher.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

typealias FeedFetcherHandler = (APICallResult<FetchedFeedModel>) -> Void

class FeedFetcher  {
    typealias ResultType = FetchedFeedModel
    var commonAPICall : CommonAPICall<FeedFetchDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    
    func fetchFeeds(nextPageUrl : String?, feedType: String?, searchText: String?,feedTypePk : Int = 0,organisationPK : Int = 0,departmentPK : Int = 0,dateRangePK : Int = 0,coreValuePk : Int = 0, completionHandler: @escaping FeedFetcherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedFetchRequestGenerator(
                    feedID: nil,
                    nextPageUrl: nextPageUrl, feedType: feedType, searchText: searchText,
                    networkRequestCoordinator: networkRequestCoordinator,
                    _feedTypePk: feedTypePk,
                    _organisationPK: organisationPK,
                    _departmentPK: departmentPK,
                    _dateRangePK: dateRangePK,
                    _coreValuePk: coreValuePk
                ),
                dataParser: FeedFetchDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
    
    func fetchFeedDetail(_ feedID: Int,feedType: String,feedTypePk : Int = 0,organisationPK : Int = 0,departmentPK : Int = 0,dateRangePK : Int = 0,coreValuePk : Int = 0, completionHandler: @escaping FeedFetcherHandler){
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: FeedFetchRequestGenerator(
                    feedID: feedID,
                    nextPageUrl: nil, feedType: feedType, searchText: nil,
                    networkRequestCoordinator: networkRequestCoordinator,
                    _feedTypePk: feedTypePk,
                    _organisationPK: organisationPK,
                    _departmentPK: departmentPK,
                    _dateRangePK: dateRangePK,
                    _coreValuePk: coreValuePk
                ),
                dataParser: FeedFetchDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class FeedFetchRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    private var nextPageUrl : String?
    private var feedID : Int?
    private var feedType : String?
    private var searchText : String?
    
    var feedTypePk : Int = 0
    var organisationPK : Int = 0
    var departmentPK : Int = 0
    var dateRangePK : Int = 0
    var coreValuePk : Int = 0
    
    init( feedID: Int?, nextPageUrl : String?, feedType: String?, searchText: String?, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, _feedTypePk : Int, _organisationPK : Int, _departmentPK : Int, _dateRangePK : Int, _coreValuePk : Int) {
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
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            if let searchedText = searchText {
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + "feeds/api/user_feed/?search=\(searchedText)"),
                        method: .GET,
                        httpBodyDict: nil
                    )
                    return req
                }
                return nil
            }else if let unwrappedFeedId = feedID{
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + "feeds/api/user_feed/\(unwrappedFeedId)/"),
                        method: .GET,
                        httpBodyDict: nil
                    )
                    return req
                }
                return nil
            }
            else if let unwrappedNextPageUrl = nextPageUrl {
                return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(url: URL(string: unwrappedNextPageUrl), method: .GET, httpBodyDict: nil)
            }else{
                var endPoints = "feeds/api/user_feed/?feed=\(feedType!)"
                endPoints = appendFeedType(endPoints)
                endPoints = appendFeedOrg(endPoints)
                endPoints = appendFeedDepartment(endPoints)
                endPoints = appendFeedDateRange(endPoints)
                endPoints = appendFeedCoreValue(endPoints)
                
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + endPoints),
                        method: .GET,
                        httpBodyDict: nil
                    )
                    
                    print("here \(req)")
                    return req
                }
                return nil
            }
        }
    }
    
    private func appendFeedType(_ baseEndpoint : String) -> String{
        if self.feedTypePk != 0 {
            return "\(baseEndpoint)&post_type=\(self.feedTypePk)"
        }
        return baseEndpoint
    }
    
    private func appendFeedOrg(_ baseEndpoint : String) -> String{
        if self.organisationPK != 0 {
            return "\(baseEndpoint)&organization=\(self.organisationPK)"
        }
        return baseEndpoint
    }
    
    private func appendFeedDepartment(_ baseEndpoint : String) -> String{
        if self.departmentPK != 0 {
            return "\(baseEndpoint)&department=\(self.departmentPK)"
        }
        return baseEndpoint
    }
    
    private func appendFeedDateRange(_ baseEndpoint : String) -> String{
        if self.dateRangePK != 0 {
            return "\(baseEndpoint)&created_during=\(self.dateRangePK)"
        }
        return baseEndpoint
    }
    
    private func appendFeedCoreValue(_ baseEndpoint : String) -> String{
        if self.coreValuePk != 0 {
            return "\(baseEndpoint)&user_strength=\(self.coreValuePk)"
        }
        return baseEndpoint
    }
}

class FeedFetchDataParser: DataParserProtocol {
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
