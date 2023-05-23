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
    
    func fetchFeeds(nextPageUrl : String?, feedType: String?, searchText: String?,feedTypePk : Int = 0,organisationPK : Int = 0,departmentPK : Int = 0,dateRangePK : Int = 0,coreValuePk : Int = 0,isComingFromProfile : Bool = false,selectedTopGetterPk : Int = 0,  completionHandler: @escaping FeedFetcherHandler) {
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
                    _coreValuePk: coreValuePk,
                    _isComingFromProfile: isComingFromProfile,
                    _selectedFeedPk: selectedTopGetterPk
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
                    _coreValuePk: coreValuePk,
                    _isComingFromProfile: false
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
    private var isComingFromProfile : Bool = false

    var feedTypePk : Int = 0
    var organisationPK : Int = 0
    var departmentPK : Int = 0
    var dateRangePK : Int = 0
    var coreValuePk : Int = 0
    var selectedFeedPk : Int = 0
    
    init( feedID: Int?, nextPageUrl : String?, feedType: String?, searchText: String?, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, _feedTypePk : Int, _organisationPK : Int, _departmentPK : Int, _dateRangePK : Int, _coreValuePk : Int, _isComingFromProfile : Bool, _selectedFeedPk : Int = 0) {
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
        self.selectedFeedPk = _selectedFeedPk
        self.isComingFromProfile = _isComingFromProfile
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            var url = "feeds/api/user_feed/"
            if feedType == "SearchFromHome" {
                url = "feeds/api/user_feed/organization_recognitions/"
            }
            if feedType == "postPoll" {
                url = "feeds/api/user_feed/organization_recognitions/?post_polls=1"
            }
            if let searchedText = searchText {
                if let nextPage = nextPageUrl, !nextPage.isEmpty {
                    return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(url: URL(string: nextPage), method: .GET, httpBodyDict: nil)
                }else {
                    var endPoints = url
                    if feedType != "SearchFromHome" {
                        endPoints = appendFeedInputType(endPoints) + "&search=\(searchedText)"
                    }else {
                        endPoints = "\(endPoints)?search=\(searchedText)"
                    }
                    if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                        let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                            url: URL(string: baseUrl + endPoints),
                            method: .GET,
                            httpBodyDict: nil
                        )
                        return req
                    }
                    return nil
                }
            }else if let unwrappedFeedId = feedID{
                if let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
                    let req =  self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                        url: URL(string: baseUrl + "/feeds/api/posts/" + "\(unwrappedFeedId)/"),
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
                var endPoints = url
                if feedType == "received" || feedType == "given" {
                    endPoints = appendFeedInputType(endPoints)
                }
                endPoints = appendFeedType(endPoints)
                endPoints = appendFeedOrg(endPoints)
                endPoints = appendFeedDepartment(endPoints)
                endPoints = appendFeedDateRange(endPoints)
                endPoints = appendFeedCoreValue(endPoints)
                endPoints = appendTopGettersPk(endPoints)
                endPoints = appendTodayDate(endPoints)
                
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
    
    private func appendFeedInputType(_ baseEndpoint : String) -> String{
        if !(self.feedType?.isEmpty ?? true) {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&feed=\(self.feedType!)"
            }else{
                return "\(baseEndpoint)?feed=\(self.feedType!)"
            }
        }
        return baseEndpoint
    }
    
    private func appendFeedType(_ baseEndpoint : String) -> String{
        if self.feedTypePk != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&post_type=\(self.feedTypePk)"
            }else{
                return "\(baseEndpoint)?post_type=\(self.feedTypePk)"
            }
        }
        return baseEndpoint
    }
    
    private func appendFeedOrg(_ baseEndpoint : String) -> String{
        if self.organisationPK != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&organizations=\(self.organisationPK)"
            }else{
                return "\(baseEndpoint)?organizations=\(self.organisationPK)"
            }
        }
        return baseEndpoint
    }
    
    private func appendFeedDepartment(_ baseEndpoint : String) -> String{
        if self.departmentPK != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&department=\(self.departmentPK)"
            }else{
                return "\(baseEndpoint)?department=\(self.departmentPK)"
            }
        }
        return baseEndpoint
    }
    
    private func appendFeedDateRange(_ baseEndpoint : String) -> String{
        if self.dateRangePK != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&created_during=\(self.dateRangePK)"
            }else{
                return "\(baseEndpoint)?created_during=\(self.dateRangePK)"
            }
        }
        return baseEndpoint
    }
    
    private func appendFeedCoreValue(_ baseEndpoint : String) -> String{
        if self.coreValuePk != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&user_strength=\(self.coreValuePk)"
            }else{
                return "\(baseEndpoint)?user_strength=\(self.coreValuePk)"
            }
        }
        return baseEndpoint
    }
    
    private func appendTopGettersPk(_ baseEndpoint : String) -> String{
        if self.selectedFeedPk != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&user=\(self.selectedFeedPk)"
            }else{
                return "\(baseEndpoint)?user=\(self.selectedFeedPk)"
            }
        }
        return baseEndpoint
    }
    
    private func appendTodayDate(_ baseEndpoint : String) -> String{
        if self.selectedFeedPk != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&created_on_after=\(Date().startOfMonth().string(format: "yyyy-MM-dd"))"
            }else{
                return "\(baseEndpoint)?created_on_after=\(Date().startOfMonth().string(format: "yyyy-MM-dd"))"
            }
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
extension Date {
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension Date {
    
    var year:   Int { return Calendar(identifier: .gregorian).component(.year,   from: self as Date) }
    var month:  Int { return Calendar(identifier: .gregorian).component(.month,  from: self as Date) }
    var day:    Int { return Calendar(identifier: .gregorian).component(.day,    from: self as Date) }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
}
