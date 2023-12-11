//
//  ApprovalAwardCategoryWorker.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 25/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

typealias ApprovalAwardCategoryWorkerCompletionHandler = (APICallResult<[ApprovalAwardCategoryModel]>) -> Void

class ApprovalAwardCategoryWorker  {
    typealias ResultType = [ApprovalAwardCategoryModel]
    var commonAPICall : CommonAPICall<ApprovalAwardCategoryDataParser>?
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
        self.networkRequestCoordinator = networkRequestCoordinator
    }
    func getApproverAwardCategory(completionHandler: @escaping ApprovalAwardCategoryWorkerCompletionHandler) {
        if (commonAPICall == nil){
            self.commonAPICall = CommonAPICall(
                apiRequestProvider: ApprovalAwardCategoryWorkerRequestGenerator(networkRequestCoordinator: networkRequestCoordinator),
                dataParser: ApprovalAwardCategoryDataParser(),
                logouthandler: networkRequestCoordinator.getLogoutHandler()
            )
        }
        commonAPICall?.callAPI(completionHandler: { (result : APICallResult<ResultType>) in
            completionHandler(result)
        })
    }
}

class ApprovalAwardCategoryWorkerRequestGenerator: APIRequestGeneratorProtocol  {
    var urlBuilder: ParameterizedURLBuilder
    var requestBuilder: APIRequestBuilderProtocol
    private let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    
    init(networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) {
       
        self.networkRequestCoordinator = networkRequestCoordinator
        urlBuilder = ParameterizedURLBuilder(baseURLProvider: networkRequestCoordinator.getBaseUrlProvider())
        requestBuilder = APIRequestBuilder(tokenProvider: networkRequestCoordinator.getTokenProvider())
    }
    
    var apiRequest: URLRequest?{
        get{
            let req = self.requestBuilder.apiRequestWithHttpParamsAggregatedHttpParams(
                url:  self.urlBuilder.getURL(endpoint: "/nominations/api/categories/?badge=1", parameters: nil
                ),
                method: .GET ,
                httpBodyDict: nil
            )
            return req
        }
    }
    
}

//class ApprovalAwardCategoryDataParser: DataParserProtocol {
//    typealias ExpectedRawDataType = NSDictionary
//    typealias ResultType = NSDictionary
//    
//    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
//        return APICallResult.Success(result: fetchedData)
//    }
//}

class ApprovalAwardCategoryDataParser: DataParserProtocol {
    typealias ExpectedRawDataType = NSDictionary
    typealias ResultType = [ApprovalAwardCategoryModel]
    
    func parseFetchedData(fetchedData: ExpectedRawDataType) -> APICallResult<ResultType> {
        var awardCategoryArr  = [ApprovalAwardCategoryModel]()
        var badgesData  = [BadgeData]()
        if let fetchedAwardCategory = fetchedData.object(forKey: "results") as? [NSDictionary] {
            for awardCat in fetchedAwardCategory {
                let pk = awardCat.object(forKey: "id") as? Int ?? 0
                let isMultipleUserAllowed = awardCat.object(forKey: "is_multiple_user") as? Bool ?? true
                let isSelfNominationEnabled = awardCat.object(forKey: "is_self") as? Bool ?? false
                let canAttachCoreValue = awardCat.object(forKey: "can_attach_core_value") as? Bool ?? false
                
                if let badgedata = awardCat.object(forKey: "badges") as? [NSDictionary] {
                    badgesData.removeAll()
                    for badge in badgedata {
                        let badgePK = badge.object(forKey: "id") as? Int ?? 0
                        let badgeName = badge.object(forKey: "name") as? String ?? ""
                        let badgeIcon = badge.object(forKey: "icon") as? String ?? ""
                        let badgeBgColor = badge.object(forKey: "background_color") as? String ?? ""
                        let badgePoints = badge.object(forKey: "award_points") as? String ?? ""
                        let badgeDecimalPoints = badge.object(forKey: "points") as? String ?? ""
                        let serverUrl = UserDefaults.standard.value(forKey: "base_url_for_image_height") as? String ?? ""
                        let badgeData = BadgeData(_badgePk: badgePK, _name: badgeName, _icon: serverUrl + badgeIcon, _backGroundColor: badgeBgColor, _points: badgePoints, _decimalPoints: badgeDecimalPoints)
                        badgesData.append(badgeData)
                    }
                }
                let awardDataArr = ApprovalAwardCategoryModel(_isMultipleUser: isMultipleUserAllowed, isSelfNominationEnabled, _isCoreValueEnabled: canAttachCoreValue, _parentPK: pk, _badgeData: badgesData)
                awardCategoryArr.append(awardDataArr)
            }
            let apiResults = APICallResult.Success(result: awardCategoryArr)
            return apiResults
        }else{
            return APICallResult.Success(result: [])
            
        }
    }
}


public struct ApprovalAwardCategoryModel{
    public var parentPK : Int
    public var isMultipleUser : Bool
    public var isSelfEnabled : Bool
    public var isCoreValueEnabled : Bool
    public var badgeData : [BadgeData]
    
    public init(_isMultipleUser : Bool, _ isSelfEnabled : Bool, _isCoreValueEnabled : Bool, _parentPK : Int, _badgeData : [BadgeData]) {
        self.isMultipleUser = _isMultipleUser
        self.isSelfEnabled = isSelfEnabled
        self.isCoreValueEnabled = _isCoreValueEnabled
        self.parentPK = _parentPK
        self.badgeData = _badgeData
    }
    
}

public struct BadgeData{
    public  var badgePk : Int
    public var name : String
    public var icon : String
    public var backGroundColor : String
    public var points : String
    public var decimalPoints : String
    
    public init(_badgePk : Int, _name : String, _icon : String, _backGroundColor : String, _points : String, _decimalPoints : String) {
        self.badgePk = _badgePk
        self.name = _name
        self.icon = _icon
        self.backGroundColor = _backGroundColor
        self.points = _points
        self.decimalPoints = _decimalPoints
    }
    
}
