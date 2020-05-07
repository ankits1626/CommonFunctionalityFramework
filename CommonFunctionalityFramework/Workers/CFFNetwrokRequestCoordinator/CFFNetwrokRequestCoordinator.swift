//
//  CFFNetwrokRequestCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

public struct FetchedFeedModel{
    public var fetchedRawFeeds : [String : Any]?
    public var error : String?
    public var nextPageUrl : String?
    
    public init(fetchedRawFeeds : [String : Any]?, error : String?, nextPageUrl : String?) {
        self.fetchedRawFeeds = fetchedRawFeeds
        self.error = error
        self.nextPageUrl = nextPageUrl
    }
}

public struct FetchFeedRequest{
    public var nextPageUrl : String?
}

public protocol CFFNetwrokRequestCoordinatorProtocol : class {
    func getBaseUrlProvider() -> BaseURLProviderProtocol
    func getLogoutHandler() -> LogoutResponseHandler
    func getTokenProvider() -> TokenProviderProtocol
}
