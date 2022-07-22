//
//  NoEntryViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 22/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class NoEntryViewController: UIViewController {
    @IBOutlet weak var messageLabel : UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel?.text = "No Records Found!".localized
    }
    
    func showEmptyMessageView(message: String, parentView: UIView, parentViewController: UIViewController) {
        messageLabel?.text = message
        parentViewController.addChild(self)
        view.frame = CGRect(
            x: 0,
            y: 0,
            width: parentView.bounds.size.width,
            height: parentView.bounds.size.height
        )
        parentView.addSubview(view)
        didMove(toParent: parentViewController)
    }
    
    func hideEmptyMessageView() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
