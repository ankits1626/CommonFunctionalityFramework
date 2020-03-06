//
//  FeedsCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/03/20.
//  Copyright © 2020 Rewardz Private Limited. All rights reserved.
//

import UIKit

public struct GetFeedsViewModel{
    var networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    var mediaCoordinator : CFFMediaCoordinatorProtocol
    public init (networkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol, mediaCoordinator : CFFMediaCoordinatorProtocol){
        self.networkRequestCoordinator = networkRequestCoordinator
        self.mediaCoordinator = mediaCoordinator
    }
}

public class FeedsCoordinator {
    
    public init(){}
    
    public func getFeedsView(_ inputModel : GetFeedsViewModel) -> UIViewController{
        let feedsVc =  FeedsViewController(nibName: "FeedsViewController", bundle: Bundle(for: FeedsViewController.self))
        feedsVc.feedFetcher = inputModel.networkRequestCoordinator
        feedsVc.mediaFetcher = inputModel.mediaCoordinator
        return feedsVc
    }
}
