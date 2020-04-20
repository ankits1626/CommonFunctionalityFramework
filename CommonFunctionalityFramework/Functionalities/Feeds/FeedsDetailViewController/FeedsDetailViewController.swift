//
//  FeedsDetailViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

enum FeedDetailSection : Int {
    case FeedInfo = 0
    case ClapsSection
    case Comments 
}

class FeedsDetailViewController: UIViewController {
    var feedFetcher: CFFNetwrokRequestCoordinatorProtocol!
    @IBOutlet weak var commentBarView : ASChatBarview?
    @IBOutlet weak var feedDetailTableView : UITableView?
    var targetFeedItem : FeedsItemProtocol!
    var clappedByUsers : [ClappedByUser]?
    var comments : [FeedComment]?{
        didSet{
            feedDetailSectionFactory.refreshCommentsSection()
        }
    }
    
    var feedDetailDataFetcher: CFFNetwrokRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    
    lazy var feedDetailSectionFactory: FeedDetailSectionFactory = {
        return FeedDetailSectionFactory(self, mediaFetcher: mediaFetcher, targetTableView: feedDetailTableView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
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
                    self.comments = result
                case .SuccessWithNoResponseData:
                    fallthrough
                case .Failure(let _):
                    print("unable to fetch comments")
                }
            }
        }
    }
}

extension FeedsDetailViewController : FeedsDatasource{    
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
        
    func getComments() -> [FeedComment]?{
        return comments
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
