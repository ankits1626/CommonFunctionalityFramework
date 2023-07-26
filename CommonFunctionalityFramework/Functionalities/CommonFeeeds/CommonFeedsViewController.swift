//
//  CommonFeedsViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 03/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import CoreData
import Photos
import RewardzCommonComponents

class CommonFeedsViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet private weak var feedsTable : UITableView?
    
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var feedCoordinatorDelegate: FeedsCommonCoordinatorDelegate!
    var themeManager: CFFThemeManagerProtocol?
    var mainAppCoordinator : CFFMainAppInformationCoordinator?
    @IBOutlet private weak var feedCreateView : UIButton?
    @IBOutlet private weak var appreciationiconContainer : UIView?
    @IBOutlet private weak var creationButtonView : UIView?
    @IBOutlet private weak var noRecordsLabel : UILabel?
    @IBOutlet private weak var topGettersContainerView : UIView?
    @IBOutlet private weak var viewRecognitionLabel : UILabel?
    var selectedTabType = ""
    var searchText : String?
    var feedTypePk : Int = 0
    var organisationPK : Int = 0
    var departmentPK : Int = 0
    var dateRangePK : Int = 0
    var coreValuePk : Int = 0
    var isCreationButtonRequired : Bool = false
    var isRecognitionBannerHide : Bool = false
    var selectedTopGettersPK : Int = 0
    
    lazy var feedSectionFactory: CommonFeedsSectionFactory = {
        return CommonFeedsSectionFactory(
            feedsDatasource: self,
            mediaFetcher: mediaFetcher,
            targetTableView: feedsTable,
            selectedOptionMapper: pollSelectedAnswerMapper,
            themeManager: themeManager, selectedTab: selectedTabType
        )
    }()
    let loader = MFLoader()
    lazy var pollSelectedAnswerMapper: SelectedPollAnswerMapper = {
        return SelectedPollAnswerMapper()
    }()
    let currentWindow: UIWindow? = UIApplication.shared.keyWindow!
    private var lastFetchedFeeds : FetchedFeedModel?
    @IBOutlet weak var topLeaderboardHeightConstraints : NSLayoutConstraint?
    var isDesklessEnabled : Bool = false
    private lazy var refreshControl : UIRefreshControl  = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFeeds), for: .valueChanged)
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .gray
        return refreshControl
    }()
    @IBOutlet weak var emptyViewContainer : UIView?
    lazy private var emptyResultView: NoEntryViewController = {
        return NoEntryViewController(
            nibName: "NoEntryViewController",
            bundle: Bundle(for: NoEntryViewController.self)
        )
    }()
    private var frc : NSFetchedResultsController<ManagedPost>?
    private var pollAnswerSubmitter : PollAnswerSubmitter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(scrollTableView(notification:)), name: NSNotification.Name(rawValue: "FeedsScroll"), object: nil)
        UserDefaults.standard.setValue(selectedTabType, forKey: "selectedTab")
        UserDefaults.standard.synchronize()
        clearAnyExistingFeedsData {[weak self] in
            self?.initializeFRC()
            self?.setup()
            self?.loadFeeds()
        }
        if selectedTabType == "SearchFromHome" {
            self.feedsTable?.alwaysBounceVertical = false
            self.feedsTable?.showsVerticalScrollIndicator = false
        }
        setupView()
        feedCreateView?.layer.cornerRadius = (feedCreateView?.frame.size.width)!/2
        feedCreateView?.clipsToBounds = true
        feedCreateView?.backgroundColor = UIColor.getControlColor()
        self.creationButtonView?.isHidden = !isCreationButtonRequired
        self.noRecordsLabel?.text = "No Records Found!".localized
        viewRecognitionLabel?.text = "View Recognition Hero’s of this month".localized
    }
    
    func setupView() {
        topLeaderboardHeightConstraints?.constant = isRecognitionBannerHide ? 0 : 92
        topGettersContainerView?.backgroundColor = UIColor.getControlColor()
        topGettersContainerView?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0 )
        appreciationiconContainer?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0 )
    }
    
    @objc func scrollTableView(notification: NSNotification) {
        if let scrollData = notification.object as? Dictionary<String, Any> {
            if let isScrollable = scrollData["isScrollable"] as? Bool {
                print("isScrollable ----- \(isScrollable)")
                if selectedTabType != "SearchFromHome" {
                    self.feedsTable?.bounces = true
                }
                self.feedsTable?.isScrollEnabled = isScrollable
            }
        }
    }
    
    deinit {
        print("Notification deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (selectedTopGettersPK == 0) {
            self.tabBarController?.tabBar.isHidden = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showMenuButton"), object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.loader.hideActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
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
        if selectedTabType != "SearchFromHome" {
            clearAnyExistingFeedsData {[weak self] in
                self?.lastFetchedFeeds = nil
                self?.loadFeeds()
            }
        }
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
        //loader.showActivityIndicator(self.currentWindow!)
        FeedFetcher(networkRequestCoordinator: requestCoordinator).fetchFeeds(
            nextPageUrl: lastFetchedFeeds?.nextPageUrl, feedType: selectedTabType, searchText: searchText,feedTypePk: self.feedTypePk, organisationPK: self.organisationPK,departmentPK: self.departmentPK,dateRangePK: self.dateRangePK,coreValuePk: self.coreValuePk,selectedTopGetterPk: self.selectedTopGettersPK) {[weak self] (result) in
                DispatchQueue.main.async {
                    // self?.loader.hideActivityIndicator((self?.currentWindow!)!)
                    self?.feedsTable?.loadCFFControl?.endLoading()
                    switch result{
                    case .Success(let result):
                        if let resultData = result.fetchedRawFeeds as? NSDictionary {
                            if self?.selectedTabType == "received" {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "approvalsTabStatus"), object: nil, userInfo: [
                                    "show_approvals": resultData["show_approvals"], "approvals_count": resultData["approvals_count"]
                                ])
                            }
                            
                            if let feedData = resultData["results"]as? [NSDictionary], feedData.count == 0{
                                self?.loader.hideActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
                            }
                            
                            if let resultCount = resultData["count"] as? Int  {
                                if resultCount == 0 {
                                    self?.feedsTable?.isHidden = true
                                }else{
                                    self?.feedsTable?.isHidden = false
                                }
                            }
                        }
                        if result.fetchedRawFeeds?.count == 0 {
                            self?.loader.hideActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
                        }
                        self?.handleFetchedFeedsResult(fetchedfeeds: result)
                    case .SuccessWithNoResponseData:
                        ErrorDisplayer.showError(errorMsg: "No record Found".localized) { (_) in}
                    case .Failure(let error):
                        ErrorDisplayer.showError(errorMsg: error.displayableErrorMessage()) { (_) in}
                    }
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
        setupTableView()
    }
    
    
    private func setupTableView(){
        if selectedTabType != "SearchFromHome" {
            feedsTable?.addSubview(refreshControl)
        }
        feedsTable?.tableFooterView = UIView(frame: CGRect.zero)
        feedsTable?.rowHeight = UITableView.automaticDimension
        feedsTable?.estimatedRowHeight = 500
        feedsTable?.dataSource = self
        feedsTable?.delegate = self
        feedsTable?.loadCFFControl = CFFLoadControl(target: self, action: #selector(bottomLoader))
        feedsTable?.loadCFFControl?.tintColor = .gray
        feedsTable?.loadCFFControl?.heightLimit = 100.0
    }
    
    @IBAction func createNominationView() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "openThanksView"), object: nil, userInfo: nil)
    }
    
    @IBAction func openTopGettersUsersBtnPressed() {
        let topHeroVc = TopGettersLeaderboardViewController(nibName: "TopGettersLeaderboardViewController", bundle: Bundle(for: TopGettersLeaderboardViewController.self))
        topHeroVc.requestCoordinator = requestCoordinator
        topHeroVc.mediaFetcher = mediaFetcher
        self.tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideMenuButton"), object: nil)
        self.navigationController?.pushViewController(topHeroVc, animated: true)
        
    }
}

