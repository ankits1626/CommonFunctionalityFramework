//
//  FeedsViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/03/20.
//  Copyright © 2020 Rewardz Private Limited. All rights reserved.
//

import UIKit
import CoreData
import UILoadControl

class FeedsViewController: UIViewController {
    @IBOutlet private weak var composeLabel : UILabel?
    @IBOutlet private weak var feedsTable : UITableView?
    @IBOutlet private weak var whatsInYourMindView : UIView?
    @IBOutlet private weak var cameraContainerViewView : UIView?
    
    var requestCoordinator: CFFNetwrokRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var feedCoordinatorDeleagate: FeedsCoordinatorDelegate!
    
    lazy var feedSectionFactory: FeedSectionFactory = {
        return FeedSectionFactory(feedsDatasource: self, mediaFetcher: mediaFetcher, targetTableView: feedsTable)
    }()
    
    var lastFetchedFeeds : FetchedFeedModel?
    
    private lazy var refreshControl : UIRefreshControl  = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFeeds), for: .valueChanged)
        refreshControl.backgroundColor = .black
        refreshControl.tintColor = .white //Rgbconverter.HexToColor(get_backgroundColor(), alpha: 1.0)
        return refreshControl
    }()
    
    private var frc : NSFetchedResultsController<ManagedPost>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearAnyExistingFeedsData {[weak self] in
            self?.initializeFRC()
            self?.loadFeeds()
            self?.setup()
            self?.loadFeeds()
        }
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
    
    @objc private func loadFeeds(){
        FeedFetcher(networkRequestCoordinator: requestCoordinator).fetchFeeds(
        nextPageUrl: lastFetchedFeeds?.nextPageUrl) {[weak self] (result) in
            DispatchQueue.main.async {
                self?.feedsTable?.loadControl?.endLoading()
                switch result{
                case .Success(let result):
                    self?.handleFetchedFeedsResult(fetchedfeeds: result)
                case .SuccessWithNoResponseData:
                    ErrorDisplayer.showError(errorMsg: "No record Found") { (_) in}
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
                    let _ = RawFeed(input: aRawFeed).getManagedObject() as! ManagedPost
                }
                CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                    CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                }
            }
        }
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.feedsTable?.reloadData()
        }
    }
    
    private func setup(){
        view.backgroundColor = .viewBackgroundColor
        setupTopBar()
        setupTableView()
    }
    
    private func setupTopBar(){
        whatsInYourMindView?.curvedCornerControl()
        whatsInYourMindView?.backgroundColor = UIColor.grayBackGroundColor()
        cameraContainerViewView?.curvedCornerControl()
        cameraContainerViewView?.backgroundColor = UIColor.grayBackGroundColor()
        composeLabel?.text = "Whats on your mind"
        composeLabel?.font = .Highlighter1
        composeLabel?.textColor = .getSubTitleTextColor()
    }
    
    private func setupTableView(){
        feedsTable?.addSubview(refreshControl)
        feedsTable?.tableFooterView = UIView(frame: CGRect.zero)
        feedsTable?.rowHeight = UITableView.automaticDimension
        feedsTable?.estimatedRowHeight = 140
        feedsTable?.dataSource = self
        feedsTable?.delegate = self
        feedsTable?.loadControl = UILoadControl(target: self, action: #selector(loadFeeds))
        feedsTable?.loadControl?.heightLimit = 100.0
    }
}

extension FeedsViewController{
    @IBAction func openFeedComposerSelectionDrawer(){
        let drawer = FeedsComposerDrawer(nibName: "FeedsComposerDrawer", bundle: Bundle(for: FeedsComposerDrawer.self))
        drawer.feedCoordinatorDeleagate = feedCoordinatorDeleagate
        drawer.requestCoordinator = requestCoordinator
        do{
            try drawer.presentDrawer()
        }catch let error{
            print("show error")
            ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
                
            }
        }
    }
}

extension FeedsViewController : UITableViewDataSource, UITableViewDelegate{
    
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
            let feedDetailVC = FeedsDetailViewController(nibName: "FeedsDetailViewController", bundle: Bundle(for: FeedsDetailViewController.self))
            feedDetailVC.targetFeedItem = getFeedItem(indexPath.section) //feeds[indexPath.section]
            feedDetailVC.mediaFetcher = mediaFetcher
            feedDetailVC.requestCoordinator = requestCoordinator
            feedDetailVC.feedCoordinatorDeleagate = feedCoordinatorDeleagate
            feedCoordinatorDeleagate.showFeedDetail(feedDetailVC)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadControl?.update()
    }
}

extension FeedsViewController : FeedsDelegate{
    
    func toggleClapForPost(feedIdentifier: Int64) {
        if let feed = getFeedItem(feedIdentifier: feedIdentifier){
            FeedClapToggler(networkRequestCoordinator: requestCoordinator).toggleLike(feed) { (result) in
                switch result{
                case .Success(result: let result):
                    CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                        let post = ((feed as? RawObjectProtocol)?.getManagedObject() as? ManagedPost)
                        post?.isLikedByMe = result
                        if let numberOfLikes = post?.numberOfLikes{
                           post?.numberOfLikes = numberOfLikes + ( result ? 1 : -1  )
                        }
                        
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
        if let feed =  getFeedItem(feedIdentifier: feedIdentifier){
            var options = [FloatingMenuOption]()
            if feed.getFeedType() == .Post{
                options.append(
                    FloatingMenuOption(title: "EDIT", action: {
                        print("Edit post - \(feedIdentifier)")
                        self.openFeedEditor(feed)
                    }
                    )
                )
            }
            options.append( FloatingMenuOption(title: "DELETE", action: {
                print("Delete post- \(feedIdentifier)")
            }
                )
            )
            
            FloatingMenuOptions(options: options).showPopover(sourceView: targetView!)
        }
    }
    
    private func openFeedEditor(_ feed : FeedsItemProtocol){
        FeedComposerCoordinator(
            delegate: feedCoordinatorDeleagate,
            requestCoordinator: requestCoordinator,
            mediaFetcher: mediaFetcher
        ).editPost(feed: feed)
    }
}


extension FeedsViewController : FeedsDatasource{
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
                feedsTable?.insertSections(IndexSet(integer: unwrappedInsertedIndexpath.row), with: .fade)
            }
        case .delete:
            if let unwrappedInsertedIndexpath = indexPath {
                feedsTable?.deleteSections(IndexSet(integer: unwrappedInsertedIndexpath.row), with: .fade)
            }
        case .update:
            if let unwrappedInsertedIndexpath = indexPath {
                feedsTable?.reloadSections(IndexSet(integer: unwrappedInsertedIndexpath.row), with: .fade)
            }
        case .move:
            if let unwrappedInsertedIndexpath = indexPath {
                if let unwrappedNewindexpath = newIndexPath {
                    print("<<<<<<<<<<, moved to row at \(unwrappedNewindexpath)")
                    feedsTable?.deleteSections(IndexSet(integer: unwrappedInsertedIndexpath.row), with: .fade)
                    feedsTable?.insertSections(IndexSet(integer: unwrappedNewindexpath.row), with: .fade)
                }
            }
        @unknown default:
            fatalError("unknown NSFetchedResultsChangeType")
        }
    }
    
    // did change
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        feedsTable?.endUpdates()
    }
}

