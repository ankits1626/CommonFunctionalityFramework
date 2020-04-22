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
class FeedsDetailViewController: UIViewController {
    var feedFetcher: CFFNetwrokRequestCoordinatorProtocol!
    @IBOutlet weak var commentBarView : ASChatBarview?
    @IBOutlet weak var feedDetailTableView : UITableView?
    var targetFeedItem : FeedsItemProtocol!
    var clappedByUsers : [ClappedByUser]?
    var feedDetailDataFetcher: CFFNetwrokRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    
    lazy var feedDetailSectionFactory: FeedDetailSectionFactory = {
        return FeedDetailSectionFactory(self, mediaFetcher: mediaFetcher, targetTableView: feedDetailTableView)
    }()
    private var frc : NSFetchedResultsController<ManagedPostComment>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearAnyExistingFeedsData {[weak self] in
            self?.initializeFRC()
            self?.setup()
        }
    }
    
    private func setup(){
        setupTableView()
    }
    
    private func setupTableView(){
        feedDetailTableView?.tableFooterView = UIView(frame: CGRect.zero)
        feedDetailTableView?.rowHeight = UITableView.automaticDimension
        feedDetailTableView?.estimatedRowHeight = 140
        feedDetailTableView?.dataSource = self
        feedDetailTableView?.delegate = self
        feedDetailTableView?.reloadData()
    }
    
    private func initializeFRC() {
        let fetchRequest: NSFetchRequest<ManagedPostComment> = ManagedPostComment.fetchRequest()
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
    
    private func fetchComments(){
        FeedCommentsFetcher(networkRequestCoordinator: feedDetailDataFetcher).fetchComments(
        feedId: targetFeedItem.feedIdentifier) { (result) in
            DispatchQueue.main.async {
                switch result{
                case .Success(let result):
                    CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                        result.forEach { (aRawComment) in
                            let _ = aRawComment.getManagedObject() as! ManagedPostComment
                        }
                        CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                            CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
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
        feedDetailSectionFactory.configureCell(cell: cell, indexPath: indexPath, delegate: self)
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
}

extension FeedsDetailViewController : FeedsDelegate{
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
        
    }
    
    func showLikedByUsersList() {
        let allLikedVc = LikeListViewController(nibName: "LikeListViewController", bundle: Bundle(for: LikeListViewController.self))
        present(allLikedVc, animated: true, completion: nil)
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
            FeedCommentPostWorker(networkRequestCoordinator: feedDetailDataFetcher).postComment(
                comment: PostbaleComment(
                    feedId: targetFeedItem.feedIdentifier,
                    commentText: message)) { (result) in
                        DispatchQueue.main.async {
                            switch result{
                            case .Success(let result):
                                fallthrough
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
        feedDetailTableView?.endUpdates()
    }
}
