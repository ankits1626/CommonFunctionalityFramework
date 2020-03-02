//
//  FeedsViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/03/20.
//  Copyright © 2020 Rewardz Private Limited. All rights reserved.
//

import UIKit

class FeedsViewController: UIViewController {
  @IBOutlet private weak var feedsTable : UITableView?
  lazy var feedsCellFactory: FeedsCellFactory = {
    return FeedsCellFactory()
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  private func setupTableView(){
    
  }
}
