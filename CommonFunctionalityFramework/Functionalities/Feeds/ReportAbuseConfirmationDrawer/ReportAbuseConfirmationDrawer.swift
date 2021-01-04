//
//  ReportAbuseConfirmationDrawer.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit Sachan on 10/10/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class ReportAbuseConfirmationDrawer: UIViewController {@IBOutlet private weak var closeLabel : UILabel?
    @IBOutlet private weak var titleLabel : UILabel?
    @IBOutlet private weak var messageLabel : UILabel?
    @IBOutlet private weak var commentsLabel : UILabel?
    @IBOutlet private weak var confirmButton : UIButton?
    @IBOutlet private weak var cancelButton : UIButton?
    weak var themeManager: CFFThemeManagerProtocol?
    @IBOutlet private weak var descriptionText : KMPlaceholderTextView?
    
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    var confirmPressedCompletion :((_ notes: String?) -> Void)?
    var targetFeed : FeedsItemProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        view.clipsToBounds = true
        view.roundCorners(corners: [.topLeft, .topRight], radius: AppliedCornerRadius.standardCornerRadius)
        closeLabel?.font = .Caption1
        titleLabel?.text = "Report Abuse".localized
        messageLabel?.text = "If you have any concerns regarding the feed please share below.".localized
        titleLabel?.font = .Title1
        titleLabel?.font = .Title1
        messageLabel?.font = .Body3
        commentsLabel?.font = .Highlighter1
        configureConfirmButton()
        configureCancelButton()
        descriptionText?.placeholder = "Please type in your concerns".localized
        descriptionText?.placeholderColor = .gray
        descriptionText?.font = .Body1
        descriptionText?.delegate = self
    }
    
    private func configureConfirmButton(){
        confirmButton?.isEnabled = false
        confirmButton?.setTitle("CONFIRM".localized, for: .normal)
        confirmButton?.titleLabel?.font = .Button
        confirmButton?.setTitleColor(.bottomAssertiveButtonTextColor, for: .normal)
        confirmButton?.backgroundColor = themeManager?.getControlActiveColor() ?? .bottomAssertiveBackgroundColor
        if let unwrappedThemeManager = themeManager{
            confirmButton?.curvedBorderedControl(borderColor: unwrappedThemeManager.getControlActiveColor(), borderWidth: 1.0)
        }else{
            confirmButton?.curvedBorderedControl()
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
            slideInTransitioningDelegate.direction = .bottom(height: 380)
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
    
    @IBAction private func confirmButtonPressed(){
        if let unwrappedCompletion = confirmPressedCompletion{
            dismiss(animated: true) { [weak self] in
                if let commentText = self?.descriptionText?.text{
                     unwrappedCompletion(commentText)
                }
            }
        }
    }
}


extension ReportAbuseConfirmationDrawer : UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            confirmButton?.isEnabled = true
        }else{
            confirmButton?.isEnabled = false
        }
    }
}
