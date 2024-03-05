//
//  FeedFetcher.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

struct FeedFetcherInputModel{
    var userPk: Int?
    var feedID: Int?
    var nextPageUrl : String?
    var feedType: String?
    var searchText: String?
    var feedTypePk : Int = 0
    var organisationPK : Int = 0
    var departmentPK : Int = 0
    var dateRangePK : Int = 0
    var coreValuePk : Int = 0
    var isComingFromProfile : Bool = false
    var selectedTopGetterPk : Int = 0
    var selectedFeedPk : Int = 0
    
    init(feedID : Int, feedType : String) {
        self.feedID = feedID
        self.feedType = feedType
    }
    
    init(
        userPk: Int,
        nextPageUrl : String?,
        feedType: String,
        searchText: String?,
        feedTypePk : Int,
        organisationPK : Int,
        departmentPK : Int,
        dateRangePK : Int,
        coreValuePk : Int,
        selectedTopGetterPk : Int
    ){
        self.userPk = userPk
        self.nextPageUrl = nextPageUrl
        self.feedType = feedType
        self.searchText = searchText
        self.feedTypePk = feedTypePk
        self.organisationPK = organisationPK
        self.departmentPK = departmentPK
        self.dateRangePK = dateRangePK
        self.coreValuePk = coreValuePk
        self.selectedTopGetterPk = selectedTopGetterPk
    }
    
    init(
        userPk: Int,
        nextPageUrl : String?,
        feedType: String,
        searchText: String?,
        feedTypePk : Int,
        organisationPK : Int,
        departmentPK : Int,
        dateRangePK : Int,
        coreValuePk : Int,
        isComingFromProfile : Bool
    ){
        self.userPk = userPk
        self.nextPageUrl = nextPageUrl
        self.feedType = feedType
        self.searchText = searchText
        self.feedTypePk = feedTypePk
        self.organisationPK = organisationPK
        self.departmentPK = departmentPK
        self.dateRangePK = dateRangePK
        self.coreValuePk = coreValuePk
        self.isComingFromProfile = isComingFromProfile
    }
}

typealias FeedFetcherHandler = (APICallResult<FetchedFeedModel>) -> Void

