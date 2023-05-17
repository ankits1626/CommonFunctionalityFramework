//
//  FeedsViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/03/20.
//  Copyright © 2020 Rewardz Private Limited. All rights reserved.
//

import UIKit
import CoreData
import Photos
import RewardzCommonComponents

class FeedsViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet private weak var composeBarContainerHeightConstraint : NSLayoutConstraint?
    @IBOutlet private weak var composeLabel : UILabel?
    @IBOutlet private weak var feedsTable : UITableView?
    @IBOutlet private weak var whatsInYourMindView : UIView?
    @IBOutlet private weak var cameraContainerViewView : UIView?
    @IBOutlet private weak var feedCreateView : UIView?
    @IBOutlet weak var createBtnHolderView: UIView!
    @IBOutlet private weak var feedCreateViewConstraints : NSLayoutConstraint?
    var selectedTab = ""
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var feedCoordinatorDelegate: FeedsCoordinatorDelegate!
    var themeManager: CFFThemeManagerProtocol?
    var mainAppCoordinator : CFFMainAppInformationCoordinator?
    var bottomSafeArea : CGFloat!
    var loader = MFLoader()
    var shouldShowCreateButton: Bool = false
    var isComingFromProfilePage : Bool = false
    var searchText : String?
    @IBOutlet weak var emptyViewContainer : UIView?
    lazy private var emptyResultView: NoEntryViewController = {
        return NoEntryViewController(
            nibName: "NoEntryViewController",
            bundle: Bundle(for: NoEntryViewController.self)
        )
    }()
    lazy var feedSectionFactory: FeedSectionFactory = {
        return FeedSectionFactory(
            feedsDatasource: self,
            mediaFetcher: mediaFetcher,
            targetTableView: feedsTable,
            selectedOptionMapper: pollSelectedAnswerMapper,
            themeManager: themeManager, selectedTab: selectedTab
        )
    }()
    
    lazy var pollSelectedAnswerMapper: SelectedPollAnswerMapper = {
        return SelectedPollAnswerMapper()
    }()
    
    private var lastFetchedFeeds : FetchedFeedModel?
    
    private lazy var refreshControl : UIRefreshControl  = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFeeds), for: .valueChanged)
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .gray
        return refreshControl
    }()
    
    private var frc : NSFetchedResultsController<ManagedPost>?
    private var pollAnswerSubmitter : PollAnswerSubmitter?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(scrollTableView(notification:)), name: NSNotification.Name(rawValue: "PostScroll"), object: nil)
        feedCreateView?.layer.cornerRadius = (feedCreateView?.frame.size.width)!/2
        feedCreateView?.clipsToBounds = true
        feedCreateView?.backgroundColor = UIColor.getControlColor()
        registerForPostUpdateNotifications()
        clearAnyExistingFeedsData {[weak self] in
            self?.initializeFRC()
            self?.setup()
            self?.loadFeeds()
        }
        self.feedsTable?.showsVerticalScrollIndicator = false
    }
    
    @objc func scrollTableView(notification: NSNotification) {
        
        if let paymentData = notification.object as? Dictionary<String, Any> {
            if let paymentID = paymentData["isScrollable"] as? Bool {
                print("paymentID ----- \(paymentID)")
                self.feedsTable?.bounces = true
                self.feedsTable?.isScrollEnabled = paymentID
            }
        }
    }
    
    deinit {
        print("Notification deinit")
    }
    
    private func registerForPostUpdateNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFeeds), name: NSNotification.Name.didUpdatedPosts, object: nil)
    }
    
    func clearAnyExistingFeedsData(_ completion: @escaping (() -> Void)){
        CFFCoreDataManager.sharedInstance.manager.deleteAllObjetcs(type: ManagedPost.self) {
            DispatchQueue.main.async {
                CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                completion()
            }
        }
    }
    
    private func initializeFRC() {
        let fetchRequest: NSFetchRequest<ManagedPost> = ManagedPost.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdTimeStamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CFFCoreDataManager.sharedInstance.manager.mainQueueContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc?.delegate = self
        do {
            try frc?.performFetch()
            feedsTable?.reloadData()
        } catch let error {
            print("<<<<<<<<<< error \(error.localizedDescription)")
        }
    }
    
    @objc private func refreshFeeds(){
        clearAnyExistingFeedsData {[weak self] in
            self?.lastFetchedFeeds = nil
            self?.loadFeeds()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.loader.hideActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
    }
    
    @objc private func bottomLoader(){
        if !(lastFetchedFeeds?.nextPageUrl?.isEmpty ?? true) {
            loadFeeds()
        }else{
            self.feedsTable?.loadCFFControl?.endLoading()
        }
    }
    
    @objc private func loadFeeds(){
        self.loader.showActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
        FeedFetcher(networkRequestCoordinator: requestCoordinator).fetchFeeds(
            nextPageUrl: lastFetchedFeeds?.nextPageUrl, feedType: "postPoll", searchText: searchText,isComingFromProfile: self.isComingFromProfilePage) {[weak self] (result) in
            DispatchQueue.main.async {
                self?.feedsTable?.loadCFFControl?.endLoading()
                switch result{
                case .Success(let result):
                    if result.fetchedRawFeeds?.count == 0 {
                        self?.loader.hideActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
                    }
//                    if let resultCount = result.fetchedRawFeeds?["results"] as? NSArray  {
//                        if resultCount.count == 0 {
//                            var emptyMessage : String!
//                            emptyMessage = "No Records Found!"
//                            self?.emptyResultView.showEmptyMessageView(
//                                message: emptyMessage,
//                                parentView: self!.emptyViewContainer!,
//                                parentViewController: self!
//                            )
//                        }else{
//                            self?.emptyResultView.hideEmptyMessageView()
//                        }
//                    }
                    
                    
                    self?.handleFetchedFeedsResult(fetchedfeeds: result)
                    self?.handleaddButton(fetchedfeeds: result)
                case .SuccessWithNoResponseData:
                    ErrorDisplayer.showError(errorMsg: "No record Found".localized) { (_) in}
                case .Failure(let error):
                    ErrorDisplayer.showError(errorMsg: error.displayableErrorMessage()) { (_) in}
                }
            }
        }
    }
    
    
    func handleaddButton(fetchedfeeds : FetchedFeedModel) {
        if fetchedfeeds.fetchedRawFeeds?.count == 0 {
            feedCreateViewConstraints?.constant = UIScreen.main.bounds.height / 3 + 110
        }else if fetchedfeeds.fetchedRawFeeds?.count == 1 {
            feedCreateViewConstraints?.constant = UIScreen.main.bounds.height / 3 + 110
        }else{
            if #available(iOS 11.0, *) {
                bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
            }else{
                bottomSafeArea = 0.0
            }
            if bottomSafeArea == 0.0 {
                feedCreateViewConstraints?.constant = 40
            }else{
                feedCreateViewConstraints?.constant = 25
            }
        }
    }
    
    private func handleFetchedFeedsResult (fetchedfeeds : FetchedFeedModel){
        self.lastFetchedFeeds = fetchedfeeds
        loadfetchedFeeds()
    }
    
    private func loadfetchedFeeds(){
        if let fetchedFeeds = lastFetchedFeeds?.fetchedRawFeeds?["results"] as? [[String : Any]]{
            CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                fetchedFeeds.forEach { (aRawFeed) in
                    let rawFeed = RawFeed(input: aRawFeed)
                    let _ = rawFeed.getManagedObject() as! ManagedPost
                    if let unwrappedDescription = rawFeed.getFeedDescription(){
                        FeedDescriptionMarkupParser.sharedInstance.updateDescriptionParserOutputModelForFeed(
                            feedId: rawFeed.feedIdentifier,
                            description: unwrappedDescription
                        )
                    }
                }
                
                CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                    CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                }
            }
        }
        DispatchQueue.main.async {[weak self] in
            self?.feedsTable?.loadCFFControl?.endLoading()
            self?.refreshControl.endRefreshing()
            self?.feedsTable?.reloadData()
        }
    }
    
    private func setup(){
        view.backgroundColor = .viewBackgroundColor
        self.createBtnHolderView.isHidden = shouldShowCreateButton ? true : false
        setupTopBar()
        setupTableView()
    }
    
    private func setupTopBar(){
        if let unwrappedCanUserCreatePost = self.mainAppCoordinator?.isUserAllowedToPostFeed(),
           unwrappedCanUserCreatePost == false{
            composeBarContainerHeightConstraint?.constant = 0
        }
        whatsInYourMindView?.curvedCornerControl()
        whatsInYourMindView?.backgroundColor = UIColor.grayBackGroundColor()
        cameraContainerViewView?.curvedCornerControl()
        cameraContainerViewView?.backgroundColor = UIColor.grayBackGroundColor()
        composeLabel?.text = "Whats on your mind".localized
        composeLabel?.font = .Highlighter1
        composeLabel?.textColor = .getSubTitleTextColor()
    }
    
    private func setupTableView(){
        feedsTable?.addSubview(refreshControl)
        feedsTable?.tableFooterView = UIView(frame: CGRect.zero)
        feedsTable?.rowHeight = UITableView.automaticDimension
        feedsTable?.estimatedRowHeight = 500
        feedsTable?.dataSource = self
        feedsTable?.delegate = self
        feedsTable?.loadCFFControl = CFFLoadControl(target: self, action: #selector(bottomLoader))
        feedsTable?.loadCFFControl?.tintColor = .gray
        feedsTable?.loadCFFControl?.heightLimit = 100.0
    }
}

