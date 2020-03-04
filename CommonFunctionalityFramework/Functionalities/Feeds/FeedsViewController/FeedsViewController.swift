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
        feeds.append(contentsOf: [
            RawFeed([
                "title" : "No media",
                "description" : "Description of the first post1",
                "created_on" : "2020-02-26T09:50:25.865732Z",
                "author" : ["name" : "Ankit", "department" : "IT"],
                "images" : [],
                "videos" : [],
                "post_type" : 1,
                "comments" : 1,
                "claps" : 0,
                "isClappedByMe": 1
            ]),
            RawFeed([
                "title" : "1 image",
                "description" : "Description of the first post2",
                "created_on" : "2020-02-26T09:50:25.865732Z",
                "author" : ["name" : "Ankit2", "department" : "IT2"],
                "images" : ["1"],
                "videos" : [],
                "post_type" : 1,
                "comments" : 10,
                "claps" : 1,
                "isClappedByMe": 1
            ]),
            RawFeed([
                "title" : "1 video",
                "description" : "Description of the first post3",
                "created_on" : "2020-02-26T09:50:25.865732Z",
                "author" : ["name" : "Ankit3", "department" : "IT3"],
                "images" : [],
                "videos" : ["1"],
                "post_type" : 1,
                "comments" : 100,
                "claps" : 8,
                "isClappedByMe": 1
            ]),
            RawFeed([
                "title" : "1 image 1 Video",
                "description" : "Description of the first post3",
                "created_on" : "2020-02-26T09:50:25.865732Z",
                "author" : ["name" : "Ankit3", "department" : "IT3"],
                "images" : ["1"],
                "videos" : ["1"],
                "post_type" : 1,
                "comments" : 100,
                "claps" : 8,
                "isClappedByMe": 1
            ]),
            RawFeed([
                "title" : "2 image 1 Video",
                "description" : "Description of the first post3",
                "created_on" : "2020-02-26T09:50:25.865732Z",
                "author" : ["name" : "Ankit3", "department" : "IT3"],
                "images" : ["1","2"],
                "videos" : ["1"],
                "post_type" : 1,
                "comments" : 100,
                "claps" : 8,
                "isClappedByMe": 1
            ]),
        ])
    }
    
    private func setupTableView(){
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