extension CommonFeedsViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedSectionFactory.getNumberOfSections()
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
            feedDetailVC.themeManager = themeManager
            feedDetailVC.showDisplayOptions = .Appreciation
            feedDetailVC.mainAppCoordinator = mainAppCoordinator
            feedDetailVC.targetFeedItem = getFeedItem(indexPath.section) //feeds[indexPath.section]
            feedDetailVC.mediaFetcher = mediaFetcher
            feedDetailVC.selectedTab = selectedTabType
            feedDetailVC.requestCoordinator = requestCoordinator
            feedDetailVC.isDesklessEnabled = isDesklessEnabled
            //feedDetailVC.feedCoordinatorDelegate = feedCoordinatorDelegate as! FeedsCoordinatorDelegate
            feedDetailVC.pollSelectedAnswerMapper = pollSelectedAnswerMapper
            feedCoordinatorDelegate.showFeedDetail(feedDetailVC)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadCFFControl?.update()
        if Bundle.main.bundleIdentifier == "com.rewardz.iOSabundantly" {
            if selectedTabType == "SearchFromHome" {
                if scrollView.contentOffset.y <= 0 {
                    scrollView.contentOffset = .zero
                 }
            }
        }
    }
}

extension CommonFeedsViewController : CommonFeedsDelegate{
    
    func showFeedEditOptions(targetView: UIView?, feedIdentifier: Int64) {
        print("show edit option")
        if let feed =  getFeedItem(feedIdentifier: feedIdentifier){
            if feed.isFeedReportAbuseAllowed(){
                self.showReportAbuseConfirmation(feedIdentifier)
            }
            
        }
    }
    
