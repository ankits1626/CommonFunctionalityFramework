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
    @IBOutlet private weak var confirmedButton : UIButton?
    @IBOutlet private weak var cancelButton : UIButton?
    @IBOutlet private weak var postFrequency : UIView?
    weak var themeManager: CFFThemeManagerProtocol?
    @IBOutlet private weak var selectPinPostFrequency : UIButton?
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    var confirmedCompletion : ((_ selectedFrequency : String) -> Void)?
    var targetFeed : FeedsItemProtocol?
    var isAlreadyPinned : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        postFrequency?.addBorders(edges: [.all], color: .gray)
    }
    
    private func setup(){
        view.clipsToBounds = true
        view.roundCorners(corners: [.topLeft, .topRight], radius: AppliedCornerRadius.standardCornerRadius)
        closeLabel?.font = .Caption1
        if isAlreadyPinned {
            titleLabel?.text = "Make Priority".localized
            messageLabel?.text = "Making this post as pinned will remove the older pinned post. Are you sure you want to proceed?".localized
        }else{
            titleLabel?.text = "Make Priority".localized
            messageLabel?.text = "Do you want to make this post a priority and pin on top?".localized
        }
        titleLabel?.font = .Title1
        titleLabel?.font = .Title1
        messageLabel?.font = .Caption2
        configureConfirmButton()
        configureCancelButton()
    }
    
    private func configureConfirmButton(){
        confirmedButton?.setTitle("CONFIRM".localized, for: .normal)
        confirmedButton?.titleLabel?.font = .Button
        confirmedButton?.setTitleColor(.bottomAssertiveButtonTextColor, for: .normal)
        confirmedButton?.backgroundColor = themeManager?.getControlActiveColor() ?? .bottomAssertiveBackgroundColor
        if let unwrappedThemeManager = themeManager{
            confirmedButton?.curvedBorderedControl(borderColor: unwrappedThemeManager.getControlActiveColor(), borderWidth: 1.0)
        }else{
            confirmedButton?.curvedBorderedControl()
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
    
    @IBAction private func confirmedButtonPressed(){
        if let unwrappedCompletion = confirmedCompletion{
            dismiss(animated: true) {
                unwrappedCompletion(self.selectPinPostFrequency?.titleLabel?.text ?? "")
            }
        }
    }
    
    @IBAction private func pinPostFrequncyButtonPressed(sender : UIButton){
        var options = [FloatingMenuOption]()
        options.append(
            FloatingMenuOption(title: "1 day", action: {
                self.setFrequencyText(value: "1 day")
            }
            )
        )
        options.append(
            FloatingMenuOption(title: "1 week".localized, action: {
                self.setFrequencyText(value: "1 week")
            }
            )
        )
        options.append(
            FloatingMenuOption(title: "1 month".localized, action: {
                self.setFrequencyText(value: "1 month")
            }
            )
        )
        
        options.append(
            FloatingMenuOption(title: "Always".localized, action: {
                self.setFrequencyText(value: "Always")
            }
            )
        )
        FloatingMenuOptions(options: options).showPopover(sourceView: sender)
    }
    
    func setFrequencyText(value : String) {
        self.selectPinPostFrequency?.setTitle(value, for: .normal)
    }
}

