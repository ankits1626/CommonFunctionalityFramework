//
//  ASChatBarview.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import Photos

public class ASChatBarError {
    static let NoHeightConstraintSet : Error = NSError(
        domain: "com.cff.aschatbarview",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Height constraint is not set for chat bar."]
    )
}
@objc public protocol ASChatBarViewDelegate : class {
    func finishedPresentingOverKeyboard()
    func addAttachmentButtonPressed()
    func removeAttachment()
    func rightButtonPressed(_ chatBar : ASChatBarview)
}

public class ASChatBarview : UIView {
    public var themeManager: CFFThemeManagerProtocol?
    @IBOutlet public weak var container : UIView?
    @IBOutlet public weak var attachImageButton : UIButton?
    @IBOutlet public weak var attachImageWidthConstraint : NSLayoutConstraint?
    public var isAttachmentButtonVisibile = false{
        didSet{
            attachImageWidthConstraint?.constant = isAttachmentButtonVisibile ? 40 : 0
        }
    }
    @IBOutlet private weak var attachmentContainer : UIView?
    @IBOutlet private weak var attachmentDisplayHeightConstraint : NSLayoutConstraint?
    @IBOutlet private weak var sendButton : UIButton?
    @IBOutlet weak var leftUserImg: UIImageView!
    @IBOutlet public weak var messageTextView : KMPlaceholderTextView?
    @IBOutlet private weak var placeholderLabel : UILabel?
    @IBOutlet public weak var delegate : ASChatBarViewDelegate?
    var tagPicker : ASMentionSelectorViewController?
    @IBOutlet public weak var heightConstraint : NSLayoutConstraint?
    @IBOutlet private weak var leftContainer : UIView?
    @IBOutlet private weak var leftContainerHeightConstraint : NSLayoutConstraint?
    @IBOutlet private weak var leftContainerWidthConstraint : NSLayoutConstraint?
    var taggedMessaged : String = ""
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    weak var themeManager: CFFThemeManagerProtocol?
    public override var backgroundColor: UIColor?{
        didSet{
            container?.backgroundColor = backgroundColor
        }
    }
    lazy var tap: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(dismiss))
    }()
    @IBOutlet public var bottomConstraint: NSLayoutConstraint!
    public var containerSuperView: UIView?
    lazy var maxHeight: NSLayoutConstraint = {
        let _bottomConstraint =   NSLayoutConstraint(
            item: messageTextView!,
            attribute: NSLayoutConstraint.Attribute.height,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: nil,
            attribute: NSLayoutConstraint.Attribute.height,
            multiplier: 1,
            constant: 0)
        _bottomConstraint.priority = UILayoutPriority.defaultHigh
        return _bottomConstraint
    }()

    private let kAttachmentContainerWidth : CGFloat = 100
    private let kAttachmentContainerHeight : CGFloat = 80
    private let kAttachmentContainerTopInset : CGFloat = 5
    private let kAttachmentContainerBottomInset : CGFloat = 5
    private let kDefaultAttachmentContainerWidth : CGFloat = 44
    private let kDefaultAttachmentContainerHeight  : CGFloat = 44
    
    private lazy var attachmentHandler: AttachmentHandler = {
        return AttachmentHandler()
    }()
    
    private lazy var attachmentDataManager: AttachmentDataManager = {
        return AttachmentDataManager()
    }()
    private var attachmentView: ASChatBarAttachmentViewController?
    
    public var placeholder: String?{
        didSet{
            placeholderLabel?.text = placeholder
        }
    }
    
    public var placeholderColor : UIColor?{
        didSet{
            placeholderLabel?.textColor = placeholderColor
        }
    }
    
    public var placeholderFont : UIFont?{
        didSet{
            placeholderLabel?.font = placeholderFont
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        commonSetup()
        setupCoordinator(messageTextView)
    }
    
    public func setupUserProfile() {
        if let profileImageEndpoint = themeManager?.getLoggedInUserImage(), profileImageEndpoint.count > 0{
            self.mediaFetcher.fetchImageAndLoad(self.leftUserImg, imageEndPoint: profileImageEndpoint)
        }else{
            self.leftUserImg.setImageForName(themeManager?.getLoggedInUserFullName() ?? "NN", circular: false, textAttributes: nil)
        }
    }

    private func registerForKeyboardNotifications(){
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleKeyboardAppearance),
//            name: UIResponder.keyboardWillShowNotification,
//            object: nil
//        )
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleKeyboardAppearance),
//            name: UIResponder.keyboardWillHideNotification,
//            object: nil
//        )
    }

    private func registerForTextChangeNotification(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChanged),
            name: UITextView.textDidChangeNotification,
            object: nil
        )
    }

    private func commonSetup(){
        xibSetup()
        registerForKeyboardNotifications()
        registerForTextChangeNotification()
        attachImageWidthConstraint?.constant = isAttachmentButtonVisibile ? 40 : 0
    }
    
    func registerTextView() {
        if ASMentionCoordinator.shared.targetTextview == nil{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.setupCoordinator(self.messageTextView)
            })
        }
    }

    private var previousnumberOfLines : Int!
    private let maxNumberOflines = 4

    @objc private func textChanged(){
        registerTextView()
        if let txtview = messageTextView{
            placeholderLabel?.isHidden = !txtview.text.isEmpty
//            attachImageButton?.isEnabled = !txtview.text.isEmpty
            enableSendButtonIfRequired()
            
            adjustHeight()
//            if (previousnumberOfLines == nil ) || (previousnumberOfLines != txtview.getNumberOfLines()) || (txtview.getNumberOfLines() == maxNumberOflines){
//                previousnumberOfLines = txtview.getNumberOfLines()
//                if txtview.getNumberOfLines() >= maxNumberOflines{
//                    maxHeight.constant = txtview.frame.size.height
//                    messageTextView?.addConstraint(maxHeight)
//                    txtview.isScrollEnabled = true
//                    txtview.setNeedsFocusUpdate()
//                    txtview.invalidateIntrinsicContentSize()
//                }else{
//                    txtview.isScrollEnabled = false
//                    if txtview.constraints.contains(maxHeight){
//                        txtview.removeConstraint(maxHeight)
//                    }
//                    txtview.invalidateIntrinsicContentSize()
//                }
//            }
        }
    }
    
    private func enableSendButtonIfRequired(){
        if let isMessageEmpty = messageTextView?.text.isEmpty,
            !isMessageEmpty{
            sendButton?.isEnabled = true
        }else{
            if attachmentDataManager.getNumberOfAttachments() > 0{
                sendButton?.isEnabled = true
            }else{
                sendButton?.isEnabled = false
            }
        }
    }
    
    var orignalHeight : CGFloat!
    private func adjustHeight(){
        messageTextView?.isScrollEnabled = true
        let textView = messageTextView!
        let fixedWidth = textView.frame.size.width
        
        /// Here we need to get The height as Greatest that we can have or expected
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        /// Get New Size
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        /// New Frame
        var newFrame = textView.frame
        var maxHeight : Int = 100
        if let attachmentHeight = attachmentDataManager.getRequiredAttachmentHeight(){
            maxHeight = maxHeight + attachmentHeight + 40
            newFrame.size = CGSize(
                width: max(newSize.width, fixedWidth),
                height: newSize.height + CGFloat(attachmentHeight)
            )
        }else{
            newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        }
        
        
        /// Orignal height is height that is assigned to TextView for first time and 100 is maximum height that textview can increase
        self.heightConstraint?.constant = CGFloat(
            min(
                maxHeight,
                max(
                    Int(newFrame.size.height),
                    Int(self.orignalHeight!)
                   )
            )
        )
        
        scrollTextViewToBottom(textView: messageTextView!)
        
        //                bookSessionStruct.sessionTopicDiscussion = textView.text!.trimmed()
    }
    
    func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    
    private func setupCoordinator(_ targetTextView: UITextView?){
        orignalHeight = self.frame.size.height
        targetTextView?.delegate = ASMentionCoordinator.shared
        ASMentionCoordinator.shared.loadInitialText(targetTextView: targetTextView)
        ASMentionCoordinator.shared.textUpdateListener = self
    }
    
    
    @objc private func handleKeyboardAppearance(notification: NSNotification) {
//        superview?.addGestureRecognizer(tap)
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
        var bottomInset : CGFloat = 0
        if #available(iOS 11.0, *) {
            //TO:DO: Needs to be refactored
            if let unwrappedSuperView = containerSuperView{
                bottomInset = unwrappedSuperView.safeAreaInsets.bottom ?? 34
            }else{
                bottomInset = self.superview?.superview?.superview?.safeAreaInsets.bottom ?? 34
            }
            
        }
        bottomConstraint.constant = isKeyboardShowing ?  keyboardFrame.height - bottomInset : 0
        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.superview?.layoutIfNeeded()
        }) { (completed) in
            if isKeyboardShowing{
                self.delegate?.finishedPresentingOverKeyboard()
            }
        }
    }

    @objc private func dismiss(){
        superview?.removeGestureRecognizer(tap)
        messageTextView?.resignFirstResponder()
    }

    func getMessage() -> String? {
        return messageTextView?.text
    }

    func activate()  {
        messageTextView?.becomeFirstResponder()
        leftButtonTapped()
    }

    func disable() throws {
        if let constraint = heightConstraint{
            let newConstraint = NSLayoutConstraint(
                item: constraint.firstItem as Any,
                attribute: constraint.firstAttribute,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: constraint.secondItem,
                attribute: constraint.secondAttribute,
                multiplier: constraint.multiplier,
                constant: 0
            )
            self.removeConstraint(constraint)
            heightConstraint = newConstraint
            self.addConstraint(newConstraint)
            self.layoutIfNeeded()
        }else{
            throw ASChatBarError.NoHeightConstraintSet
        }
    }

    func enable() throws {
        if let constraint = heightConstraint{
            let newConstraint = NSLayoutConstraint(
                item: constraint.firstItem as Any,
                attribute: constraint.firstAttribute,
                relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual,
                toItem: constraint.secondItem,
                attribute: constraint.secondAttribute,
                multiplier: constraint.multiplier,
                constant: 44
            )
            self.removeConstraint(constraint)
             heightConstraint = newConstraint
            self.addConstraint(newConstraint)
            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.layoutIfNeeded()
            }) { (completed) in

            }
        }else{
            throw ASChatBarError.NoHeightConstraintSet
        }
    }

    deinit {
        superview?.addGestureRecognizer(tap)
    }
}

