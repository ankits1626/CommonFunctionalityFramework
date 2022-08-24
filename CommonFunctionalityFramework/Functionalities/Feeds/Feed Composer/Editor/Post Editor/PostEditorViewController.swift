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
import Photos
import GiphyUISDK

extension Notification.Name{
    static let didUpdatedPosts = Notification.Name("didUpdatedPosts")
}

class PostEditorViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var themeManager: CFFThemeManagerProtocol?
    var containerTopBarModel : EditorContainerModel?{
        didSet{
            setupContainerTopbar()
            setupMessageGuidenceContainer()
        }
    }
    private let postType: FeedType
    private let requestCoordinator: CFFNetworkRequestCoordinatorProtocol
    private var tagPicker : ASMentionSelectorViewController?
    
    @IBOutlet private weak var postEditorTable : UITableView?
    @IBOutlet private weak var createButton : UIButton?
    @IBOutlet private weak var postWithSameDepartmentContainer: UIView?
    @IBOutlet private weak var tableBackgroundContainer: UIView?
    @IBOutlet private weak var parentTableView: UIView?
    @IBOutlet private weak var messageGuidenceContainer: UIView?
    @IBOutlet private weak var guidenceMessage: UILabel?
    @IBOutlet private weak var messageGuidenceContainerHeightContraint: NSLayoutConstraint?
    var loader = CommonLoader()
    var numberOfRows = 1
    var selectedGif = ""
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
            themeManager: themeManager,
            mediaFetcher: mediaFetcher
            )
        )
    }()
    private weak var mediaFetcher: CFFMediaCoordinatorProtocol?
    private lazy var localMediaManager: LocalMediaManager = {
        return LocalMediaManager()
    }()
    private let editablePost : EditablePostProtocol?
    private var deferredSelectedMediaLoad : (() -> Void)?
    init(postType: FeedType, requestCoordinator : CFFNetworkRequestCoordinatorProtocol, post: EditablePostProtocol?, mediaFetcher: CFFMediaCoordinatorProtocol?, selectedAssets : [LocalSelectedMediaItem]?, themeManager: CFFThemeManagerProtocol?){
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
    
    override func viewWillDisappear(_ animated: Bool) {
        clearTagDelegation()
    }
    
    func clearTagDelegation() {
        ASMentionCoordinator.shared.delegate = nil
        ASMentionCoordinator.shared.loadInitialText(targetTextView: nil)
        ASMentionCoordinator.shared.targetTextview?.text = ""
        ASMentionCoordinator.shared.clearMentionsTextView()
        ASMentionCoordinator.shared.textUpdateListener = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableBackgroundContainer?.roundCorners(corners: [.topLeft,.topRight], radius: 12)
    }
    
    private func setup(){
        parentTableView?.backgroundColor = UIColor.getControlColor()
        view.backgroundColor = .viewBackgroundColor
        setupTableView()
        setupCreateButton()
        if let deferredLoad = deferredSelectedMediaLoad{
            deferredLoad()
        }
        postWithSameDepartmentContainer?.isHidden = editablePost?.remotePostId != nil
        setupMessageGuidenceContainer()
    }
    
    private func setupMessageGuidenceContainer(){
        if let unwrappedContainerModel = containerTopBarModel?.shouldShowGuidenceMessage{
            messageGuidenceContainerHeightContraint?.constant = unwrappedContainerModel ? 40 : 0
        }else{
            messageGuidenceContainerHeightContraint?.constant = 0
        }
        messageGuidenceContainer?.curvedCornerControl()
        messageGuidenceContainer?.backgroundColor = .guidenceViewBackgroundColor
        guidenceMessage?.text = "Only s3 & s4 messages can be shared on this platform".localized
        guidenceMessage?.font = .Body1
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
            createButton?.setTitle("CREATE POLL".localized, for: .normal)
        case .Post:
            createButton?.setTitle("POST".localized, for: .normal)
        }
        createButton?.titleLabel?.font = UIFont.Button
        createButton?.titleLabel?.tintColor = .buttonTextColor
        createButton?.backgroundColor = themeManager?.getControlActiveColor() ?? .buttonColor
        createButton?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
    }
    
    private func setupContainerTopbar(){
        switch postType {
        case .Poll:
            containerTopBarModel?.title?.text = "CREATE POLL".localized
            containerTopBarModel?.cameraButton?.isHidden = true
        case .Post:
            containerTopBarModel?.title?.text = editablePost?.remotePostId == nil ? "CREATE POST".localized :  "EDIT POST".localized
            containerTopBarModel?.cameraButton?.setImage(
                UIImage(named: "cff_camera", in: Bundle(for: PostEditorViewController.self), compatibleWith: nil),
                for: .normal
            )
            containerTopBarModel?.attachPDFButton?.setImage(
               UIImage(named: "cff_attachmentIcon", in: Bundle(for: PostEditorViewController.self), compatibleWith: nil),
               for: .normal)
            containerTopBarModel?.attachPDFButton?.isHidden = false
            containerTopBarModel?.cameraButton?.tintColor = .black
            containerTopBarModel?.cameraButton?.addTarget(self, action: #selector(initiateMediaAttachment), for: .touchUpInside)
            containerTopBarModel?.attachPDFButton?.addTarget(self, action: #selector(initiateAttachment), for: .touchUpInside)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addTagPicker()
    }
    
    private func addTagPicker(){
        if tagPicker == nil{
                        tagPicker = ASMentionSelectorViewController(nibName: "ASMentionSelectorViewController", bundle: Bundle(for: ASMentionSelectorViewController.self))
                        tagPicker?.networkRequestCoordinator = requestCoordinator
                    }
        tagPicker?.mediaFetcher = mediaFetcher
        tagPicker?.addTagPickerToParent(self)
    }
    
    @objc private func initiateAttachment(){
        let drawer = FeedAttachmentOptionsDrawerViewController(nibName: "FeedAttachmentOptionsDrawerViewController", bundle: Bundle(for: FeedAttachmentOptionsDrawerViewController.self))
        do{
            try drawer.presentDrawer()
            drawer.attachPhotosButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {[weak self] in
                drawer.dismiss(animated: true) {
                    self?.initiateGalleryAttachment()
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
//        let gifSelector = FeedsGIFSelectorViewController(nibName: "FeedsGIFSelectorViewController", bundle: Bundle(for: FeedsGIFSelectorViewController.self))
//        gifSelector.requestCoordinator = requestCoordinator
//        gifSelector.mediaFetcher = mediaFetcher
//        gifSelector.feedsGIFSelectorDelegate = self
//        do{
//            try gifSelector.presentDrawer()
//        }catch let error{
//            print("show error")
//            ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
//            }
//        }
        
        let giphy = GiphyViewController()
        Giphy.configure(apiKey: "sUhGOw62fGSyGbWUT0hrlsfLL3gBMQ3h")
        giphy.delegate = self
        giphy.mediaTypeConfig = [.gifs, .stickers, .text, .emoji]
        GiphyViewController.trayHeightMultiplier = 1.0
        giphy.theme = GPHTheme(type: .lightBlur)
        present(giphy, animated: true, completion: nil)
        
    }
    
    @objc private func initiateMediaAttachment(){
        PhotosPermissionChecker().checkPermissions {[weak self] in
            self?.openCameraInput()
        }
    }
    
    @objc private func initiateGalleryAttachment(){
        PhotosPermissionChecker().checkPermissions {[weak self] in
            self?.showImagePicker()
        }
    }
    
    func openCameraInput(){
        let picker = UIImagePickerController()
        picker.delegate = self
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            picker.allowsEditing = false
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
            break
        case .denied:
            self.alertPromptToAllowCameraAccessViaSettings()
            break
        default:
            picker.allowsEditing = false
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
            break
        }
    }
    
    func alertPromptToAllowCameraAccessViaSettings() {
        DispatchQueue.main.async {
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName")as? String ?? ""
            let alert = UIAlertController(title: "\"\(String(describing: appName))\" Would Like To Access the Camera/Gallery", message: "Please grant permission", preferredStyle: .alert )
            alert.addAction(UIAlertAction(title: "Open Settings", style: .cancel) { alert in
                if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettingsURL)
                }
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var placeholderAsset: PHObjectPlaceholder? = nil
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        PHPhotoLibrary.shared().performChanges({
            let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeholderAsset = newAssetRequest.placeholderForCreatedAsset
        }, completionHandler: { [weak self] (sucess, error) in
            DispatchQueue.main.async {
                if sucess, let `self` = self, let identifier = placeholderAsset?.localIdentifier {
                    guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else { return }
                    AssetGridViewController.presentCameraPickerStack(presentationModel: CameraPickerPresentationModel(localMediaManager: self.localMediaManager, selectedAssets: self.postCoordinator.getCurrentPost().selectedMediaItems, assetSelectionCompletion: { (selectedMediaItems) in
                        self.updatePostWithSelectedMediaSection(selectedMediaItems: selectedMediaItems)
                    }, maximumItemSelectionAllowed: 10, presentingViewController: self, themeManager: self.themeManager, _identifier: asset.localIdentifier, _mediaType: asset.mediaType, _asset: asset))
                }
            }
        })
        self.dismiss(animated: true, completion: nil)
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
            self.loader.showActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
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
                            self?.loader.hideActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
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
                                ErrorDisplayer.showError(errorMsg: "Unable to post.".localized) { (_) in

                                }
                            case .Failure(let error):
                                ErrorDisplayer.showError(errorMsg: "\("Unable to post due to".localized) \(error.displayableErrorMessage())") { (_) in

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
    func numberOfRowsIncrement(number: Int) {
        self.numberOfRows = number
        self.postEditorTable?.beginUpdates()
        self.postEditorTable?.insertRows(at: [IndexPath(row: number - 1, section: 1)], with: .automatic)
        self.postEditorTable?.endUpdates()
    }
    
    func removeAttachedECard() {
        postCoordinator.removeAttachedECard()
    }
    
    func openPhotoLibrary() {
        self.initiateGalleryAttachment()
    }
    
    func openGif() {
        self.initiateGifAttachment()
    }
    
    func openECard() {
        let storyboard = UIStoryboard(name: "FeedEcard",bundle: Bundle(for: FeedEcardSelectViewController.self))
        let controller = storyboard.instantiateViewController(withIdentifier: "FeedEcardSelectViewController") as! FeedEcardSelectViewController
        controller.delegate = self
        controller.requestCoordinator = requestCoordinator
        controller.mediaFetcher = mediaFetcher
        do{
            try controller.presentDrawer()
        }catch let error{
            print("show error")
            ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
            }
        }
    }
    
    func createdPostType(_ isEnabled: Bool?) {
        self.postCoordinator.updatePostWithSameDepartment(isEnabled ?? false)
    }
    
    
    func removeAttachedGif() {
        postCoordinator.removeAttachedGiflyGif()
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
        postEditorTable?.scrollToRow(at: indexpath, at: .top, animated: false)
        if
            let cell = postEditorTable?.cellForRow(at: indexpath) as? FeedEditorDescriptionTableViewCell,
            let textView = cell.descriptionText,
            let confirmedTextViewCursorPosition = textView.selectedTextRange?.end {
            
            let caretPosition = textView.caretRect(for: confirmedTextViewCursorPosition)
            var textViewActualPosition = textView.convert(caretPosition, to: postEditorTable)
            textViewActualPosition.size.height +=  textViewActualPosition.size.height/2
            print( "<<<<<<<<< sroll \(textViewActualPosition)")
            postEditorTable?.scrollRectToVisible(textViewActualPosition, animated: false)
            updateTagPickerFrame(textView)
            tagPicker?.updateShadow()
        }else{
            postEditorTable?.scrollToRow(at: indexpath, at: .bottom, animated: false)
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func showUserListForTagging(searckKey : String, textView: UITextView, pickerDelegate : TagUserPickerDelegate?){
        tagPicker?.pickerDelegate = pickerDelegate
        if
            let confirmedTextViewCursorPosition = textView.selectedTextRange?.end {
            let caretPosition = textView.caretRect(for: confirmedTextViewCursorPosition)
            let textViewActualPosition = textView.convert(caretPosition, to: view)
            tagPicker?.searchForUser(
                searckKey,
                displayRect: textViewActualPosition,
                parent: self,
                shouldSearchOnlyDepartment: postCoordinator.isPostWithSameDepartment()
            )
        }
    }
    
    func updateTagPickerFrame(_ textView: UITextView?) {
        if
            let confirmedTextViewCursorPosition = textView?.selectedTextRange?.end,
            let caretPosition = textView?.caretRect(for: confirmedTextViewCursorPosition),
            let textViewActualPosition = textView?.convert(caretPosition, to: view){
            tagPicker?.updateFrameOfPicker(textViewActualPosition)
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
        return cellFactory.numberOfRowsInSection(section, numberOfRows)
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
extension  PostEditorViewController : DidTapOnEcard {
    func selectedEcard(ecardData: EcardListResponseValues) {
        postCoordinator.attachedEcardItems(_selectedECard: ecardData)
    }
    
    
}

extension PostEditorViewController: GiphyDelegate {
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia)   {
        let gifURL = media.url(rendition: .fixedWidth, fileType: .gif)
        // your user tapped a GIF!
        self.selectedGif = gifURL!
        postCoordinator.attachGifyGifItem(gifURL!)
        //        self.documentsArr.append(["Gif" : self.selectedGif])
        //self.tableView.reloadData()
        giphyViewController.dismiss(animated: true, completion: nil)
    }
    
    func didDismiss(controller: GiphyViewController?) {
        // your user dismissed the controller without selecting a GIF.
    }
}
