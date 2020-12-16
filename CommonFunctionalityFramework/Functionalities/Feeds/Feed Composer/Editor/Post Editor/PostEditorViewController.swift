//
//  PostEditorViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import SimpleCheckbox
import CoreData

extension Notification.Name{
    static let didUpdatedPosts = Notification.Name("didUpdatedPosts")
}

class PostEditorViewController: UIViewController {
    weak var themeManager: CFFThemeManagerProtocol?
    var containerTopBarModel : EditorContainerModel?{
        didSet{
            setupContainerTopbar()
            setupMessageGuidenceContainer()
        }
    }
    private let postType: FeedType
    private let requestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    private var tagPicker : ASMentionSelectorViewController?
    
    @IBOutlet private weak var postEditorTable : UITableView?
    @IBOutlet private weak var createButton : UIButton?
    @IBOutlet private weak var postWithSameDepartmentCheckBox : Checkbox?
    @IBOutlet private weak var postWithSameDepartmentMessage: UILabel?
    @IBOutlet private weak var postWithSameDepartmentContainer: UIView?
    @IBOutlet private weak var tableBackgroundContainer: UIView?
    @IBOutlet private weak var messageGuidenceContainer: UIView?
    @IBOutlet private weak var guidenceMessage: UILabel?
    @IBOutlet private weak var messageGuidenceContainerHeightContraint: NSLayoutConstraint?
    var loader = CommonLoader()
    
    lazy var postCoordinator: PostCoordinator = {
        return PostCoordinator(postObsever: cellFactory, postType: postType, editablePost: editablePost)
    }()
    lazy var imageMapper : EditablePostMediaRepository = {
        return EditablePostMediaRepository(input: EditablePostMediaMapperInitModel(
            datasource: self,
            localMediaManager: localMediaManager,
            mediaFetcher: mediaFetcher,
            themeManager: themeManager
            )
        )
    }()
    
    private lazy var feedOrderManager: FeedOrderManager = {
        return FeedOrderManager()
    }()
    