extension ASChatBarview{
    @IBAction private func leftButtonTapped(){
        //addAttachedImageView()
        attachmentHandler.delegate = self
        attachmentHandler.themeManager = themeManager
        attachmentHandler.showAttachmentOptions()
        delegate?.addAttachmentButtonPressed()
    }

    @objc private func removeAttachedImage(){
        removeAttachedImageView()
        textChanged()
        delegate?.removeAttachment()
    }

    @IBAction private func rightButtonTapped(){
        removeAttachedImageView()
        delegate?.rightButtonPressed(self)
        messageTextView?.text = nil
        textChanged()
        messageTextView?.resignFirstResponder()
    }

    private func removeAttachedImageView(){
        //attachedImageView.removeFromSuperview()
        leftContainerWidthConstraint?.constant = kDefaultAttachmentContainerWidth
        leftContainerHeightConstraint?.constant = kDefaultAttachmentContainerHeight
        heightConstraint?.constant = kDefaultAttachmentContainerHeight
    }

}

extension ASChatBarview : ASMentionCoordinatortextUpdateListener{
    func textUpdated() {
        taggedMessaged = ASMentionCoordinator.shared.getPostableTaggedText() ?? ""
    }
}

extension ASChatBarview : AttachmentHandlerDelegate{
    public func finishedSelectionfFile(documentUrl: URL) {
        attachmentDataManager.addSelectedDocument(documentUrl: documentUrl) {[weak self] in
            self?.toggleAttachmentContainer()
            self?.enableSendButtonIfRequired()
        }
    }
    
