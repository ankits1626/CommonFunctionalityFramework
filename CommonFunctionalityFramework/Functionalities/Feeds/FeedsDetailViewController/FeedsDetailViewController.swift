//
//  FeedsDetailViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import CoreData

enum FeedDetailSection : Int {
    case FeedInfo = 0
    case ClapsSection
    case Comments
}
protocol FeedsDetailCommentsProviderProtocol{
    func getNumberOfComments() -> Int
    func getComment(_ index : Int) -> FeedComment?
}
class FeedsDetailViewController: UIViewController, PostEditorCellFactoryDelegate {

    var feedFetcher: CFFNetworkRequestCoordinatorProtocol!
    private var tagPicker : ASMentionSelectorViewController?
    @IBOutlet weak var commentBarView : ASChatBarview?
    @IBOutlet weak var feedDetailTableView : UITableView?
    var targetFeedItem : FeedsItemProtocol!
    var clappedByUsers : [ClappedByUser]?
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    weak var themeManager: CFFThemeManagerProtocol?
    var feedCoordinatorDelegate: FeedsCoordinatorDelegate!
    weak var mainAppCoordinator : CFFMainAppInformationCoordinator?
    
    lazy var feedDetailSectionFactory: FeedDetailSectionFactory = {
        return FeedDetailSectionFactory(
            self,
            feedDetailDelegate: self,
            mediaFetcher: mediaFetcher,
            targetTableView: feedDetailTableView,
            themeManager: themeManager,
            selectedOptionMapper: pollSelectedAnswerMapper
        )
    }()
    var pollSelectedAnswerMapper: SelectedPollAnswerMapper?
    private var frc : NSFetchedResultsController<ManagedPostComment>?
    private var lastFetchedComments : FeedCommentsFetchResult?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideMenuButton"), object: nil)
    }
    
    private func setup(){
        view.backgroundColor = .viewBackgroundColor
        setupTableView()
        //setupCommentBar()
        fetchClappedByUsers()
        observeChangesToPost()
    }
    
    private func observeChangesToPost(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadPost),
            name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
            object: CFFCoreDataManager.sharedInstance.manager.mainQueueContext)
    }
    
    private func setupCommentBar(){
        commentBarView?.backgroundColor = .commentBarBackgroundColor
        commentBarView?.placeholder = "Enter your comments here".localized
        commentBarView?.placeholderColor = .getPlaceholderTextColor()
        commentBarView?.placeholderFont = .Body1
    }
    
    private func setupTableView(){
        feedDetailTableView?.tableFooterView = UIView(frame: CGRect.zero)
        feedDetailTableView?.rowHeight = UITableView.automaticDimension
        feedDetailTableView?.estimatedRowHeight = 140
        feedDetailTableView?.dataSource = self
        feedDetailTableView?.delegate = self
        feedDetailTableView?.reloadData()
        feedDetailTableView?.loadCFFControl = CFFLoadControl(target: self, action: #selector(fetchComments))
        feedDetailTableView?.loadCFFControl?.heightLimit = 100.0
    }
    
    private func initializeFRC() {
        let fetchRequest: NSFetchRequest<ManagedPostComment> = ManagedPostComment.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "commentId", ascending: false)
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
            feedDetailTableView?.reloadData()
        } catch let error {
            print("<<<<<<<<<< error \(error.localizedDescription)")
        }
    }
    
    private func clearAnyExistingFeedsData(_ completion: @escaping (() -> Void)){
        CFFCoreDataManager.sharedInstance.manager.deleteAllObjetcs(type: ManagedPostComment.self) {
            DispatchQueue.main.async {
                CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                completion()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearAnyExistingFeedsData {[weak self] in
            ASMentionCoordinator.shared.delegate = self
            self?.initializeFRC()
            self?.setup()
            self?.fetchComments()
            ASChatBarview().setNeedsDisplay()
            ASChatBarview().layoutIfNeeded()
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
                shouldSearchOnlyDepartment: false
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
    
    @objc private func fetchComments(){
        FeedCommentsFetcher(networkRequestCoordinator: requestCoordinator).fetchComments(
        feedId: targetFeedItem.feedIdentifier, nextpageUrl: lastFetchedComments?.nextPageUrl) { (result) in
            DispatchQueue.main.async {
                switch result{
                case .Success(let result):
                    DispatchQueue.main.async {[weak self] in
                        self?.lastFetchedComments = result
                        self?.feedDetailTableView?.loadCFFControl?.endLoading()
                    }
                    CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                        if let comments = result.fetchedComments{
                            comments.forEach { (aRawComment) in
                                let _ = aRawComment.getManagedObject() as! ManagedPostComment
                            }
                            CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                                CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                            }
                        }
                    }
                    
                case .SuccessWithNoResponseData:
                    fallthrough
                case .Failure(let _):
                    print("unable to fetch comments")
                }
            }
        }
    }
    
    private func fetchClappedByUsers(){
        PostLikeListFetcher(networkRequestCoordinator: requestCoordinator).fetchLikeList(
        feedIdentifier: targetFeedItem.feedIdentifier, nextPageUrl: nil) { (result) in
            switch result{
            case .Success(result: let result):
                var likeList = [ClappedByUser]()
                if let results = result.fetchedLikes?["results"] as? [[String : Any]]{
                    results.forEach { (aRawLike) in
                        if let userInfo = aRawLike["user_info"] as? [String : Any]{
                            likeList.append(ClappedByUser(userInfo))
                        }
                    }
                }
                
                DispatchQueue.main.async {[weak self] in
                    self?.clappedByUsers = likeList
                    self?.feedDetailTableView?.reloadData()
                }
            case .SuccessWithNoResponseData:
                fallthrough
            case .Failure(error: _):
                print("<<<<<<< error while fetching like list")
            }
        }
    }
    
    @objc private func reloadPost(notification: NSNotification){
        guard let userInfo = notification.userInfo else { return }
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<ManagedPost>,
            let updatedPost = updates.first?.getRawObject() as? FeedsItemProtocol{
             print("<<<<<<<<<<< reloadPost")
            targetFeedItem = updatedPost
            feedDetailTableView?.reloadSections(IndexSet(integer: 0), with: .none)
        }
    }
    
    func reloadTextViewContainingRow(indexpath: IndexPath) {
    }
    
    func updatePostTitle(title: String?) {
    }
    
    func updatePostDescription(decription: String?) {
    }
    
    func removeSelectedMedia(index: Int, mediaSection: EditableMediaSection) {
    }
    
    func removeAttachedGif() {
    }
    
    func savePostOption(index: Int, option: String?) {
    }
    
    func activeDaysForPollChanged(_ days: Int) {
    }
}

extension FeedsDetailViewController : FeedsDetailCommentsProviderProtocol{
    func getNumberOfComments() -> Int {
        guard let sections = frc?.sections else {
            return 0
        }
        let sectionInfo = sections[0]
        return sectionInfo.numberOfObjects
    }
    
    func getComment(_ index: Int) -> FeedComment? {
        return frc?.object(at: IndexPath(item: index, section: 0)).getRawObject() as? FeedComment
    }
    
    
}

extension FeedsDetailViewController : FeedsDatasource{
    func shouldShowMenuOptionForFeed() -> Bool {
        return mainAppCoordinator?.isUserAllowedToPostFeed() ?? true
    }
    
    func getCommentProvider() -> FeedsDetailCommentsProviderProtocol? {
        return self
    }
    
    func getTargetPost() -> EditablePostProtocol? {
        return nil
    }
    
    func showShowFullfeedDescription() -> Bool {
        return true
    }
    
    func getNumberOfItems() -> Int {
        return 0
    }
    
    func getFeedItem(_ index: Int) -> FeedsItemProtocol {
        return targetFeedItem
    }
    
    func getClappedByUsers() -> [ClappedByUser]? {
        return clappedByUsers
    }
    
    func getFeedItem() -> FeedsItemProtocol!{
        return targetFeedItem
    }
}

extension FeedsDetailViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedDetailSectionFactory.getNumberOfSectionsForFeedDetailView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedDetailSectionFactory.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  feedDetailSectionFactory.getCell(indexPath: indexPath, tableView: tableView)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        feedDetailSectionFactory.configureCell(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return feedDetailSectionFactory.getHeightOfCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return feedDetailSectionFactory.getViewForHeaderInSection(section: section, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return feedDetailSectionFactory.getHeightOfViewForSection(section: section)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadCFFControl?.update()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.loadCFFControl?.update()
    }
}

extension FeedsDetailViewController : FeedsDelegate{
    
    func toggleLikeForComment(commentIdentifier: Int64) {
        if let comment = getLikeableComment(commentIdentifier: commentIdentifier){
            print("<<<<<<<<< toggle like \(commentIdentifier)")
            FeedClapToggler(networkRequestCoordinator: requestCoordinator).toggleLike(comment) { (result) in
                switch result{
                case .Success(result: let result):
                    CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                        let comment = comment.getManagedObject() as! ManagedPostComment
                        comment.isLikedByMe = result.isLiked
                        comment.numberOfLikes = result.totalLikeCount
                    
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
            pinPostDrawer.targetFeed = targetFeedItem
            pinPostDrawer.confirmedCompletion = {postFrequency in
                PostPinWorker(networkRequestCoordinator: self.requestCoordinator).postPin(feedIdentifier, frequency: postFrequency) { (result) in
                    DispatchQueue.main.async {
                        switch result{
                        case .Success(_):
                            ErrorDisplayer.showError(errorMsg: isAlreadyPinned ? "Post is unpinned successfully".localized : "Post is pinned successfully".localized, okActionHandler: { (_) in
                                NotificationCenter.default.post(name: .didUpdatedPosts, object: nil)
                                self.navigationController?.popViewController(animated: true)
                            })
                        case .SuccessWithNoResponseData:
                            fallthrough
                        case .Failure(_):
                            ErrorDisplayer.showError(errorMsg: "Failed to pin post, please try again.".localized) { (_) in}
                        }
                    }
                }
            }
            do{
                try pinPostDrawer.presentDrawer()
            }catch {
                
            }
        }
    
    private func getLikeableComment(commentIdentifier: Int64) -> FeedComment?{
        let fetchRequest = NSFetchRequest<ManagedPostComment>(entityName: "ManagedPostComment")
        fetchRequest.predicate = NSPredicate (format: "commentId == %d", commentIdentifier)
        do{
            let filterdComments = try CFFCoreDataManager.sharedInstance.manager.mainQueueContext.fetch(fetchRequest)
            return filterdComments.first?.getRawObject() as? FeedComment
        }catch{
            return nil
        }
    }
    
    func showAllClaps(feedIdentifier: Int64) {}
    
    func submitPollAnswer(feedIdentifier: Int64) {
        print("from detail page post answer")
        if let selectedOption = pollSelectedAnswerMapper?.getSelectedOption(feedIdentifier: feedIdentifier){
            PollAnswerSubmitter(networkRequestCoordinator: requestCoordinator, feedIdentifier: feedIdentifier, answer: selectedOption).submitAnswer { (result) in
                switch result{
                case .Success(result: let result):
                    print("<<<<<<<< update raw poll after answer submission")
                    DispatchQueue.main.async {[weak self] in
                        self?.pollSelectedAnswerMapper?.removeSelectedOptionAfterAnswerIsPosted(feedIdentifier: feedIdentifier)
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
            ErrorDisplayer.showError(errorMsg: "Please select an option.") { (_) in
                
            }
        }
    }
    
    func selectPollAnswer(feedIdentifier: Int64, pollOption: PollOption) {
        print("select answer for feed \(feedIdentifier), answer : \(pollOption.getNewtowrkPostableAnswer())")
        pollSelectedAnswerMapper?.toggleOptionSelection(pollId: feedIdentifier, selectedOption: pollOption)
        CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
            let post = ((self.targetFeedItem as? RawObjectProtocol)?.getManagedObject() as? ManagedPost)
            post?.pollUpdatedTrigger = NSDate()
            CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
            }
        }
    }
    
    func toggleClapForPost(feedIdentifier: Int64) {
        FeedClapToggler(networkRequestCoordinator: requestCoordinator).toggleLike(targetFeedItem) { [weak self](result) in
            switch result{
            case .Success(result: let result):
                CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                    let post = ((self?.targetFeedItem as? RawObjectProtocol)?.getManagedObject() as! ManagedPost)
                    post.isLikedByMe = result.isLiked
                    post.numberOfLikes = result.totalLikeCount
                    self?.targetFeedItem = post.getRawObject() as! RawFeed
                    CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                        CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                        DispatchQueue.main.async {
                            self?.feedDetailSectionFactory.reloadToShowLikeAndCommentCountUpdate()
                            self?.fetchClappedByUsers()
                        }
                    }
                }
            case .SuccessWithNoResponseData:
                fallthrough
            case .Failure(error: let _):
                print("<<<<<<<<<< like/unlike call completed \(result)")
            }
            
        }
    }
    
    func showMediaBrowser(feedIdentifier: Int64, scrollToItemIndex: Int) {
        if let feed =  targetFeedItem,
            let mediaItems = feed.getMediaList(){
            let mediaBrowser = CFFMediaBrowserViewController(
                mediaList: mediaItems,
                mediaFetcher: mediaFetcher,
                selectedIndex: scrollToItemIndex
            )
            present(mediaBrowser, animated: true, completion: nil)
        }
    }
    
    func showFeedEditOptions(targetView: UIView?, feedIdentifier: Int64) {
        var options = [FloatingMenuOption]()
        if targetFeedItem.getFeedType() == .Post,
            targetFeedItem.isFeedEditAllowed(){
            options.append(
                FloatingMenuOption(title: "EDIT".localized, action: {
                    print("Edit post - \(feedIdentifier)")
                    self.openFeedEditor(self.targetFeedItem)
                }
                )
            )
        }
        if targetFeedItem.isFeedDeleteAllowed(){
            options.append( FloatingMenuOption(title: "DELETE".localized, action: {[weak self] in
                print("Delete post- \(feedIdentifier)")
                self?.showDeletePostConfirmation(feedIdentifier)
                }
                )
            )
        }
        if targetFeedItem.isFeedReportAbuseAllowed(){
            options.append( FloatingMenuOption(title: "REPORT ABUSE".localized, action: {[weak self] in
                print("report abuse- \(feedIdentifier)")
                self?.showReportAbuseConfirmation(feedIdentifier)
                }
                )
            )
        }
        FloatingMenuOptions(options: options).showPopover(sourceView: targetView!)
    }
    
    private func openFeedEditor(_ feed : FeedsItemProtocol){
        FeedComposerCoordinator(
            delegate: feedCoordinatorDelegate,
            requestCoordinator: requestCoordinator,
            mediaFetcher: mediaFetcher,
            selectedAssets: nil,
            themeManager: themeManager
        ).editPost(feed: feed)
    }
    
    private func showDeletePostConfirmation(_ feedIdentifier : Int64){
        let deleteConfirmationDrawer = DeletePostConfirmationDrawer(
            nibName: "DeletePostConfirmationDrawer",
            bundle: Bundle(for: DeletePostConfirmationDrawer.self)
        )
        deleteConfirmationDrawer.themeManager = themeManager
        deleteConfirmationDrawer.targetFeed = targetFeedItem
        deleteConfirmationDrawer.deletePressedCompletion = {[weak self] in
            print("<<<<<<<<< proceed with feed delete \(feedIdentifier)")
            if let unwrappedSelf = self{
                PostDeleteWorker(networkRequestCoordinator: unwrappedSelf.requestCoordinator).deletePost(feedIdentifier) { (result) in
                    switch result{
                    case .Success(result: _):
                        DispatchQueue.main.async {[weak self] in
                            if let feedItem = self?.targetFeedItem{
                                CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                                    if let post = ((feedItem as? RawObjectProtocol)?.getManagedObject() as? ManagedPost){
                                        CFFCoreDataManager.sharedInstance.manager.deleteManagedObject(managedObject: post, context: CFFCoreDataManager.sharedInstance.manager.privateQueueContext)
                                        CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                                            print("<<<<<<<<<<<<<poll deleted suceessfully")
                                            CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                                            DispatchQueue.main.async {
                                                ErrorDisplayer.showError(errorMsg: "Deleted successfully.".localized) { (_) in
                                                    self?.feedCoordinatorDelegate.removeFeedDetail()
                                                }
                                            }
                                        }
                                    }
                                }
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
        reportAbuseConfirmationDrawer.targetFeed = targetFeedItem
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
    
    func showLikedByUsersList() {
        let likeListVC = LikeListViewController(
            feedIdentifier: targetFeedItem.feedIdentifier,
            requestCoordinator: requestCoordinator,
            mediaFetcher: mediaFetcher
        )
        feedCoordinatorDelegate.showPostLikeList(likeListVC, presentationOption: .Navigate) { (topBarModel) in
            likeListVC.containerTopBarModel = topBarModel
        }
    }
    
}

extension FeedsDetailViewController : ASChatBarViewDelegate{
    func finishedPresentingOverKeyboard() {
        
    }
    
    func addAttachmentButtonPressed() {
        
    }
    
    func removeAttachment() {
        
    }
    
    func rightButtonPressed(_ chatBar: ASChatBarview) {
        if let message = chatBar.messageTextView?.text{
            print("post \(message)")
            FeedCommentPostWorker(networkRequestCoordinator: requestCoordinator).postComment(
                comment: PostbaleComment(
                    feedId: targetFeedItem.feedIdentifier,
                    commentText: chatBar.taggedMessaged)) { (result) in
                        DispatchQueue.main.async {
                            switch result{
                            case .Success(let result):
                                CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {[weak self] in
                                    let post = ((self?.targetFeedItem as? RawObjectProtocol)?.getManagedObject() as! ManagedPost)
                                    post.numberOfComments =  post.numberOfComments + 1
                                    ASMentionCoordinator.shared.clearMentionsTextView()
                                    self?.targetFeedItem = post.getRawObject() as! RawFeed
                                    let _ = FeedComment(input: result).getManagedObject() as! ManagedPostComment
                                    CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                                        CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                                    }
                                }
                            case .SuccessWithNoResponseData:
                                print("comment posted successfully")
                            case .Failure(let error):
                                ErrorDisplayer.showError(errorMsg: error.displayableErrorMessage()) { (_) in
                                    
                                }
                                chatBar.messageTextView?.text = message
                            }
                        }
            }
        }
    }
    
}

extension FeedsDetailViewController:  NSFetchedResultsControllerDelegate {
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // begin update to table
        feedDetailTableView?.beginUpdates()
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
                let translatedIndexpath = IndexPath(row: unwrappedInsertedIndexpath.row, section: feedDetailSectionFactory.getCommentsSectionIndex())
                feedDetailTableView?.insertRows(at: [translatedIndexpath], with: .fade)
            }
        case .delete:
            if let unwrappedInsertedIndexpath = indexPath {
                let translatedIndexpath = IndexPath(row: unwrappedInsertedIndexpath.row, section: feedDetailSectionFactory.getCommentsSectionIndex())
                feedDetailTableView?.deleteRows(at: [translatedIndexpath], with: .fade)
            }
        case .update:
            if let unwrappedInsertedIndexpath = indexPath {
                let translatedIndexpath = IndexPath(row: unwrappedInsertedIndexpath.row, section: feedDetailSectionFactory.getCommentsSectionIndex())
                feedDetailTableView?.reloadRows(at: [translatedIndexpath], with: .none)
            }
        case .move:
            if let unwrappedInsertedIndexpath = indexPath {
                if let unwrappedNewindexpath = newIndexPath {
                    let translatedIndexpath = IndexPath(row: unwrappedInsertedIndexpath.row, section: feedDetailSectionFactory.getCommentsSectionIndex())
                    let translatedNewIndexpath = IndexPath(row: unwrappedNewindexpath.row, section: feedDetailSectionFactory.getCommentsSectionIndex())
                    feedDetailTableView?.deleteRows(at: [translatedIndexpath], with: .none)
                    feedDetailTableView?.insertRows(at: [translatedNewIndexpath], with: .none)
                }
            }
        @unknown default:
            fatalError("unknown NSFetchedResultsChangeType")
        }
    }
    
    // did change
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {[weak self] in
            self?.feedDetailSectionFactory.reloadToShowLikeAndCommentCountUpdate()
            self?.feedDetailSectionFactory.reloadToCommentCountHeader()
        }
        feedDetailTableView?.endUpdates()
    }
}