extension FeedsViewController{
    
    @IBAction func openFeedComposerSelectionDrawer(){
        continueWithFeedCreation(nil, nil)
    }
    
    private func triggerMutiOrgPath(){
        let orgPicker = FeedOrganisationSelectionViewController(
            FeedOrganisationSelectionInitModel(
                requestCoordinator: requestCoordinator,
                selectionCompletionHandler: { [weak self] selectedOrganisationsAndDeparments,displayable  in
                    self?.continueWithFeedCreation(selectedOrganisationsAndDeparments, displayable)
                })
        )
        feedCoordinatorDelegate.showMultiOrgPicker(orgPicker, presentationOption: .Navigate) { topBarModel in
            orgPicker.containerTopBarModel = topBarModel
        }
    }
    
    private func continueWithFeedCreation(_ selectedOrganisationsAndDeparments: FeedOrganisationDepartmentSelectionModel?, _ displayable : FeedOrganisationDepartmentSelectionDisplayModel?){
        let drawer = FeedsComposerDrawer(nibName: "FeedsComposerDrawer", bundle: Bundle(for: FeedsComposerDrawer.self))
        drawer.mainAppCoordinator = mainAppCoordinator
        drawer.feedCoordinatorDeleagate = feedCoordinatorDelegate
        drawer.requestCoordinator = requestCoordinator
        drawer.mediaFetcher = mediaFetcher
        drawer.themeManager = themeManager
        drawer.selectedOrganisationsAndDepartment = selectedOrganisationsAndDeparments
        drawer.displayable = displayable
        
        do{
            if let unwrappedCanUserCreatePost = self.mainAppCoordinator?.isUserAllowedToCreatePoll(),
               unwrappedCanUserCreatePost == false{
                try drawer.opnPostViewController()
            }else{
                try drawer.presentDrawer()
            }
        }catch let error{
            print("show error")
            ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
            }
        }
    }
    
    @IBAction func openImagePickerToComposePost(){
        let drawer = FeedsImageDrawer(nibName: "FeedsImageDrawer", bundle: Bundle(for: FeedsImageDrawer.self))
        drawer.mainAppCoordinator = mainAppCoordinator
        drawer.feedCoordinatorDeleagate = feedCoordinatorDelegate
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
                    AssetGridViewController.presentCameraPickerStack(presentationModel: CameraPickerPresentationModel(localMediaManager: LocalMediaManager(), selectedAssets: nil, assetSelectionCompletion: { (selectedMediaItems) in
                        FeedComposerCoordinator(
                            delegate: self.feedCoordinatorDelegate,
                            requestCoordinator: self.requestCoordinator,
                            mediaFetcher: self.mediaFetcher,
                            selectedAssets: selectedMediaItems,
                            themeManager: self.themeManager,
                            selectedOrganisationsAndDepartments: nil,
                            mainAppCoordinator: self.mainAppCoordinator
                        ).showFeedItemEditor(type: .Post)
                    }, maximumItemSelectionAllowed: 10, presentingViewController: self, themeManager: self.themeManager, _identifier: asset.localIdentifier, _mediaType: asset.mediaType, _asset: asset))
                }
            }
        })
        dismiss(animated: true, completion: nil)
    }
    private func showImagePicker(){
        AssetGridViewController.presentMediaPickerStack(
            presentationModel: MediaPickerPresentationModel(
                localMediaManager: LocalMediaManager(),
                selectedAssets: nil,
                assetSelectionCompletion: { (selectedMediaItems) in
                    FeedComposerCoordinator(
                        delegate: self.feedCoordinatorDelegate,
                        requestCoordinator: self.requestCoordinator,
                        mediaFetcher: self.mediaFetcher,
                        selectedAssets: selectedMediaItems,
                        themeManager: self.themeManager,
                        selectedOrganisationsAndDepartments: nil,
                        mainAppCoordinator: self.mainAppCoordinator
                    ).showFeedItemEditor(type: .Post)
            }, maximumItemSelectionAllowed: 10, presentingViewController: self, themeManager: themeManager
            )
        )
    }
    
}

