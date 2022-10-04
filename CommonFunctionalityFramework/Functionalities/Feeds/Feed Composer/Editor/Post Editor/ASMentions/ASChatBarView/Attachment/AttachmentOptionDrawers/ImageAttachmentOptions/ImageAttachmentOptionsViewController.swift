//
//  ImageAttachmentOptionsViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 04/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class ImageAttachmentOptionsViewController: UIViewController {
    
    @IBOutlet weak var cameraButton : BlockButton?
    @IBOutlet weak var galleryButton : BlockButton?
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
        cameraButton?.setTitle("Camera".localized.uppercased(), for: .normal)
        cameraButton?.borderedControl()
        cameraButton?.titleLabel?.font = UIFont.Button
        cameraButton?.setTitleColor(.black, for: .normal)
        galleryButton?.setTitle("Gallery".localized.uppercased(), for: .normal)
        galleryButton?.borderedControl()
        galleryButton?.titleLabel?.font = UIFont.Button
        galleryButton?.setTitleColor(.black, for: .normal)
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