    private lazy var cellFactory: PostEditorCellFactory = {
        return PostEditorCellFactory(InitPostEditorCellFactoryModel(
            datasource: self,
            delegate: self,
            localMediaManager: localMediaManager,
            targetTableView: postEditorTable,
            postImageMapper: imageMapper,
            themeManager: themeManager
            )
        )
    }()
    private weak var mediaFetcher: CFFMediaCoordinatorProtocol?
    private lazy var localMediaManager: LocalMediaManager = {
        return LocalMediaManager()
    }()
    private let editablePost : EditablePostProtocol?
    private var deferredSelectedMediaLoad : (() -> Void)?
    init(postType: FeedType, requestCoordinator : CFFNetwrokRequestCoordinatorProtocol, post: EditablePostProtocol?, mediaFetcher: CFFMediaCoordinatorProtocol?, selectedAssets : [LocalSelectedMediaItem]?, themeManager: CFFThemeManagerProtocol?){
        self.postType  = postType
        self.requestCoordinator = requestCoordinator
        self.editablePost = post
        self.mediaFetcher = mediaFetcher
        self.themeManager = themeManager
        super.init(
            nibName: "PostEditorViewController"
            , bundle: Bundle(for: PostEditorViewController.self))
        if let unwrappedAssets = selectedAssets{
            deferredSelectedMediaLoad = {
                self.postCoordinator.updateAttachedMediaItems(unwrappedAssets)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        tableBackgroundContainer?.curvedCornerControl()
        view.backgroundColor = .viewBackgroundColor
        setupTableView()
        setupCreateButton()
        setupPostWithDepartment()
        if let deferredLoad = deferredSelectedMediaLoad{
            deferredLoad()
        }
        postWithSameDepartmentContainer?.isHidden = editablePost?.remotePostId != nil
        setupMessageGuidenceContainer()
        setupCheckbox()
    }
    
    private func setupMessageGuidenceContainer(){
        if let unwrappedContainerModel = containerTopBarModel?.shouldShowGuidenceMessage{
            messageGuidenceContainerHeightContraint?.constant = unwrappedContainerModel ? 40 : 0
        }else{
            messageGuidenceContainerHeightContraint?.constant = 0
        }
        messageGuidenceContainer?.curvedCornerControl()
        messageGuidenceContainer?.backgroundColor = .guidenceViewBackgroundColor
        guidenceMessage?.font = .Body1
    }
    
    private func setupCheckbox(){
        postWithSameDepartmentCheckBox?.uncheckedBorderColor =  themeManager?.getControlActiveColor() ?? .stepperActiveColor
        postWithSameDepartmentCheckBox?.checkmarkColor =  themeManager?.getControlActiveColor() ?? .stepperActiveColor
        postWithSameDepartmentCheckBox?.checkedBorderColor =  themeManager?.getControlActiveColor() ?? .stepperActiveColor
    }
    
    private func setupPostWithDepartment() {
        postWithSameDepartmentCheckBox?.borderLineWidth = 1
        postWithSameDepartmentCheckBox?.isEnabled = postCoordinator.isDepartmentSharedWithEditable()
        postWithSameDepartmentCheckBox?.checkmarkStyle = .tick
        postWithSameDepartmentCheckBox?.isChecked = postCoordinator.isPostWithSameDepartment()
        postWithSameDepartmentCheckBox?.valueChanged = {(isChecked) in
            self.postCoordinator.updatePostWithSameDepartment(isChecked)
        }
        
        postWithSameDepartmentMessage?.text = "Post to my department only"
        postWithSameDepartmentMessage?.font = .Highlighter2
        
    }
    
    private func setupTableView(){
        postEditorTable?.tableFooterView = UIView(frame: CGRect.zero)
        postEditorTable?.rowHeight = UITableView.automaticDimension
        postEditorTable?.estimatedRowHeight = 140
        postEditorTable?.dataSource = self
        postEditorTable?.delegate = self
        cellFactory.registerTableToAllPossibleCellTypes(postEditorTable)
        postEditorTable?.reloadData()
    }
    
    private func setupCreateButton(){
        switch postType {
        case .Poll:
            createButton?.setTitle("CREATE POLL", for: .normal)
        case .Post:
            createButton?.setTitle("POST", for: .normal)
        }
        createButton?.titleLabel?.font = UIFont.Button
        createButton?.titleLabel?.tintColor = .buttonTextColor
        createButton?.backgroundColor = themeManager?.getControlActiveColor() ?? .buttonColor
        createButton?.curvedCornerControl()
    }
    
    private func setupContainerTopbar(){
        switch postType {
        case .Poll:
            containerTopBarModel?.title?.text = "CREATE POLL"
            containerTopBarModel?.cameraButton?.isHidden = true
        case .Post:
            containerTopBarModel?.title?.text = editablePost?.remotePostId == nil ? "CREATE POST" :  "EDIT POST"
            containerTopBarModel?.cameraButton?.setImage(
                UIImage(named: "camera", in: Bundle(for: PostEditorViewController.self), compatibleWith: nil),
                for: .normal
            )
            containerTopBarModel?.attachPDFButton?.setImage(
               UIImage(named: "attachmentIcon", in: Bundle(for: PostEditorViewController.self), compatibleWith: nil),
               for: .normal)
            containerTopBarModel?.attachPDFButton?.isHidden = false
            containerTopBarModel?.cameraButton?.tintColor = .black
            containerTopBarModel?.cameraButton?.addTarget(self, action: #selector(initiateMediaAttachment), for: .touchUpInside)
            containerTopBarModel?.attachPDFButton?.addTarget(self, action: #selector(initiateAttachment), for: .touchUpInside)
        }
    }
    
    @objc private func initiateAttachment(){
        let drawer = FeedAttachmentOptionsDrawerViewController(nibName: "FeedAttachmentOptionsDrawerViewController", bundle: Bundle(for: FeedAttachmentOptionsDrawerViewController.self))
        do{
            try drawer.presentDrawer()
            drawer.attachPhotosButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {[weak self] in
                drawer.dismiss(animated: true) {
                    self?.initiateMediaAttachment()
                }
            })
            drawer.attachGifButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {[weak self] in
                drawer.dismiss(animated: true) {
                    self?.initiateGifAttachment()
                }
            })
        }catch let error{
            print("show error")
            ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
            }
        }
    }
    
    private func initiateGifAttachment(){
        print("<<<<<<<< initiate gif attachment")
        let gifSelector = FeedsGIFSelectorViewController(nibName: "FeedsGIFSelectorViewController", bundle: Bundle(for: FeedsGIFSelectorViewController.self))
        gifSelector.requestCoordinator = requestCoordinator
        gifSelector.mediaFetcher = mediaFetcher
        gifSelector.feedsGIFSelectorDelegate = self
        do{
            try gifSelector.presentDrawer()
        }catch let error{
            print("show error")
            ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
            }
        }
        
    }
    
    @objc private func initiateMediaAttachment(){
        PhotosPermissionChecker().checkPermissions {[weak self] in
            self?.showImagePicker()
        }
    }
    
    private func showImagePicker(){
        AssetGridViewController.presentMediaPickerStack(
            presentationModel: MediaPickerPresentationModel(
                localMediaManager: localMediaManager,
                selectedAssets: postCoordinator.getCurrentPost().selectedMediaItems,
                assetSelectionCompletion: { (selectedMediaItems) in
                    self.updatePostWithSelectedMediaSection(selectedMediaItems: selectedMediaItems)
            },
                maximumItemSelectionAllowed: 10 - postCoordinator.getRemoteMediaCount(),
                presentingViewController: self,
                themeManager: themeManager
            )
        )
    }
    
