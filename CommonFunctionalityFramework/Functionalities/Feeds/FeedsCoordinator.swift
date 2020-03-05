//
//  FeedsCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/03/20.
//  Copyright © 2020 Rewardz Private Limited. All rights reserved.
//

import UIKit

public struct GetFeedsViewModel{
    var netoworkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    var mediaCoordinator : CFFMediaCoordinatorProtocol
    public init (netoworkRequestCoordinator: CFFNetwrokRequestCoordinatorProtocol, mediaCoordinator : CFFMediaCoordinatorProtocol){
        self.netoworkRequestCoordinator = netoworkRequestCoordinator
        self.mediaCoordinator = mediaCoordinator
    }
}

public class FeedsCoordinator {
  
  public init(){}
  
    public func getFeedsView(_ inputModel : GetFeedsViewModel) -> UIViewController{
    return FeedsViewController(nibName: "FeedsViewController", bundle: Bundle(for: FeedsViewController.self))
  }
}
