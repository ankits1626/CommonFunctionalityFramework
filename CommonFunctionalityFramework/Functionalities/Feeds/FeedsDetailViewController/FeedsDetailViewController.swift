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
    var comments : [FeedComment]?
    
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
    
    func getFeedItem() -> FeedsItemProtocol{
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
        return feedDetailSectionFactory.getCell(indexPath: indexPath, tableView: tableView)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        feedDetailSectionFactory.configureCell(cell: cell, indexPath: indexPath, delegate: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return feedDetailSectionFactory.getHeightOfCell(indexPath: indexPath)
    }
}

extension FeedsDetailViewController : FeedsDelegate{
    func showFeedEditOptions(targetView : UIView?, feedIdentifier : Int64) {
        
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
        
    }
    
}
