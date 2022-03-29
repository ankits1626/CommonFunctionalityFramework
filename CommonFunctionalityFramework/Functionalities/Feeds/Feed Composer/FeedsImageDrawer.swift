//
//  FeedsImageDrawer.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 29/03/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

protocol FeedsImageDelegate {
    func selectedImageType(isCamera : Bool)
}

class FeedsImageDrawer: UIViewController {
    
    @IBOutlet private weak var cameraButton : UIButton?
    @IBOutlet private weak var galleryButton : UIButton?
    var feedCoordinatorDeleagate: FeedsCoordinatorDelegate!
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    weak var mediaFetcher : CFFMediaCoordinatorProtocol?
    weak var themeManager: CFFThemeManagerProtocol?
    var delegate : FeedsImageDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.clipsToBounds = true
        view.roundCorners(corners: [.topLeft, .topRight], radius: AppliedCornerRadius.standardCornerRadius)
        setupButtons()
    }
    
    private func setupButtons(){
        cameraButton?.setTitle("Camera".localized, for: .normal)
        cameraButton?.borderedControl()
        cameraButton?.titleLabel?.font = UIFont.Button
        cameraButton?.setTitleColor(.black, for: .normal)
        galleryButton?.setTitle("Gallery".localized, for: .normal)
        galleryButton?.borderedControl()
        galleryButton?.titleLabel?.font = UIFont.Button
        galleryButton?.setTitleColor(.black, for: .normal)
    }
    
    func presentDrawer() throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            slideInTransitioningDelegate.direction = .bottom(height: 198.0)
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw FeedsComposerDrawerError.UnableToGetTopViewController
        }
    }
    
    func opnPostViewController() throws{
        dismissAndShowEditor(type: .Post)
    }
}

extension FeedsImageDrawer{
    @IBAction func openCamera(){
        delegate?.selectedImageType(isCamera: true)
    }
    
    @IBAction func openGallery(){
        delegate?.selectedImageType(isCamera: false)
    }
    
    private func dismissAndShowEditor(type: FeedType){
        dismiss(animated: true) {
            FeedComposerCoordinator(
                delegate: self.feedCoordinatorDeleagate,
                requestCoordinator: self.requestCoordinator,
                mediaFetcher: self.mediaFetcher, selectedAssets: nil, themeManager: self.themeManager).showFeedItemEditor(type: type)
        }
    }
    
}