extension FeedsViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedSectionFactory.getNumberOfSections()
//
//        if feedSectionFactory.getNumberOfSections() > 0 {
//                //self.feedsTable?.backgroundView = nil
//                //self.feedsTable?.separatorStyle = .singleLine
//                return feedSectionFactory.getNumberOfSections()
//            }
//
//            let rect = CGRect(x: 0,
//                              y: 0,
//                              width: self.feedsTable?.bounds.size.width ?? 360,
//                              height: self.feedsTable?.bounds.size.height ?? 360)
//            let noDataLabel: UILabel = UILabel(frame: rect)
//            noDataLabel.text = "No Records Found!"
//            noDataLabel.textColor = .black
//            noDataLabel.textAlignment = NSTextAlignment.center
//            self.feedsTable?.backgroundView = noDataLabel
//            self.feedsTable?.separatorStyle = .none
//
//            return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedSectionFactory.getNumberOfRows(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return  feedSectionFactory.getCell(indexPath: indexPath, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        feedSectionFactory.configureCell(cell: cell, indexPath: indexPath, delegate: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        feedSectionFactory.getHeightOfCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if getFeedItem(indexPath.section).shouldShowDetail(){
            UserDefaults.standard.setValue(false, forKey: "notRefreshFeedDetail")
            let feedDetailVC = FeedsDetailViewController(nibName: "FeedsDetailViewController", bundle: Bundle(for: FeedsDetailViewController.self))
            feedDetailVC.mainAppCoordinator = mainAppCoordinator
            feedDetailVC.themeManager = themeManager
            feedDetailVC.mainAppCoordinator = mainAppCoordinator
            feedDetailVC.targetFeedItem = getFeedItem(indexPath.section) //feeds[indexPath.section]
            feedDetailVC.mediaFetcher = mediaFetcher
            feedDetailVC.requestCoordinator = requestCoordinator
            feedDetailVC.feedCoordinatorDelegate = feedCoordinatorDelegate
            feedDetailVC.pollSelectedAnswerMapper = pollSelectedAnswerMapper
            feedDetailVC.isPostPollType = true
            feedCoordinatorDelegate.showFeedDetail(feedDetailVC)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadCFFControl?.update()
        if scrollView.contentOffset.y <= 0
        {
            scrollView.contentOffset = .zero
        }
    }
}