    private func updatePostWithSelectedMediaSection(selectedMediaItems : [LocalSelectedMediaItem]?){
        postCoordinator.updateAttachedMediaItems(selectedMediaItems)
    }
    
    
    @IBAction func createButtonPressed(){
        do{
            createButton?.isUserInteractionEnabled  = false
            try postCoordinator.checkIfPostReadyToPublish()
            self.loader.showActivityIndicator(self.view)
            PostImageDataMapper(localMediaManager).prepareMediaUrlMapForPost(
            self.postCoordinator.getCurrentPost()) { (localImageUrls, error) in
                 print("here")
                if let unwrappedUrls = localImageUrls{
                    self.postCoordinator.saveLocalMediaUrls(unwrappedUrls)
                }
                if error == nil{
                    PostPublisher(networkRequestCoordinator: self.requestCoordinator).publishPost(
                    post: self.postCoordinator.getCurrentPost()) {[weak self] (callResult) in
                        DispatchQueue.main.async {
                            self?.loader.hideActivityIndicator(self?.view ?? UIView())
                            self?.createButton?.isUserInteractionEnabled  = true
                            switch callResult{
                            case .Success(let rawFeed):
                                self?.feedOrderManager.insertFeeds(
                                    rawFeeds: [rawFeed],
                                    insertDirection: self?.editablePost?.remotePostId == nil ? .Top : .Bottom,
                                    completion: {[weak self] in
                                        DispatchQueue.main.async {
                                            NotificationCenter.default.post(name: .didUpdatedPosts, object: nil)
                                            ErrorDisplayer.showError(errorMsg: self?.postCoordinator.getPostSuccessMessage() ?? "Success") { (_) in
                                                self?.dismiss(animated: true, completion: nil)
                                            }
                                        }
                                })
                                
                            case .SuccessWithNoResponseData:
                                ErrorDisplayer.showError(errorMsg: "Unable to post.") { (_) in

                                }
                            case .Failure(let error):
                                ErrorDisplayer.showError(errorMsg: "Unable to post due to \(error.displayableErrorMessage())") { (_) in

                                }
                            }
                        }
                    }
                }
                else{
                    self.createButton?.isUserInteractionEnabled  = true
                    print("<<<<<<<<<<<<<<<<<<< erorr observed \(error)")
                }
            }
        }catch let error{
            createButton?.isUserInteractionEnabled  = true
            ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
                
            }
        }
    }
}

extension PostEditorViewController: FeedsGIFSelectorDelegate{
    func finishedSelectingGif(_ gif: RawGif) {
        postCoordinator.attachGifItem(gif)
    }
}

extension PostEditorViewController : PostEditorCellFactoryDatasource{
    func getTargetPost() -> EditablePostProtocol? {
        return postCoordinator.getCurrentPost()
    }
}
extension PostEditorViewController : PostEditorCellFactoryDelegate{
    
    func removeAttachedGif() {
        postCoordinator.removeAttachedGif()
    }
    func activeDaysForPollChanged(_ days: Int) {
        postCoordinator.updateActiveDayForPoll(days)
    }
    
    func savePostOption(index: Int, option: String?) {
        postCoordinator.savePostOption(index: index, option: option)
    }
    
    func removeSelectedMedia(index : Int, mediaSection: EditableMediaSection) {
        postCoordinator.removeMedia(index: index, mediaSection: mediaSection)
    }
    
    func updatePostTitle(title: String?) {
        postCoordinator.updatePostTitle(title: title)
    }
    
    func updatePostDescription(decription: String?) {
        postCoordinator.updatePostDescription(decription: decription)
    }
    
    func reloadTextViewContainingRow(indexpath: IndexPath) {
        print("<< reload text view \(indexpath)")
        UIView.setAnimationsEnabled(false)
        postEditorTable?.beginUpdates()
        postEditorTable?.endUpdates()
        postEditorTable?.scrollToRow(at: indexpath, at: .bottom, animated: false)
        UIView.setAnimationsEnabled(true)
    }
    
    func showUserListForTagging(searckKey : String, textView: UITextView, pickerDelegate : TagUserPickerDelegate?){
        if tagPicker == nil{
                        tagPicker = ASMentionSelectorViewController(nibName: "ASMentionSelectorViewController", bundle: Bundle(for: ASMentionSelectorViewController.self))
                        tagPicker?.networkRequestCoordinator = requestCoordinator
                    }
        tagPicker?.pickerDelegate = pickerDelegate
        if let selectedRange = textView.selectedTextRange {
            let caretRect = textView.caretRect(for: selectedRange.end)
            let displayRect = textView.convert(caretRect, to: presentingViewController?.view)
            print(displayRect)
            tagPicker?.searchForUser(searckKey, displayRect: displayRect, parent: self)
        }
    }
    
    func dismissUserListForTagging(completion :(() -> Void)){
        tagPicker?.dismissTagSelector(completion)
    }
}

extension PostEditorViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellFactory.getNumberOfSection()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellFactory.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellFactory.getCell(indexPath:indexPath, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellFactory.configureCell(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellFactory.getHeight(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellFactory.getHeightOfViewForSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return cellFactory.getViewForHeaderInSection(section: section, tableView: tableView)
    }
}
