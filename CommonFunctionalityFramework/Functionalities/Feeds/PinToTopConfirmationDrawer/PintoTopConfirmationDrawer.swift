//
//  PintoTopConfirmationDrawer.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 12/04/21.
//  Copyright © 2021 Rewardz. All rights reserved.
//

import UIKit

class PintoTopConfirmationDrawer: UIViewController {
    @IBOutlet private weak var closeLabel : UILabel?
    @IBOutlet private weak var titleLabel : UILabel?
    @IBOutlet private weak var messageLabel : UILabel?
    @IBOutlet private weak var deleteButton : UIButton?
    @IBOutlet private weak var cancelButton : UIButton?
    weak var themeManager: CFFThemeManagerProtocol?
    
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
        titleLabel?.text = "Make Priority".localized
        messageLabel?.text = "This will appear on top of users feed.Any earilerpriority feed would be unpinned. Are you sure?".localized
        titleLabel?.font = .Title1
        titleLabel?.font = .Title1
        messageLabel?.font = .Caption2
        configureConfirmButton()
        configureCancelButton()
    }
    
    private func configureConfirmButton(){
        deleteButton?.setTitle("CONFIRM".localized, for: .normal)
        deleteButton?.titleLabel?.font = .Button
        deleteButton?.setTitleColor(.bottomAssertiveButtonTextColor, for: .normal)
        deleteButton?.backgroundColor = themeManager?.getControlActiveColor() ?? .bottomAssertiveBackgroundColor
        if let unwrappedThemeManager = themeManager{
            deleteButton?.curvedBorderedControl(borderColor: unwrappedThemeManager.getControlActiveColor(), borderWidth: 1.0)
        }else{
            deleteButton?.curvedBorderedControl()
        }
    }
    
    private func configureCancelButton(){
        cancelButton?.setTitle("CANCEL".localized, for: .normal)
        cancelButton?.titleLabel?.font = .Button
        cancelButton?.setTitleColor(.bottomDestructiveButtonTextColor, for: .normal)
        cancelButton?.backgroundColor = .bottomDestructiveBackgroundColor
        if let controlColor = themeManager?.getControlActiveColor(){
            cancelButton?.curvedBorderedControl(borderColor: controlColor, borderWidth: 1.0)
            cancelButton?.setTitleColor(controlColor, for: .normal)
        }else{
            cancelButton?.curvedBorderedControl()
        }
    }
    
    func presentDrawer() throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            slideInTransitioningDelegate.direction = .bottom(height: 320)
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw FeedConfirmationDrawerError.UnableToGetTopViewController
        }
    }
    
    @IBAction private func closeDrawer(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func deleteButtonPressed(){
        if let unwrappedCompletion = deletePressedCompletion{
            dismiss(animated: true) {
                unwrappedCompletion()
            }
        }
    }
}

