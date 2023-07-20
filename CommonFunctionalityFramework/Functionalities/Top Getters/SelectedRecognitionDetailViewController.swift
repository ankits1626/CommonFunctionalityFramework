//
//  SelectedRecognitionDetailViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 10/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit

class SelectedRecognitionDetailViewController: UIViewController {
  var feedDetailVC : UIViewController!
  @IBOutlet private weak var containerView : UIView!
  override func viewDidLoad() {
    super.viewDidLoad()
    addViewControllerToContainer(feedDetailVC)
  }
  
  private func addViewControllerToContainer(_ newVC : UIViewController){
    addChild(newVC)
    newVC.view.frame = CGRect(x: 0, y: 0, width: containerView.bounds.size.width, height: containerView.bounds.size.height)
    containerView.addSubview(newVC.view)
    newVC.didMove(toParent: self)
  }
  
  @IBAction func backButtonPressed(){
    self.navigationController?.popViewController(animated: true)
  }
  
}