    public func finishedSelectionfImage(images: [LocalSelectedMediaItem]?) {
        attachmentDataManager.addSelectedImages(images: images) {[weak self] in
            self?.toggleAttachmentContainer()
            self?.enableSendButtonIfRequired()
        }
    }
    
    private func toggleAttachmentContainer(){
        updateAttachmentView()
        adjustHeight()
    }
    
    private func updateAttachmentView(){
        if attachmentView == nil{
            let attachmentVC = ASChatBarAttachmentViewController(
                nibName: "ASChatBarAttachmentViewController",
                bundle: Bundle(for: ASChatBarAttachmentViewController.self))
            attachmentVC.parentContainerHeightConstraint = attachmentDisplayHeightConstraint
            attachmentVC.attachmentDataManager = attachmentDataManager
            attachmentVC.delegate = self
            attachmentContainer?.addSubview(attachmentVC.view)
            self.attachmentView = attachmentVC
        }
        attachmentView?.updateHeight()
    }
    
    public func finishedDeletingDocument() {
        adjustHeight()
        enableSendButtonIfRequired()
    }
    
    public func getNetworkPostableCommentModel() -> NetworkPostableCommentModel?{
        if (messageTextView?.text != nil) || (attachmentDataManager.getNumberOfAttachments()>0){
            return NetworkPostableCommentModel(
                commentText: messageTextView?.text,
                postableLocalMediaUrls: attachmentDataManager.getAllAttachedImageUrl(),
                postableLocalDocumentUrls: attachmentDataManager.getAllAttachedDocumentUrl())
        }else{
            return nil
        }
    }
    
    public func clearChatBar(){
        self.messageTextView?.text = nil
        self.attachmentDataManager.clearDataManager()
        adjustHeight()
        enableSendButtonIfRequired()
    }
    
}