class FeedFetcher  {
    typealias ResultType = FetchedFeedModel
    var commonAPICall : CommonAPICall<FeedFetchDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    
    /*
     func fetchFeeds(nextPageUrl : String?, feedType: String?, searchText: String?,feedTypePk : Int = 0,organisationPK : Int = 0,departmentPK : Int = 0,dateRangePK : Int = 0,coreValuePk : Int = 0,isComingFromProfile : Bool = false,selectedTopGetterPk : Int = 0,  completionHandler: @escaping FeedFetcherHandler)
     */
    func fetchFeeds(_ input: FeedFetcherInputModel, completionHandler: @escaping FeedFetcherHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                /*apiRequestProvider: FeedFetchRequestGenerator(
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
                )*/
                
                apiRequestProvider: FeedFetchRequestGenerator(
                    input,
                    networkRequestCoordinator: networkRequestCoordinator
                ),
                dataParser: FeedFetchDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
    
    /*func fetchFeedDetail(_ feedID: Int,feedType: String,feedTypePk : Int = 0,organisationPK : Int = 0,departmentPK : Int = 0,dateRangePK : Int = 0,coreValuePk : Int = 0, completionHandler: @escaping FeedFetcherHandler)*/
    
    func fetchFeedDetail(_ input: FeedFetcherInputModel, completionHandler: @escaping FeedFetcherHandler){
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                /*apiRequestProvider: FeedFetchRequestGenerator(
                    feedID: feedID,
                    nextPageUrl: nil, feedType: feedType, searchText: nil,
                    
                    _feedTypePk: feedTypePk,
                    _organisationPK: organisationPK,
                    _departmentPK: departmentPK,
                    _dateRangePK: dateRangePK,
                    _coreValuePk: coreValuePk,
                    _isComingFromProfile: false
                )*/
                apiRequestProvider: FeedFetchRequestGenerator(
                    input,
                    networkRequestCoordinator: networkRequestCoordinator
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
    
    /*
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
    */
    /*init(
     feedID: Int?,
     nextPageUrl : String?,
     feedType: String?,
     searchText: String?,
     networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol,
     _feedTypePk : Int,
     _organisationPK : Int,
     _departmentPK : Int,
     _dateRangePK : Int,
     _coreValuePk : Int,
     _isComingFromProfile : Bool,
     _selectedFeedPk : Int = 0)*/
    
    let input: FeedFetcherInputModel
    
    init( _ input:  FeedFetcherInputModel, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.input  = input
        self.networkRequestCoordinator = networkRequestCoordinator
        /*self.feedID = input.feedID
        self.nextPageUrl = input.nextPageUrl
        self.feedType = input.feedType
        self.searchText = input.searchText
        
        self.feedTypePk = input.feedTypePk
        self.organisationPK = input.organisationPK
        self.departmentPK = input.departmentPK
        self.dateRangePK = input.dateRangePK
        self.coreValuePk = input.coreValuePk
        self.selectedFeedPk = input.selectedFeedPk
        self.isComingFromProfile = input.isComingFromProfile*/
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            var url = "feeds/api/user_feed/"
            if input.feedType == "SearchFromHome" {
                url = "feeds/api/user_feed/organization_recognitions/"
            }
            if input.feedType == "postPoll" {
                url = "feeds/api/user_feed/organization_recognitions/?post_polls=1"
            }
            if input.feedType == "isFromUserPostPoll" {
                url = "/feeds/api/user_feed/?feed=post_polls"
            }
            if let searchedText = input.searchText {
                if let nextPage = input.nextPageUrl, !nextPage.isEmpty {
                    return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(url: URL(string: nextPage), method: .GET, httpBodyDict: nil)
                }else {
                    var endPoints = url
                    if input.feedType != "SearchFromHome" {
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
            }else if let unwrappedFeedId = input.feedID{
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
            else if let unwrappedNextPageUrl = input.nextPageUrl {
                return self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(url: URL(string: unwrappedNextPageUrl), method: .GET, httpBodyDict: nil)
            }else{
                var endPoints = url
                if input.feedType == "received" || input.feedType == "given" {
                    endPoints = appendFeedInputType(endPoints)
                }
                endPoints = appendFeedType(endPoints)
                endPoints = appendFeedOrg(endPoints)
                endPoints = appendFeedDepartment(endPoints)
                endPoints = appendFeedDateRange(endPoints)
                endPoints = appendFeedCoreValue(endPoints)
                endPoints = appendTopGettersPk(endPoints)
                endPoints = appendUserId(endPoints)
                
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
    
    private func appendUserId(_ baseEndpoint : String) -> String{
        if let unwrappedUserpk = input.userPk{
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&user_id=\(unwrappedUserpk)"
            }else{
                return "\(baseEndpoint)?user_id=\(unwrappedUserpk)"
            }
        }
        return baseEndpoint
    }
    
    private func appendFeedInputType(_ baseEndpoint : String) -> String{
        if !(input.feedType?.isEmpty ?? true) {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&feed=\(input.feedType!)"
            }else{
                return "\(baseEndpoint)?feed=\(input.feedType!)"
            }
        }
        return baseEndpoint
    }
    
    private func appendFeedType(_ baseEndpoint : String) -> String{
        if input.feedTypePk != 0 {
            if input.feedType == "postPoll" {
                if baseEndpoint.contains("?") {
                   if input.feedTypePk == 1 {
                       return "\(baseEndpoint)&post_polls_filter=post"
                   }else {
                       return "\(baseEndpoint)&post_polls_filter=poll"
                   }
               }else{
                   if input.feedTypePk == 1 {
                       return "\(baseEndpoint)?post_polls_filter=post"
                   }else {
                       return "\(baseEndpoint)?post_polls_filter=poll"
                   }
               }
            }else {
                if baseEndpoint.contains("?") {
                    return "\(baseEndpoint)&post_type=\(input.feedTypePk)"
                }else{
                    return "\(baseEndpoint)?post_type=\(input.feedTypePk)"
                }
            }
        }
        return baseEndpoint
    }
    
    private func appendFeedOrg(_ baseEndpoint : String) -> String{
        if input.organisationPK != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&organizations=\(input.organisationPK)"
            }else{
                return "\(baseEndpoint)?organizations=\(input.organisationPK)"
            }
        }
        return baseEndpoint
    }
    
    private func appendFeedDepartment(_ baseEndpoint : String) -> String{
        if input.departmentPK != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&department=\(input.departmentPK)"
            }else{
                return "\(baseEndpoint)?department=\(input.departmentPK)"
            }
        }
        return baseEndpoint
    }
    
    private func appendFeedDateRange(_ baseEndpoint : String) -> String{
        if input.dateRangePK != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&created_during=\(input.dateRangePK)"
            }else{
                return "\(baseEndpoint)?created_during=\(input.dateRangePK)"
            }
        }
        return baseEndpoint
    }
    
    private func appendFeedCoreValue(_ baseEndpoint : String) -> String{
        if input.coreValuePk != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&user_strength=\(input.coreValuePk)"
            }else{
                return "\(baseEndpoint)?user_strength=\(input.coreValuePk)"
            }
        }
        return baseEndpoint
    }
    
    private func appendTopGettersPk(_ baseEndpoint : String) -> String{
        if input.selectedFeedPk != 0 {
            if baseEndpoint.contains("?") {
                return "\(baseEndpoint)&user_id=\(input.selectedFeedPk)"
            }else{
                return "\(baseEndpoint)?user_id=\(input.selectedFeedPk)"
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
