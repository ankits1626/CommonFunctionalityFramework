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
    
    var requestCoordinator: CFFNetwrokRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var feedCoordinatorDeleagate: FeedsCoordinatorDelegate!
    
    lazy var feedSectionFactory: FeedSectionFactory = {
        return FeedSectionFactory(feedsDatasource: self, mediaFetcher: mediaFetcher, targetTableView: feedsTable)
    }()
    
    var feeds = [FeedsItemProtocol]()
    var lastFetchedFeeds : FetchedFeedModel?
    
    private lazy var refreshControl : UIRefreshControl  = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadFeeds), for: .valueChanged)
        refreshControl.backgroundColor = .black
        refreshControl.tintColor = .white //Rgbconverter.HexToColor(get_backgroundColor(), alpha: 1.0)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFeeds()
        setup()
    }
    
    @objc private func loadFeeds(){
        FeedFetcher(networkRequestCoordinator: requestCoordinator).fetchFeeds(
        nextPageUrl: nil) { (result) in
            DispatchQueue.main.async {
                switch result{
                    
                case .Success(let result):
                    self.handleFetchedFeedsResult(fetchedfeeds: result)
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
        var tempfeeds = [FeedsItemProtocol]()
        if let fetchedFeeds = lastFetchedFeeds?.fetchedRawFeeds?["results"] as? [[String : Any]]{
            fetchedFeeds.forEach { (aRawFeed) in
                tempfeeds.append(RawFeed(aRawFeed))
            }
        }
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
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
        feedsTable?.addSubview(refreshControl)
        feedsTable?.tableFooterView = UIView(frame: CGRect.zero)
        feedsTable?.rowHeight = UITableView.automaticDimension
        feedsTable?.estimatedRowHeight = 140
        feedsTable?.dataSource = self
        feedsTable?.delegate = self
        feedsTable?.reloadData()
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
        let feedDetailVC = FeedsDetailViewController(nibName: "FeedsDetailViewController", bundle: Bundle(for: FeedsDetailViewController.self))
        feedDetailVC.targetFeedItem = feeds[indexPath.section]
        feedDetailVC.mediaFetcher = mediaFetcher
        feedCoordinatorDeleagate.showFeedDetail(feedDetailVC)
    }
}

extension FeedsViewController : FeedsDelegate{
    func showFeedEditOptions(targetView : UIView?, feedIdentifier : Int64) {
        print("show edit option")
        let options = FloatingMenuOptions(options: [
            FloatingMenuOption(title: "EDIT", action: {
                print("Edit post - \(feedIdentifier)")
            }),
            FloatingMenuOption(title: "DELETE", action: {
                print("Delete post- \(feedIdentifier)")
            })
        ])
        options.showPopover(sourceView: targetView!)
    }
}


extension FeedsViewController : FeedsDatasource{
    func getTargetPost() -> EditablePostProtocol? {
        return nil
    }
    
    func showShowFullfeedDescription() -> Bool {
        return false
    }
    
    func getFeedItem() -> FeedsItemProtocol {
        return feeds.first!
    }
    
    func getClappedByUsers() -> [ClappedByUser]? {
        return nil
    }
    
    func getComments() -> [FeedComment]? {
        return nil
    }
    
    func getNumberOfItems() -> Int {
        return feeds.count
    }
    
    func getFeedItem(_ index: Int) -> FeedsItemProtocol {
        return feeds[index]
    }
}

