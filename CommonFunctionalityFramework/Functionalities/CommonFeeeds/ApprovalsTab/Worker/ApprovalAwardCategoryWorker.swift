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
        if let fetchedAwardCategory = fetchedData.object(forKey: "results") as? [NSDictionary] {
            for awardCat in fetchedAwardCategory {
                let pk = awardCat.object(forKey: "id") as? Int ?? 0
                if let badgedata = awardCat.object(forKey: "badge") as? NSDictionary {
                    let parentPk = badgedata.object(forKey: "id") as? Int ?? 0
                    let name = badgedata.object(forKey: "name") as? String ?? ""
                    let icon = badgedata.object(forKey: "icon") as? String ?? ""
                    let bgColor = badgedata.object(forKey: "background_color") as? String ?? ""
                    let points = badgedata.object(forKey: "award_points") as? String ?? ""
                    let awardDataArr = ApprovalAwardCategoryModel(_pk: pk, _name: name, _icon: icon, _backGroundColor: bgColor, _points: points, _parentPK: parentPk)
                    awardCategoryArr.append(awardDataArr)
                }
            }
            let apiResults = APICallResult.Success(result: awardCategoryArr)
            return apiResults
        }else{
            return APICallResult.Success(result: [])
            
        }
    }
}


struct ApprovalAwardCategoryModel{
    var pk : Int
    var name : String
    var icon : String
    var backGroundColor : String
    var points : String
    var parentPK : Int
    
    init(_pk : Int, _name : String, _icon : String, _backGroundColor: String, _points : String, _parentPK : Int) {
        self.pk = _pk
        self.name = _name
        self.icon = _icon
        self.backGroundColor = _backGroundColor
        self.points = _points
        self.parentPK = _parentPK
    }
    
}
