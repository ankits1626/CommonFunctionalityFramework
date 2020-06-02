//
//  FeedsDetailViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import CoreData
import UILoadControl

enum FeedDetailSection : Int {
    case FeedInfo = 0
    case ClapsSection
    case Comments 
}
protocol FeedsDetailCommentsProviderProtocol{
    func getNumberOfComments() -> Int
    func getComment(_ index : Int) -> FeedComment?
}
class FeedsDetailViewController: UIViewController {
    var feedFetcher: CFFNetwrokRequestCoordinatorProtocol!
    @IBOutlet weak var commentBarView : ASChatBarview?
    @IBOutlet weak var feedDetailTableView : UITableView?
    var targetFeedItem : FeedsItemProtocol!
    var clappedByUsers : [ClappedByUser]?
    var requestCoordinator: CFFNetwrokRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var feedCoordinatorDelegate: FeedsCoordinatorDelegate!
    
    lazy var feedDetailSectionFactory: FeedDetailSectionFactory = {
        return FeedDetailSectionFactory(self, feedDetailDelegate: self, mediaFetcher: mediaFetcher, targetTableView: feedDetailTableView)
    }()
    private var frc : NSFetchedResultsController<ManagedPostComment>?
    private var lastFetchedComments : FeedCommentsFetchResult?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        clearAnyExistingFeedsData {[weak self] in
            self?.initializeFRC()
            self?.setup()
        }
    }
    
    private func setup(){
        view.backgroundColor = .viewBackgroundColor
        setupTableView()
        setupCommentBar()
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
        commentBarView?.placeholder = "Enter your comments here"
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
        feedDetailTableView?.loadControl = UILoadControl(target: self, action: #selector(fetchComments))
        feedDetailTableView?.loadControl?.heightLimit = 100.0
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
        fetchComments()
    }
    
    @objc private func fetchComments(){
        FeedCommentsFetcher(networkRequestCoordinator: requestCoordinator).fetchComments(
        feedId: targetFeedItem.feedIdentifier, nextpageUrl: lastFetchedComments?.nextPageUrl) { (result) in
            DispatchQueue.main.async {
                switch result{
                case .Success(let result):
                    DispatchQueue.main.async {[weak self] in
                        self?.lastFetchedComments = result
                        self?.feedDetailTableView?.loadControl?.endLoading()
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
        PostLikeListFetcher(networkRequestCoordinator: requestCoordinator).fetchFeeds(
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
        scrollView.loadControl?.update()
    }
}

extension FeedsDetailViewController : FeedsDelegate{
    func showAllClaps(feedIdentifier: Int64) {
        
    }
    
    func submitPollAnswer(feedIdentifier: Int64) {
        
    }
    
    func selectPollAnswer(feedIdentifier: Int64, pollOption: PollOption) {
        
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
                FloatingMenuOption(title: "EDIT", action: {
                    print("Edit post - \(feedIdentifier)")
                    self.openFeedEditor(self.targetFeedItem)
                }
                )
            )
        }
        if targetFeedItem.isFeedDeleteAllowed(){
            options.append( FloatingMenuOption(title: "DELETE", action: {[weak self] in
                print("Delete post- \(feedIdentifier)")
                self?.showDeletePostConfirmation(feedIdentifier)
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
            selectedAssets: nil
        ).editPost(feed: feed)
    }
    
    private func showDeletePostConfirmation(_ feedIdentifier : Int64){
        let deleteConfirmationDrawer = DeletePostConfirmationDrawer(
            nibName: "DeletePostConfirmationDrawer",
            bundle: Bundle(for: DeletePostConfirmationDrawer.self)
        )
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
                                                ErrorDisplayer.showError(errorMsg: "Deleted successfully.") { (_) in
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
                    commentText: message)) { (result) in
                        DispatchQueue.main.async {
                            switch result{
                            case .Success(let result):
                                CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {[weak self] in
                                    let post = ((self?.targetFeedItem as? RawObjectProtocol)?.getManagedObject() as! ManagedPost)
                                    post.numberOfComments =  post.numberOfComments + 1
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