extension FeedsViewController : FeedsDelegate{
    func showPostReactions(feedIdentifier: Int64) {
        let storyboard = UIStoryboard(name: "CommonFeeds",bundle: Bundle(for: CommonFeedsViewController.self))
        let controller = storyboard.instantiateViewController(withIdentifier: "BOUSReactionsListViewController") as! BOUSReactionsListViewController
        controller.postId = Int(feedIdentifier)
        controller.requestCoordinator = requestCoordinator
        controller.mediaFetcher = mediaFetcher
        self.tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideMenuButton"), object: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func postReaction(feedId: Int64, reactionType: String) {
        if let feed = getFeedItem(feedIdentifier: feedId){
            if let reactionId = reactionType as? String{
                BOUSReactionPostWorker(networkRequestCoordinator: requestCoordinator).postReaction(postId: Int(feedId), reactionType: Int(reactionId)!){ (result) in
                    DispatchQueue.main.async {
                        switch result{
                        case .Success(result: let result):
                            CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                                let post = ((feed as? RawObjectProtocol)?.getManagedObject() as? ManagedPost)
                                if let likesResult =  result as? NSDictionary {
                                    if let dataVal = likesResult["post_reactions"] as? NSArray {
                                        post?.reactionTypesData =  dataVal
                                        post?.messageType = Int64(likesResult.object(forKey: "reaction_type") as? Int ?? -1)
                                        post?.numberOfLikes = Int64(dataVal.count)
                                    }
                                }
                                CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                                    CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                                }
                            }
                            
                            break
                        case .SuccessWithNoResponseData:
                            fallthrough
                        case .Failure(_):
                            ErrorDisplayer.showError(errorMsg: "Failed to post, please try again.".localized) { (_) in}
                        }
                    }
                }
                
            }
        }
    }
    
    func showPostReactions() {
        
    }
    
    func toggleLikeForComment(commentIdentifier: Int64) {
        
    }
    
    func pinToPost(feedIdentifier : Int64, isAlreadyPinned: Bool) {
        print("<<<<<<Feed identifier-\(feedIdentifier)")
        showPintoPostConfirmation(feedIdentifier, isAlreadyPinned: isAlreadyPinned)
    }
        
    private func showPintoPostConfirmation(_ feedIdentifier : Int64, isAlreadyPinned: Bool){
        let pinPostDrawer = PintoTopConfirmationDrawer(
            nibName: "PintoTopConfirmationDrawer",
            bundle: Bundle(for: PintoTopConfirmationDrawer.self)
        )
        pinPostDrawer.themeManager = themeManager
        pinPostDrawer.isAlreadyPinned = isAlreadyPinned
        pinPostDrawer.targetFeed = getFeedItem(feedIdentifier: feedIdentifier)
        pinPostDrawer.confirmedCompletion = {postFrequency in
            PostPinWorker(networkRequestCoordinator: self.requestCoordinator).postPin(feedIdentifier, frequency: postFrequency) { (result) in
                DispatchQueue.main.async {
                    switch result{
                    case .Success(_):
                        ErrorDisplayer.showError(errorMsg: isAlreadyPinned ? "Poll is unpinned successfully".localized : "Poll is pinned successfully".localized, okActionHandler: { (_) in
                          NotificationCenter.default.post(name: .didUpdatedPosts, object: nil)
                        })
                    case .SuccessWithNoResponseData:
                        fallthrough
                    case .Failure(_):
                        ErrorDisplayer.showError(errorMsg: "Failed to pin poll, please try again.".localized) { (_) in}
                    }
                }
            }
        }
        do{
            try pinPostDrawer.presentDrawer()
        }catch {
            
        }
    }
    
    func showAllClaps(feedIdentifier: Int64) {
        print("show all claps for \(feedIdentifier)")
        let likeListVC = LikeListViewController(
            feedIdentifier: feedIdentifier,
            requestCoordinator: requestCoordinator,
            mediaFetcher: mediaFetcher
        )
        feedCoordinatorDelegate.showPostLikeList(likeListVC, presentationOption: .Navigate) { (topBarModel) in
            likeListVC.containerTopBarModel = topBarModel
        }
    }
    
    func submitPollAnswer(feedIdentifier : Int64){
        print("post answer")
        if let selectedOption = pollSelectedAnswerMapper.getSelectedOption(feedIdentifier: feedIdentifier){
            PollAnswerSubmitter(networkRequestCoordinator: requestCoordinator, feedIdentifier: feedIdentifier, answer: selectedOption).submitAnswer { (result) in
                switch result{
                case .Success(result: let result):
                    print("<<<<<<<< update raw poll after answer submission")
                    DispatchQueue.main.async {[weak self] in
                        self?.pollSelectedAnswerMapper.removeSelectedOptionAfterAnswerIsPosted(feedIdentifier: feedIdentifier)
                    }
                    CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                        let _ = result.getManagedObject() as! ManagedPost
                        CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                            CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                        }
                    }
                    
                case .SuccessWithNoResponseData:
                    fallthrough
                case .Failure(error: _):
                    print("<<<<<<<<<< like/unlike call completed \(result)")
                }
                
            }
        }else{
            ErrorDisplayer.showError(errorMsg: "Please select an option.".localized) { (_) in
                
            }
        }
    }
    
    func selectPollAnswer(feedIdentifier : Int64, pollOption: PollOption){
        print("select answer for feed \(feedIdentifier), answer : \(pollOption.getNewtowrkPostableAnswer())")
        pollSelectedAnswerMapper.toggleOptionSelection(pollId: feedIdentifier, selectedOption: pollOption)
        //reload cells
        if let feedItem = getFeedItem(feedIdentifier: feedIdentifier){
            CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                let post = ((feedItem as? RawObjectProtocol)?.getManagedObject() as? ManagedPost)
                post?.pollUpdatedTrigger = NSDate()
                CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                    CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                }
            }
        }
    }
    
    func toggleClapForPost(feedIdentifier: Int64) {
        if let feed = getFeedItem(feedIdentifier: feedIdentifier){
            FeedClapToggler(networkRequestCoordinator: requestCoordinator).toggleLike(feed) { (result) in
                switch result{
                case .Success(result: let result):
                    CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                        let post = ((feed as? RawObjectProtocol)?.getManagedObject() as? ManagedPost)
                        post?.isLikedByMe = result.isLiked
                        post?.numberOfLikes = result.totalLikeCount
                        CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                            CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                        }
                    }
                case .SuccessWithNoResponseData:
                    fallthrough
                case .Failure(error: let _):
                    print("<<<<<<<<<< like/unlike call completed \(result)")
                }
                
            }
        }
    }
    
    private func getFeedItem(feedIdentifier: Int64) -> FeedsItemProtocol?{
        let fetchRequest = NSFetchRequest<ManagedPost>(entityName: "ManagedPost")
        fetchRequest.predicate = NSPredicate (format: "postId == %d", feedIdentifier)
        do{
            let filterfilteredFeeds = try CFFCoreDataManager.sharedInstance.manager.mainQueueContext.fetch(fetchRequest)
            return filterfilteredFeeds.first?.getRawObject() as! FeedsItemProtocol
        }catch{
            return nil
        }
    }
    
    func showMediaBrowser(feedIdentifier: Int64, scrollToItemIndex: Int) {
        if let feed =  getFeedItem(feedIdentifier: feedIdentifier),
            let mediaItems = feed.getMediaList(){
            let mediaBrowser = CFFMediaBrowserViewController(
                mediaList: mediaItems,
                mediaFetcher: mediaFetcher,
                selectedIndex: scrollToItemIndex
            )
            present(mediaBrowser, animated: true, completion: nil)
        }
    }
    
    func showLikedByUsersList() {
        
    }
    
    func showFeedEditOptions(targetView : UIView?, feedIdentifier : Int64) {
        print("show edit option")
        var numberofElementsEnabled : CGFloat = 0.0
        if let feed =  getFeedItem(feedIdentifier: feedIdentifier){
            var options = [FloatingMenuOption]()
            if feed.getFeedType() == .Post,
               feed.isFeedEditAllowed(){
                options.append(
                    FloatingMenuOption(title: "EDIT".localized, action: {[weak self] in
                        print("Edit post - \(feedIdentifier)")
                        self?.openFeedEditor(feed)
                    }
                                      )
                )
            }
            
            if feed.isLoggedUserAdmin()  == true{
                numberofElementsEnabled = numberofElementsEnabled + 1
            }

            if feed.isFeedDeleteAllowed() == true{
                numberofElementsEnabled = numberofElementsEnabled + 1
            }
            if feed.isFeedReportAbuseAllowed() == true{
                numberofElementsEnabled = numberofElementsEnabled + 1
            }
            
            drawer.isPintoPostEnabled = feed.isLoggedUserAdmin()
            drawer.isDeleteEnabled = feed.isFeedDeleteAllowed()
            drawer.isreportAbusedEnabled = feed.isFeedReportAbuseAllowed()
            do{
                try drawer.presentDrawer(numberofElementsEnabled: numberofElementsEnabled)
            }catch let error{
                print("show error")
                ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
                }
            }
        }
    }
    
    private func openFeedEditor(_ feed : FeedsItemProtocol){
        FeedComposerCoordinator(
            delegate: feedCoordinatorDelegate,
            requestCoordinator: requestCoordinator,
            mediaFetcher: mediaFetcher,
            selectedAssets: nil,
            themeManager: themeManager,
            selectedOrganisationsAndDepartments: nil,
            mainAppCoordinator: mainAppCoordinator
        ).editPost(feed: feed)
    }
    
    private func showDeletePostConfirmation(_ feedIdentifier : Int64){
        let deleteConfirmationDrawer = DeletePostConfirmationDrawer(
            nibName: "DeletePostConfirmationDrawer",
            bundle: Bundle(for: DeletePostConfirmationDrawer.self)
        )
        deleteConfirmationDrawer.themeManager = themeManager
        deleteConfirmationDrawer.targetFeed = getFeedItem(feedIdentifier: feedIdentifier)
        deleteConfirmationDrawer.deletePressedCompletion = {[weak self] in
            print("<<<<<<<<< proceed with feed delete \(feedIdentifier)")
            if let unwrappedSelf = self{
                PostDeleteWorker(networkRequestCoordinator: unwrappedSelf.requestCoordinator).deletePost(feedIdentifier) { (result) in
                    switch result{
                    case .Success(result: _):
                        DispatchQueue.main.async {[weak self] in
                            if let feedItem = self?.getFeedItem(feedIdentifier: feedIdentifier){
                                CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                                    if let post = ((feedItem as? RawObjectProtocol)?.getManagedObject() as? ManagedPost){
                                        CFFCoreDataManager.sharedInstance.manager.deleteManagedObject(managedObject: post, context: CFFCoreDataManager.sharedInstance.manager.privateQueueContext)
                                        CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                                            print("<<<<<<<<<<<<<poll deleted suceessfully")
                                            CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                                        }
                                    }
                                }
                                ErrorDisplayer.showError(errorMsg: "Deleted successfully.".localized) { (_) in}
                            }
                        }
                    case .SuccessWithNoResponseData:
                        fallthrough
                    case .Failure(error: _):
                        print("<<<<< Unable to delete post")
                    }
                }
            }
        }
        do{
            try deleteConfirmationDrawer.presentDrawer()
        }catch {
            
        }
    }
    
    private func showReportAbuseConfirmation(_ feedIdentifier : Int64){
        let reportAbuseConfirmationDrawer = ReportAbuseConfirmationDrawer(
            nibName: "ReportAbuseConfirmationDrawer",
            bundle: Bundle(for: ReportAbuseConfirmationDrawer.self)
        )
        reportAbuseConfirmationDrawer.themeManager = themeManager
        reportAbuseConfirmationDrawer.targetFeed = getFeedItem(feedIdentifier: feedIdentifier)
        reportAbuseConfirmationDrawer.confirmPressedCompletion = {notes in
            print("<<<<<<<<< proceed with feed delete \(feedIdentifier)")
            ReportAbuseWorker(networkRequestCoordinator: self.requestCoordinator).reportAbusePost(feedIdentifier, notes: notes) { (result) in
                DispatchQueue.main.async {
                    switch result{
                    case .Success(_):
                        ErrorDisplayer.showError(errorMsg: "Reported successfully.".localized) { (_) in}
                    case .SuccessWithNoResponseData:
                        fallthrough
                    case .Failure(_):
                        ErrorDisplayer.showError(errorMsg: "Failed to report, please try again.".localized) { (_) in}
                    }
                }
                
            }
        }
        do{
            try reportAbuseConfirmationDrawer.presentDrawer()
        }catch {
            
        }
    }
}


