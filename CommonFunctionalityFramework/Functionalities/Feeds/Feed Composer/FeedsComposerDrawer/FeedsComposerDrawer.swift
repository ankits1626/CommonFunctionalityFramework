//
//  FeedsComposerDrawer.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public class FeedsComposerDrawerError {
    public static let UnableToGetTopViewController = NSError(
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
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    weak var mediaFetcher : CFFMediaCoordinatorProtocol?
    weak var themeManager: CFFThemeManagerProtocol?
    var selectedOrganisationsAndDepartment : FeedOrganisationDepartmentSelectionModel?
    var displayable : FeedOrganisationDepartmentSelectionDisplayModel?
    weak var mainAppCoordinator : CFFMainAppInformationCoordinator?
    
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
        createPollButton?.setTitle("CREATE POLL".localized, for: .normal)
        createPollButton?.borderedControl()
        createPollButton?.titleLabel?.font = UIFont.Button
        createPollButton?.setTitleColor(.black, for: .normal)
        createPostButton?.setTitle("CREATE POST".localized, for: .normal)
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
    
    func opnPostViewController() throws{
        dismissAndShowEditor(type: .Post)
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
                requestCoordinator: self.requestCoordinator,
                mediaFetcher: self.mediaFetcher,
                selectedAssets: nil,
                themeManager: self.themeManager,
                selectedOrganisationsAndDepartments: self.selectedOrganisationsAndDepartment,
                mainAppCoordinator: self.mainAppCoordinator).showFeedItemEditor(type: type)
        }
    }
    
}
