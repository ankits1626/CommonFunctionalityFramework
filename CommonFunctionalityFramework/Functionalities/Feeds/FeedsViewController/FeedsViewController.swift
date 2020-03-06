//
//  FeedsViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/03/20.
//  Copyright © 2020 Rewardz Private Limited. All rights reserved.
//

import UIKit
class FeedsViewController: UIViewController {
    @IBOutlet private weak var feedsTable : UITableView?
    @IBOutlet private weak var whatsInYourMindView : UIView?
    @IBOutlet private weak var cameraContainerViewView : UIView?
    
    var feedFetcher: CFFNetwrokRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var feedCoordinatorDeleagate: FeedsCoordinatorDelegate!
    
    lazy var feedSectionFactory: FeedSectionFactory = {
        return FeedSectionFactory(feedsDatasource: self, mediaFetcher: mediaFetcher)
    }()
    
    var feeds = [FeedsItemProtocol]()
    var lastFetchedFeeds : FetchedFeedModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFeeds()
        setup()
    }
    
    private func loadFeeds(){
        feedFetcher.getFeeds(request: FetchFeedRequest(nextPageUrl: nil)) { (fetchedFeeds) in
            self.handleFetchedFeedsResult(fetchedfeeds: fetchedFeeds)
        }
    }
    
    private func handleFetchedFeedsResult (fetchedfeeds : FetchedFeedModel){
        self.lastFetchedFeeds = fetchedfeeds
        loadfetchedFeeds()
    }
    
    private func loadfetchedFeeds(){
        var tempfeeds = [FeedsItemProtocol]()
        if let fetchedFeeds = lastFetchedFeeds?.fetchedRawFeeds?["results"] as? [[String : Any]]{
            fetchedFeeds.forEach { (aRawFeed) in
                tempfeeds.append(RawFeed(aRawFeed))
            }
        }
        DispatchQueue.main.async {
            self.feeds = tempfeeds
            self.feedsTable?.reloadData()
        }
    }
    
    private func setup(){
        setupTopBar()
        setupTableView()
    }
    
    private func setupTopBar(){
        whatsInYourMindView?.curvedCornerControl()
        whatsInYourMindView?.backgroundColor = UIColor.grayBackGroundColor()
        cameraContainerViewView?.curvedCornerControl()
        cameraContainerViewView?.backgroundColor = UIColor.grayBackGroundColor()
    }
    
    private func setupTableView(){
        feedsTable?.tableFooterView = UIView(frame: CGRect.zero)
        feedsTable?.rowHeight = UITableView.automaticDimension
        feedsTable?.estimatedRowHeight = 140
        feedsTable?.dataSource = self
        feedsTable?.delegate = self
        feedSectionFactory.registerFeedstableWithRespectiveCells(feedsTable)
        feedsTable?.reloadData()
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
        feedSectionFactory.configureCell(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        feedSectionFactory.getHeightOfCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedDetailVC = FeedsDetailViewController(nibName: "FeedsDetailViewController", bundle: Bundle(for: FeedsDetailViewController.self))
        feedCoordinatorDeleagate.showFeedDetail(feedDetailVC)
    }
}

extension FeedsViewController : FeedsDatasource{
    func getNumberOfItems() -> Int {
        return feeds.count
    }
    
    func getFeedItem(_ index: Int) -> FeedsItemProtocol {
        return feeds[index]
    }
}
