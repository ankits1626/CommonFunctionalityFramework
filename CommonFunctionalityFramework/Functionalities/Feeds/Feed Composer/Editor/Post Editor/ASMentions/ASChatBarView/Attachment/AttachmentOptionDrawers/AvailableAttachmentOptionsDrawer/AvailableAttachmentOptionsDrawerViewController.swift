//
//  AvailableAttachmentOptionsDrawerViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 04/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents

class AvailableAttachmentOptionsDrawerViewController: UIViewController {
    
    @IBOutlet weak var attachPhotosButton : BlockButton?
    @IBOutlet weak var attachDocumentButton : BlockButton?
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        view.clipsToBounds = true
        view.roundCorners(corners: [.topLeft, .topRight], radius: AppliedCornerRadius.standardCornerRadius)
        setupButtons()
    }
    
    private func setupButtons(){
        attachPhotosButton?.setTitle("Photo Library".localized.uppercased(), for: .normal)
        attachPhotosButton?.borderedControl()
        attachPhotosButton?.titleLabel?.font = UIFont.Button
        attachPhotosButton?.setTitleColor(.black, for: .normal)
        attachDocumentButton?.setTitle("Document ".localized.uppercased(), for: .normal)
        attachDocumentButton?.borderedControl()
        attachDocumentButton?.titleLabel?.font = UIFont.Button
        attachDocumentButton?.setTitleColor(.black, for: .normal)
    }
    
    func presentDrawer() throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            slideInTransitioningDelegate.direction = .bottom(height: 170.0)
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw FeedsComposerDrawerError.UnableToGetTopViewController
        }
    }
}

