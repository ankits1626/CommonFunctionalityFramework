//
//  FeedsComposerDrawer.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedsComposerDrawerError {
    static let UnableToGetTopViewController = NSError(
        domain: "com.commonfunctionality.FeedsComposerDrawer",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unable to get top view controller"]
    )
}

class FeedsComposerDrawer: UIViewController {
    
    @IBOutlet private weak var createPostButton : UIButton?
    @IBOutlet private weak var createPollButton : UIButton?
    var feedCoordinatorDeleagate: FeedsCoordinatorDelegate!
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    var requestCoordinator: CFFNetwrokRequestCoordinatorProtocol!
    
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
        createPollButton?.setTitle("CREATE POLL", for: .normal)
        createPollButton?.borderedControl()
        createPollButton?.titleLabel?.font = UIFont.Button
        createPollButton?.setTitleColor(.black, for: .normal)
        createPostButton?.setTitle("CREATE POST", for: .normal)
        createPostButton?.borderedControl()
        createPostButton?.titleLabel?.font = UIFont.Button
        createPostButton?.setTitleColor(.black, for: .normal)
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
    
}

extension FeedsComposerDrawer{
    @IBAction func createPost(){
        dismissAndShowEditor(type: .Post)
    }
    
    @IBAction func createPoll(){
        dismissAndShowEditor(type: .Poll)
    }
    
    private func dismissAndShowEditor(type: FeedType){
        dismiss(animated: true) {
            FeedComposerCoordinator(
                delegate: self.feedCoordinatorDeleagate,
                requestCoordinator: self.requestCoordinator).showFeedItemEditor(type: type)
        }
    }
    
}
