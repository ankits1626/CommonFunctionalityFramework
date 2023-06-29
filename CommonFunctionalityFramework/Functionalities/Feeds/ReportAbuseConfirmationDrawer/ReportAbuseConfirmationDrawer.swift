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
    @IBOutlet private weak var reportAbuseTitleLabel : UILabel?
    @IBOutlet private weak var reportAbuseSubTitleLabel : UILabel?
    @IBOutlet weak var reportAbuseImg: UIImageView!
    @IBOutlet private weak var messageLabel : UILabel?
    @IBOutlet private weak var commentsLabel : UILabel?
    @IBOutlet private weak var confirmButton : UIButton?
    @IBOutlet private weak var cancelButton : UIButton?
    weak var themeManager: CFFThemeManagerProtocol?
    @IBOutlet private weak var descriptionText : KMPlaceholderTextView?
    var bottomSafeArea : CGFloat!
    
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
        configureConfirmButton()
        configureCancelButton()
        descriptionText?.placeholder = "Please type in your concerns".localized
        descriptionText?.placeholderColor = .gray
        descriptionText?.font = .Body1
        descriptionText?.delegate = self
        reportAbuseImg.setImageColor(color: UIColor.getControlColor())
        reportAbuseTitleLabel?.text = "Report Abuse".localized
        reportAbuseSubTitleLabel?.text = "If you have any concerns regarding this feed.Please share below".localized
    }
    
    private func configureConfirmButton(){
        confirmButton?.alpha = 0.5
        confirmButton?.isEnabled = false
        confirmButton?.setTitle("Report".localized, for: .normal)
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
        cancelButton?.setTitle("Cancel".localized, for: .normal)
        cancelButton?.titleLabel?.font = .Button
        cancelButton?.setTitleColor(.bottomDestructiveButtonTextColor, for: .normal)
        cancelButton?.backgroundColor = .bottomDestructiveBackgroundColor
        if let controlColor = themeManager?.getControlActiveColor(){
            //cancelButton?.curvedBorderedControl(borderColor: controlColor, borderWidth: 1.0)
            cancelButton?.setTitleColor(controlColor, for: .normal)
        }else{
            cancelButton?.curvedBorderedControl()
        }
    }
    
    func presentDrawer() throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            if #available(iOS 11.0, *) {
                bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
            }else{
                bottomSafeArea = 0.0
            }
            slideInTransitioningDelegate.direction = .bottom(height: 510 + bottomSafeArea)
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
            confirmButton?.alpha = 1.0
            confirmButton?.isEnabled = true
        }else{
            confirmButton?.alpha = 0.5
            confirmButton?.isEnabled = false
        }
    }
}
