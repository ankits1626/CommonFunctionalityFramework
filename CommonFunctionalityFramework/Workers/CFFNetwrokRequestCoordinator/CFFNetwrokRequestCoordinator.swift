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
    
    public init(fetchedRawFeeds : [String : Any]?, error : String?) {
        self.fetchedRawFeeds = fetchedRawFeeds
        self.error = error
    }
}

public struct FetchFeedRequest{
    public var nextPageUrl : String?
}

public protocol CFFNetwrokRequestCoordinatorProtocol {
    func getFeeds(request : FetchFeedRequest, completion:@escaping(_ fetchedFeedResult : FetchedFeedModel)-> Void)
}
