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
    lazy var feedSectionFactory: FeedSectionFactory = {
        return FeedSectionFactory(feedsDatasource: self)
    }()
    
    var feeds = [FeedsItemProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDummyFeeds()
        setupTableView()
    }
    
    private func loadDummyFeeds(){
        feeds = DummyFeedProvider.getDummyFeeds()
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
}

extension FeedsViewController : FeedsDatasource{
    func getNumberOfItems() -> Int {
        return feeds.count
    }
    
    func getFeedItem(_ index: Int) -> FeedsItemProtocol {
        return feeds[index]
    }
}
