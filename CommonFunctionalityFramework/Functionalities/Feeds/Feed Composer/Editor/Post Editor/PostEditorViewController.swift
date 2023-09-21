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
import RewardzCommonComponents
import GiphyUISDK

enum SharePostOption : Int{
    case MyOrg = 20
    case MyDepartment = 10
    case MultiOrg = 40
    case JobFamilies = 50
    
    func displayableTitle() -> String{
        switch self {
        case .MyOrg:
            return "My Org".localized
        case .MyDepartment:
            return "My Department".localized
        case .MultiOrg:
            return "Custom".localized
        case .JobFamilies:
            return "My Job Families".localized
        }
    }
    
    static var defaultCases : [SharePostOption]{
        return [.MyOrg, .MyDepartment]
    }
    
    static var multiOrgCases : [SharePostOption]{
        return [.MyOrg, .MyDepartment, .MultiOrg]
    }
    
    static var nuhsMultiOrgCases : [SharePostOption]{
        return [.MyOrg, .MyDepartment, .JobFamilies , .MultiOrg]
    }
    
    static func getOption(_ index : Int, isNuhsMultiOrgEnabled : Bool) -> SharePostOption{
        if index == 1{
            return .MyDepartment
        }
        
        if isNuhsMultiOrgEnabled {
            if index == 3{
                return .MultiOrg
            }
            
            if index == 2{
                return .JobFamilies
            }
        }else {
            if index == 2{
                return .MultiOrg
            }
        }
        return .MyOrg
    }
}


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
    var composerDismissCompletionBlock : (() -> Void)?
    
    @IBOutlet private weak var postToLabel : UILabel?
    @IBOutlet private weak var postEditorTable : UITableView?
    @IBOutlet private weak var createButton : UIButton?
    @IBOutlet private weak var postWithSameDepartmentContainer: UIView?
    @IBOutlet private weak var postWithSameDepartmentMessage: UILabel?
    @IBOutlet private weak var tableBackgroundContainer: UIView?
    @IBOutlet private weak var parentTableView: UIView?
    @IBOutlet private weak var messageGuidenceContainer: UIView?
    @IBOutlet private weak var guidenceMessage: UILabel?
    @IBOutlet private weak var messageGuidenceContainerHeightContraint: NSLayoutConstraint?
    @IBOutlet private weak var shareWithSegmentControl: UISegmentedControl?
    @IBOutlet private weak var postWithSameDepartmentCheckBox : Checkbox?
    
    @IBOutlet weak var postWithContainerView: UIView!
    var loader = CommonLoader()
    var numberOfRows = 1
    var selectedGif = ""
    lazy var postCoordinator: PostCoordinator = {
        return PostCoordinator(
            postObsever: cellFactory,
            postType: postType,
            editablePost: editablePost
        )
    }()
    lazy var imageMapper : EditablePostMediaRepository = {[weak self] in
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
    
    private lazy var cellFactory: PostEditorCellFactory = {[weak self] in
        return PostEditorCellFactory(InitPostEditorCellFactoryModel(
            datasource: self,
            delegate: self,
            localMediaManager: localMediaManager,
            targetTableView: postEditorTable,
            postImageMapper: imageMapper,
            themeManager: themeManager,
            mediaFetcher: mediaFetcher,
            mainAppCoordinator: self?.mainAppCoordinator
        )
        )
    }()
    private weak var mediaFetcher: CFFMediaCoordinatorProtocol?
    private lazy var localMediaManager: LocalMediaManager = {
        return LocalMediaManager()
    }()
    private lazy var router: PostEditorRouter = {[weak self] in
        return PostEditorRouter(
            
            PostEditorRouterInitModel(
                mainAppCoordinator: mainAppCoordinator,
                requestCoordinator: requestCoordinator,
                feedCoordinatorDelegate: feedCoordinatorDelegate,
                routerDelegate: self,
                baseNavigationController: self?.navigationController,
                themeManager: themeManager,
                mediaFetcher: mediaFetcher,
                datasource: self,
                localMediaManager: localMediaManager,
                postImageMapper: imageMapper,
                delegate: self,
                eventListener: self
            )
        )
    }()
    private var editablePost : EditablePostProtocol?
    private var deferredSelectedMediaLoad : (() -> Void)?
    private var selectedOrganisationsAndDepartments: FeedOrganisationDepartmentSelectionModel?
    private let postType: FeedType
    private let requestCoordinator: CFFNetworkRequestCoordinatorProtocol
    private var tagPicker : ASMentionSelectorViewController?
    private weak var mainAppCoordinator : CFFMainAppInformationCoordinator?
    private weak var feedCoordinatorDelegate: FeedsCoordinatorDelegate?
    
    init(postType: FeedType, requestCoordinator : CFFNetworkRequestCoordinatorProtocol, post: EditablePostProtocol?, mediaFetcher: CFFMediaCoordinatorProtocol?, selectedAssets : [LocalSelectedMediaItem]?, themeManager: CFFThemeManagerProtocol?, selectedOrganisationsAndDepartments: FeedOrganisationDepartmentSelectionModel?, mainAppCoordinator : CFFMainAppInformationCoordinator?, feedCoordinatorDelegate: FeedsCoordinatorDelegate?){
        print("&&&&&&&&&&& editor init \(post?.parentFeedItem)")
        self.postType  = postType
        self.requestCoordinator = requestCoordinator
        self.editablePost = post
        self.editablePost?.parentFeedItem = post?.parentFeedItem
        self.mediaFetcher = mediaFetcher
        self.themeManager = themeManager
        self.selectedOrganisationsAndDepartments = selectedOrganisationsAndDepartments
        self.feedCoordinatorDelegate = feedCoordinatorDelegate
        self.mainAppCoordinator = mainAppCoordinator
        
        super.init(
            nibName: "PostEditorViewController"
            , bundle: Bundle(for: PostEditorViewController.self)
        )
        self.composerDismissCompletionBlock = {[weak self] in
            debugPrint("<<<<<<<< composerDismissCompletionBlock called")
            NotificationCenter.default.removeObserver(self)
            self?.cellFactory.clear()
            self?.clearTagDelegation()
        }
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
        postToLabel?.text = "Post to".localized
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    deinit{
        debugPrint("**************** editor deinit")
        
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
        setupPostToLabel()
        setupTableView()
        setupCreateButton()
        if let deferredLoad = deferredSelectedMediaLoad{
            deferredLoad()
        }
        postWithSameDepartmentContainer?.isHidden = editablePost?.remotePostId != nil
        setupMessageGuidenceContainer()
        setupCheckbox()
        self.postWithContainerView.isHidden = false
        setupShareWithSegmentedControl()
    }
    
    private func setupPostToLabel(){
        self.postToLabel?.font = .Caption2
        self.postToLabel?.textColor = .black44
    }
    
    private func setupShareWithSegmentedControl(){
        shareWithSegmentControl?.removeAllSegments()
        var segments = SharePostOption.defaultCases
        //        = ["My Org", "My Department"]
        
        if self.mainAppCoordinator?.isMultiOrgPostEnabled() == true{
            segments = (self.mainAppCoordinator?.isNuhsMultiOrgPostEnabled())! ? SharePostOption.nuhsMultiOrgCases : SharePostOption.multiOrgCases
        }
        let tupple = editablePost?.postSharedWith() ?? (SharePostOption.MyOrg, nil)
        var selectedIndex = 0
        for  (index, shareOption) in segments.enumerated() {
            if shareOption == tupple.0{
                selectedIndex = index
            }
            shareWithSegmentControl?.insertSegment(
                withTitle: shareOption.displayableTitle(),
                at: shareOption.rawValue,
                animated: false)
        }
        let font = UIFont.systemFont(ofSize: 10)
        shareWithSegmentControl?.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        shareWithSegmentControl?.selectedSegmentIndex = 0
        shareWithSegmentControl?.tintColor = .getControlColor()
        shareWithSegmentControl?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for:
                .selected)
        shareWithSegmentControl?.selectedSegmentIndex = selectedIndex
        if self.mainAppCoordinator?.isMultiOrgPostEnabled() == true{
            updatePostButton()
        }
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
    
    private func setupCheckbox(){
        postWithSameDepartmentCheckBox?.uncheckedBorderColor =  themeManager?.getControlActiveColor() ?? .stepperActiveColor
        postWithSameDepartmentCheckBox?.checkmarkColor =  themeManager?.getControlActiveColor() ?? .stepperActiveColor
        postWithSameDepartmentCheckBox?.checkedBorderColor =  themeManager?.getControlActiveColor() ?? .stepperActiveColor
    }
    
    private func setupPostWithDepartment() {
        postWithSameDepartmentCheckBox?.isHidden = true
        postWithSameDepartmentCheckBox?.borderLineWidth = 1
        postWithSameDepartmentCheckBox?.isEnabled = false// postCoordinator.isDepartmentSharedWithEditable()
        postWithSameDepartmentCheckBox?.checkmarkStyle = .tick
        //        postWithSameDepartmentCheckBox?.isChecked = postCoordinator.isPostWithSameDepartment()
        //        postWithSameDepartmentCheckBox?.valueChanged = {[weak self] (isChecked) in
        //            self?.postCoordinator.updatePostWithSameDepartment(isChecked)
        //        }
        //
        //        postWithSameDepartmentMessage?.text = "Post to my department only".localized
        //        postWithSameDepartmentMessage?.font = .Highlighter2
        
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
    
    //    private func setupCreateButton(){
    //        createButton?.setTitle(getCreateButtonTitle(), for: .normal)
    //        createButton?.titleLabel?.font = UIFont.Button
    //        createButton?.titleLabel?.tintColor = .buttonTextColor
    //        createButton?.backgroundColor = themeManager?.getControlActiveColor() ?? .buttonColor
    //        createButton?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
    //
    //    }
    
    private func setupCreateButton(){
        switch postType {
        case .Poll:
            createButton?.setTitle("Create".localized, for: .normal)
        case .Post:
            createButton?.setTitle("POST".localized, for: .normal)
        case .Greeting:
            break
        }
        createButton?.titleLabel?.font = UIFont.Button
        createButton?.titleLabel?.tintColor = .buttonTextColor
        createButton?.backgroundColor = themeManager?.getControlActiveColor() ?? .buttonColor
        createButton?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
    }
    
    private func getCreateButtonTitle() -> String{
        switch postType {
        case .Poll:
            return "PREVIEW POLL".localized
        case .Post:
            return "PREVIEW POST".localized
        case .Greeting:
            return "PREVIEW POST".localized
        }
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
        case .Greeting:
            break
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
    
    @objc private func openImagePickerToComposePost(){
        let drawer = FeedsImageDrawer(nibName: "FeedsImageDrawer", bundle: Bundle(for: FeedsImageDrawer.self))
        //        drawer.feedCoordinatorDeleagate = feedCoordinatorDelegate
        drawer.requestCoordinator = requestCoordinator
        drawer.mediaFetcher = mediaFetcher
        drawer.themeManager = themeManager
        drawer.delegate = self
        do{
            try drawer.presentDrawer()
        }catch let error{
            print("show error")
            ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
            }
        }
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
    
    @IBAction func createButtonPressed() {
        if self.mainAppCoordinator?.isMultiOrgPostEnabled() == true {
            do{
                //            createButton?.isUserInteractionEnabled  = false
                try postCoordinator.checkIfPostReadyToPublish()
                PostImageDataMapper(localMediaManager).prepareMediaUrlMapForPost(
                    postCoordinator.getCurrentPost()) { localImageUrls, error in
                        if let unwrappedUrls = localImageUrls{
                            self.postCoordinator.saveLocalMediaUrls(unwrappedUrls)
                        }
                        if let unwrappedError = error{
                            self.createButton?.isUserInteractionEnabled  = true
                            ErrorDisplayer.showError(
                                errorMsg: unwrappedError.localizedDescription) { _ in }
                            print("<<<<<<<<<<<<<<<<<<< erorr observed \(unwrappedError)")
                        }else{
                            self.router.routeToNextScreenFromEditor()
                        }
                    }
                
            }catch let error{
                createButton?.isUserInteractionEnabled  = true
                ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in}
            }
        }else {
            do{
                createButton?.isUserInteractionEnabled  = false
                try postCoordinator.checkIfPostReadyToPublish()
                self.loader.showActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
                PostImageDataMapper(localMediaManager).prepareMediaUrlMapForPost(
                    self.postCoordinator.getCurrentPost()) { (localImageUrls, error) in
                        if let unwrappedUrls = localImageUrls{
                            self.postCoordinator.saveLocalMediaUrls(unwrappedUrls)
                        }
                        if error == nil{
                            PostPublisher(networkRequestCoordinator: self.requestCoordinator).publishPost(
                                post: self.postCoordinator.getCurrentPost()) {[weak self] (callResult) in
                                    DispatchQueue.main.async {
                                        self?.loader.hideActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
                                        switch callResult{
                                        case .Success(let rawFeed):
                                            self?.feedOrderManager.insertFeeds(
                                                rawFeeds: [rawFeed],
                                                insertDirection: self?.editablePost?.remotePostId == nil ? .Top : .Bottom,
                                                completion: {[weak self] in
                                                    DispatchQueue.main.async {
                                                        //                                            NotificationCenter.default.post(name: .didUpdatedPosts, object: nil)
                                                        ErrorDisplayer.showError(errorMsg: self?.postCoordinator.getPostSuccessMessage() ?? "Success") { (_) in
                                                            self?.createButton?.isUserInteractionEnabled  = true
                                                            if self?.mainAppCoordinator?.isMultiOrgPostEnabled() == true {
                                                                self?.navigationController?.popViewController(animated: true)
                                                            }else {
                                                                self?.dismiss(animated: true, completion: nil)
                                                            }
                                                        }
                                                    }
                                                })
                                            
                                        case .SuccessWithNoResponseData:
                                            self?.createButton?.isUserInteractionEnabled  = true
                                            ErrorDisplayer.showError(errorMsg: "Unable to post.".localized) { (_) in
                                                
                                            }
                                        case .Failure(let error):
                                            self?.createButton?.isUserInteractionEnabled  = true
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
    
    private func postToNetwork(_ completion : @escaping ()-> Void){
        createButton?.isUserInteractionEnabled  = false
        PostPublisher(networkRequestCoordinator: self.requestCoordinator).publishPost(
            post: self.postCoordinator.getCurrentPost()) {[weak self] (callResult) in
                DispatchQueue.main.async {
                    completion()
                    self?.createButton?.isUserInteractionEnabled  = true
                    switch callResult{
                    case .Success(let rawFeed):
                        self?.feedOrderManager.insertFeeds(
                            rawFeeds: [rawFeed],
                            insertDirection: self?.editablePost?.remotePostId == nil ? .Top : .Bottom,
                            completion: {[weak self] in
                                DispatchQueue.main.async {
                                   // NotificationCenter.default.post(name: .didUpdatedPosts, object: nil)
                                    ErrorDisplayer.showError(errorMsg: self?.postCoordinator.getPostSuccessMessage() ?? "Success") { (_) in
                                        self?.clearTagDelegation()
                                        if self?.mainAppCoordinator?.isMultiOrgPostEnabled() == true{
                                            self?.navigationController?.popToRootViewController(animated: false)
                                        }else {
                                            self?.dismiss(animated: true, completion: nil)
                                        }
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
        self.openImagePickerToComposePost()
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
        print("<< PostEditorViewController reload text view \(indexpath)")
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
            print( "<<<<<<<<< PostEditorViewController scroll \(textViewActualPosition)")
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
    
    func triggerAmplify() {
        debugPrint("<<<<<<< trigger amplify")
        if let amplifyInputModel = postCoordinator.getAmplifyInputModel(){
            router.routeToAmplifyScreen(amplifyInputModel, delegate: self)
        }else{
            router.routeToAmplifyErrorScreen()
        }
    }
}

extension PostEditorViewController : InspireMeDelegate{

    
    private func triggerAmplifyFeed(_ amplifyInputModel: AmplifyRequestHelperProtocol){
        
    }
    
    func aiText(userText: String){
        postCoordinator.parseAmplifiedtext(userText) {[weak self] in
            self?.updatePollOptionsAfterAmplifyIfRequired()
        }
        postEditorTable?.reloadData()
    }
    
    private func updatePollOptionsAfterAmplifyIfRequired(){
        if postCoordinator.postType == .Poll{
            numberOfRows = postCoordinator.getCurrentPost().pollOptions?.count ?? 0
            numberOfRows  = min(4, numberOfRows + 1) 
            postEditorTable?.reloadData()
//            numberOfRowsIncrement(number: numberOfRows + 1)
        }
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

extension PostEditorViewController{
    @IBAction func segmentControlSelectionChanged(){
        if self.mainAppCoordinator?.isMultiOrgPostEnabled() == true{
            updatePostButton()
        }
        if let selectedIndex = shareWithSegmentControl?.selectedSegmentIndex{
            let selectedSharePostOption = SharePostOption.getOption(selectedIndex, isNuhsMultiOrgEnabled: self.mainAppCoordinator?.isNuhsMultiOrgPostEnabled() ?? false)
            switch selectedSharePostOption {
            case .MyOrg:
                fallthrough
            case .JobFamilies:
                fallthrough
            case .MyDepartment:
                postCoordinator.updatePostShareOption(selectedSharePostOption, selectedOrganisationsAndDepartments: nil)
            case .MultiOrg:
                postCoordinator.updatePostShareOption(selectedSharePostOption, selectedOrganisationsAndDepartments: selectedOrganisationsAndDepartments)
            }
        }
    }
    
    private func updatePostButton(){
        if let selectedIndex = shareWithSegmentControl?.selectedSegmentIndex{
            switch SharePostOption.getOption(selectedIndex, isNuhsMultiOrgEnabled: self.mainAppCoordinator?.isNuhsMultiOrgPostEnabled() ?? false) {
            case .MyOrg:
                fallthrough
            case .JobFamilies:
                fallthrough
            case .MyDepartment:
                createButton?.setTitle(getCreateButtonTitle(), for: .normal)
            case .MultiOrg:
                createButton?.setTitle("Select Org/Dept".localized.uppercased(), for: .normal)
            }
        }
    }
}


extension PostEditorViewController : PostEditorRouterDelegate{
    func getPreviewablePost() -> PreviewablePost {
        return PreviewablePost(
            postCoordinator.getCurrentPost(),
            mediaRepository: imageMapper,
            mainppCoordinator: mainAppCoordinator
        )
    }
    
    func selectedSharePostOption() -> SharePostOption {
        if let selectedShareOptionIndex = shareWithSegmentControl?.selectedSegmentIndex{
            return SharePostOption.getOption(selectedShareOptionIndex, isNuhsMultiOrgEnabled: self.mainAppCoordinator?.isNuhsMultiOrgPostEnabled() ?? false)
        }else{
            return SharePostOption.MyOrg
        }
    }
    
    func saveOrganisationAndDepartmentSelection(_ selectedOrganisationsAndDepartments: FeedOrganisationDepartmentSelectionModel?){
        self.selectedOrganisationsAndDepartments = selectedOrganisationsAndDepartments
        postCoordinator.updatePostShareOption(.MultiOrg, selectedOrganisationsAndDepartments: selectedOrganisationsAndDepartments)
    }
    
    func getSavedOrganisationAndDepartmentSelection() -> FeedOrganisationDepartmentSelectionModel?{
        return self.selectedOrganisationsAndDepartments
    }
}

extension PostEditorViewController : PostPreviewViewEventListener{
    func postTriggered(_ completion: @escaping () -> Void) {
        self.postToNetwork(completion)
    }
}

extension  PostEditorViewController : DidTapOnEcard {
    func selectedEcard(ecardData: EcardListResponseValues) {
        postCoordinator.attachedEcardItems(_selectedECard: ecardData)
    }
    
    
}

extension PostEditorViewController: GiphyDelegate {
    func didSelectMedia(giphyViewController: GiphyViewController, media: GPHMedia)   {
        let gifURL = media.url(rendition: .downsized, fileType: .gif)
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
extension PostEditorViewController:  FeedsImageDelegate {
    func selectedImageType(isCamera : Bool) {
        if isCamera {
            PhotosPermissionChecker().checkPermissions {[weak self] in
                self?.openCameraInput()
            }
        }else{
            PhotosPermissionChecker().checkPermissions {[weak self] in
                self?.showImagePicker()
            }
        }
    }
}