    func toggleLikeForComment(commentIdentifier: Int64) {
        //
    }
    
    func pinToPost(feedIdentifier : Int64, isAlreadyPinned: Bool) {
        //
    }
    
    func showPostReactions(feedIdentifier : Int64) {
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
                                    post?.numberOfLikes = likesResult["count"] as? Int64 ?? 0
                                    if let dataVal = likesResult["post_reactions"] as? NSArray {
                                        post?.reactionTypesData =  dataVal
                                        post?.messageType = Int64(likesResult.object(forKey: "reaction_type") as? Int ?? -1)
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
    
    private func showPintoPostConfirmation(_ feedIdentifier : Int64, isAlreadyPinned: Bool){
        //        let pinPostDrawer = PintoTopConfirmationDrawer(
        //            nibName: "PintoTopConfirmationDrawer",
        //            bundle: Bundle(for: PintoTopConfirmationDrawer.self)
        //        )
        //        pinPostDrawer.themeManager = themeManager
        //        pinPostDrawer.isAlreadyPinned = isAlreadyPinned
        //        pinPostDrawer.targetFeed = getFeedItem(feedIdentifier: feedIdentifier)
        //        pinPostDrawer.confirmedCompletion = {postFrequency in
        //            PostPinWorker(networkRequestCoordinator: self.requestCoordinator).postPin(feedIdentifier, frequency: postFrequency) { (result) in
        //                DispatchQueue.main.async {
        //                    switch result{
        //                    case .Success(_):
        //                        ErrorDisplayer.showError(errorMsg: isAlreadyPinned ? "Post is unpinned successfully".localized : "Post is pinned successfully".localized, okActionHandler: { (_) in
        //                          NotificationCenter.default.post(name: .didUpdatedPosts, object: nil)
        //                        })
        //                    case .SuccessWithNoResponseData:
        //                        fallthrough
        //                    case .Failure(_):
        //                        ErrorDisplayer.showError(errorMsg: "Failed to pin post, please try again.".localized) { (_) in}
        //                    }
        //                }
        //            }
        //        }
        //        do{
        //            try pinPostDrawer.presentDrawer()
        //        }catch {
        //
        //        }
    }
    
    func showAllClaps(feedIdentifier: Int64) {
        //        print("show all claps for \(feedIdentifier)")
        //        let likeListVC = LikeListViewController(
        //            feedIdentifier: feedIdentifier,
        //            requestCoordinator: requestCoordinator,
        //            mediaFetcher: mediaFetcher
        //        )
        //        feedCoordinatorDelegate.showPostLikeList(likeListVC, presentationOption: .Navigate) { (topBarModel) in
        //            likeListVC.containerTopBarModel = topBarModel
        //        }
    }
    
    func submitPollAnswer(feedIdentifier : Int64){
        print("post answer")
        //        if let selectedOption = pollSelectedAnswerMapper.getSelectedOption(feedIdentifier: feedIdentifier){
        //            PollAnswerSubmitter(networkRequestCoordinator: requestCoordinator, feedIdentifier: feedIdentifier, answer: selectedOption).submitAnswer { (result) in
        //                switch result{
        //                case .Success(result: let result):
        //                    print("<<<<<<<< update raw poll after answer submission")
        //                    DispatchQueue.main.async {[weak self] in
        //                        self?.pollSelectedAnswerMapper.removeSelectedOptionAfterAnswerIsPosted(feedIdentifier: feedIdentifier)
        //                    }
        //                    CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
        //                        let _ = result.getManagedObject() as! ManagedPost
        //                        CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
        //                            CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
        //                        }
        //                    }
        //
        //                case .SuccessWithNoResponseData:
        //                    fallthrough
        //                case .Failure(error: _):
        //                    print("<<<<<<<<<< like/unlike call completed \(result)")
        //                }
        //
        //            }
        //        }else{
        //            ErrorDisplayer.showError(errorMsg: "Please select an option.".localized) { (_) in
        //
        //            }
        //        }
    }
    
    func selectPollAnswer(feedIdentifier : Int64, pollOption: PollOption){
        print("select answer for feed \(feedIdentifier), answer : \(pollOption.getNewtowrkPostableAnswer())")
        //        pollSelectedAnswerMapper.toggleOptionSelection(pollId: feedIdentifier, selectedOption: pollOption)
        //        //reload cells
        //        if let feedItem = getFeedItem(feedIdentifier: feedIdentifier){
        //            CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
        //                let post = ((feedItem as? RawObjectProtocol)?.getManagedObject() as? ManagedPost)
        //                post?.pollUpdatedTrigger = NSDate()
        //                CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
        //                    CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
        //                }
        //            }
        //        }
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


extension CommonFeedsViewController : CommonFeedsDatasource{
    
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

extension CommonFeedsViewController:  NSFetchedResultsControllerDelegate {
    
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
