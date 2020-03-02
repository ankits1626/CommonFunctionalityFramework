//
//  FeedsCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/03/20.
//  Copyright © 2020 Rewardz Private Limited. All rights reserved.
//

import UIKit

public class FeedsCoordinator {
  
  public init(){}
  
  public func getFeedsView() -> UIViewController{
    return FeedsViewController(nibName: "FeedsViewController", bundle: Bundle(for: FeedsViewController.self))
  }
  
  
  
}
