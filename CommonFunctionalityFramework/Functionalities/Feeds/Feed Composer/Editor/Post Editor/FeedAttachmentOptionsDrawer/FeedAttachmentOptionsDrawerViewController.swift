//
//  FeedAttachmentOptionsDrawerViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 08/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedAttachmentOptionsDrawerViewController: UIViewController {
    @IBOutlet weak var attachPhotosButton : BlockButton?
    @IBOutlet weak var attachGifButton : BlockButton?
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
        attachPhotosButton?.setTitle("Photo Library", for: .normal)
        attachPhotosButton?.borderedControl()
        attachPhotosButton?.titleLabel?.font = UIFont.Button
        attachPhotosButton?.setTitleColor(.black, for: .normal)
        attachGifButton?.setTitle("GIFS", for: .normal)
        attachGifButton?.borderedControl()
        attachGifButton?.titleLabel?.font = UIFont.Button
        attachGifButton?.setTitleColor(.black, for: .normal)
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