extension FeedsViewController : FeedsDatasource{
    func getPostShareOption() -> SharePostOption {
        return .MyOrg //dummy will be changes if we plan to show selected org/department on feed detail
    }
    
    func getPostSharedWithOrgAndDepartment() -> FeedOrganisationDepartmentSelectionDisplayModel? {
        return nil
    }
    
    
    func shouldShowMenuOptionForFeed() -> Bool {
        return mainAppCoordinator?.isUserAllowedToPostFeed() ?? true
    }
    
    func getCommentProvider() -> FeedsDetailCommentsProviderProtocol? {
        return nil
    }
    
    func getTargetPost() -> EditablePostProtocol? {
        return nil
    }
    
    func showShowFullfeedDescription() -> Bool {
        return false
    }
    
    func getFeedItem() -> FeedsItemProtocol! {
        return nil
    }
    
    func getClappedByUsers() -> [ClappedByUser]? {
        return nil
    }
    
    func getComments() -> [FeedComment]? {
        return nil
    }
    
    func getNumberOfItems() -> Int {
        //return feeds.count
        guard let sections = frc?.sections else {
            return 0
        }
        let sectionInfo = sections[0]
        return sectionInfo.numberOfObjects
    }
    
    func getFeedItem(_ index: Int) -> FeedsItemProtocol {
        return frc?.object(at: IndexPath(item: index, section: 0)).getRawObject() as! FeedsItemProtocol
    }
}

