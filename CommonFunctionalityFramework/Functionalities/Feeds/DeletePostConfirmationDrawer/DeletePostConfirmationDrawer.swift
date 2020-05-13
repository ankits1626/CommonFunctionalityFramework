//
//  DeletePostConfirmationDrawer.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class DeletePostConfirmationDrawerError {
    static let UnableToGetTopViewController = NSError(
        domain: "com.commonfunctionality.DeletePostConfirmationDrawer",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unable to get top view controller"]
    )
}

class DeletePostConfirmationDrawer: UIViewController {
    @IBOutlet private weak var closeLabel : UILabel?
    @IBOutlet private weak var titleLabel : UILabel?
    @IBOutlet private weak var messageLabel : UILabel?
    @IBOutlet private weak var deleteButton : UIButton?
    
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    var deletePressedCompletion :(() -> Void)?
    var targetFeed : FeedsItemProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        view.clipsToBounds = true
        view.roundCorners(corners: [.topLeft, .topRight], radius: AppliedCornerRadius.standardCornerRadius)
        closeLabel?.font = .Caption1
        if let type = targetFeed?.getFeedType() {
            switch type {
            case .Poll:
                titleLabel?.text = "Delete Poll"
                messageLabel?.text = "Are you sure that you need to delete this poll? By deleting all the users answers till now would be lost and not retrievable."
            case .Post:
                titleLabel?.text = "Delete Post"
                messageLabel?.text = "Are you sure that you need to delete this post? "
            }
        }else{
            titleLabel?.text = "Delete Post"
            messageLabel?.text = "Are you sure that you need to delete this post? "
        }
        titleLabel?.font = .Title1
        titleLabel?.font = .Title1
        messageLabel?.font = .Highlighter2
        deleteButton?.titleLabel?.font = .Button
        deleteButton?.setTitleColor(.bottomButtonTextColor, for: .normal)
        deleteButton?.curvedBorderedControl()
    }
    
    func presentDrawer() throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            slideInTransitioningDelegate.direction = .bottom(height: 233)
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw DeletePostConfirmationDrawerError.UnableToGetTopViewController
        }
    }
    
    @IBAction private func closeDrawer(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func deleteButtonPressed(){
        if let unwrappedCompletion = deletePressedCompletion{
            unwrappedCompletion()
            dismiss(animated: true, completion: nil)
        }
    }
}