extension FeedsViewController:  NSFetchedResultsControllerDelegate {
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // begin update to table
        feedsTable?.beginUpdates()
    }
    
    // object changed
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let unwrappedInsertedIndexpath = newIndexPath {
                feedsTable?.insertSections(IndexSet(integer: unwrappedInsertedIndexpath.row), with: .none)
            }
        case .delete:
            if let unwrappedInsertedIndexpath = indexPath {
                feedsTable?.deleteSections(IndexSet(integer: unwrappedInsertedIndexpath.row), with: .none)
            }
        case .update:
            if let unwrappedInsertedIndexpath = indexPath {
                feedsTable?.reloadSections(IndexSet(integer: unwrappedInsertedIndexpath.row), with: .none)
            }
        case .move:
            if let unwrappedInsertedIndexpath = indexPath {
                if let unwrappedNewindexpath = newIndexPath {
                    print("<<<<<<<<<<, moved to row at \(unwrappedNewindexpath)")
                    feedsTable?.deleteSections(IndexSet(integer: unwrappedInsertedIndexpath.row), with: .none)
                    feedsTable?.insertSections(IndexSet(integer: unwrappedNewindexpath.row), with: .none)
                }
            }
        @unknown default:
            fatalError("unknown NSFetchedResultsChangeType")
        }
    }
    
    // did change
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.loader.hideActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
        feedsTable?.endUpdates()
    }
}
extension FeedsViewController:  FeedsImageDelegate {
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

extension FeedsViewController : Click3DotsByMeFilterTypeProtocol {
    func selectedFilterType(selectedType: Click3DotsByMeFilterType, feedIdentifier: Int64, isPostAlreadyPinned: Bool) {
        switch selectedType {
        case .Edit:
            if let feed =  getFeedItem(feedIdentifier: feedIdentifier){
                self.openFeedEditor(feed)
            }
        case .Pin:
            self.pinToPost(feedIdentifier: feedIdentifier, isAlreadyPinned: isPostAlreadyPinned)
        case .Delete:
            self.showDeletePostConfirmation(feedIdentifier)
        case .ReportAbuse:
            self.showReportAbuseConfirmation(feedIdentifier)
        }
    }
}
