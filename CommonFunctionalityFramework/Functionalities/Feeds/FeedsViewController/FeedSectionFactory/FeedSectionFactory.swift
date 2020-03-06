//
//  FeedSectionFactory.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

protocol FeedsDatasource {
    func getNumberOfItems() -> Int
    func getFeedItem(_ index: Int) -> FeedsItemProtocol
}

class FeedSectionFactory{
    private let  feedsDatasource : FeedsDatasource!
    private var mediaFetcher: CFFMediaCoordinatorProtocol!
    private var cachedFeedContentCoordinator = [FeedType : FeedContentCoordinatorProtocol]()
    
    init(feedsDatasource : FeedsDatasource, mediaFetcher: CFFMediaCoordinatorProtocol!) {
        self.feedsDatasource = feedsDatasource
        self.mediaFetcher = mediaFetcher
    }
    
    func registerFeedstableWithRespectiveCells(_ feedsTable : UITableView?)  {}
    
    func getNumberOfSections() -> Int {
        return feedsDatasource.getNumberOfItems()
    }
    
    func getNumberOfRows(section : Int) -> Int {
        let feedItem = feedsDatasource.getFeedItem(section)
        return getContentCoordinator(feedType: feedItem.getFeedType()).getRowsToRepresentAFeed(feedIndex: section).count
    }
    
    func getCell(indexPath : IndexPath, tableView: UITableView) -> UITableViewCell {
        let feedItem = feedsDatasource.getFeedItem(indexPath.section)
        return getContentCoordinator(feedType: feedItem.getFeedType()).getCell(
            FeedContentGetCellModel(
                targetIndexpath: indexPath,
                targetTableView: tableView)
        )
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath)  {
        let feedItem = feedsDatasource.getFeedItem(indexPath.section)
        getContentCoordinator(feedType: feedItem.getFeedType()).configureCell(
            FeedContentConfigureCellModel(
                targetIndexpath: indexPath,
                targetCell: cell
            )
        )
    }
    
    func getHeightOfCell(indexPath: IndexPath) -> CGFloat {
        let feedItem = feedsDatasource.getFeedItem(indexPath.section)
        return getContentCoordinator(feedType: feedItem.getFeedType()).getHeightOfCell(
            FeedContentGetHeightOfCellModel(targetIndexpath: indexPath)
        )
    }
    
    private func getContentCoordinator(feedType : FeedType) -> FeedContentCoordinatorProtocol{
        if let cachedCoordinator = cachedFeedContentCoordinator[feedType]{
            return cachedCoordinator
        }else{
            let coordinator = getFeedContentCoordinator(feedType: feedType)
            cachedFeedContentCoordinator[feedType] = coordinator
            return coordinator
        }
    }
    
    func getFeedContentCoordinator(feedType : FeedType) -> FeedContentCoordinatorProtocol {
        return PostFeedContentCoordinator(feedsDatasource: feedsDatasource, mediaFetcher: mediaFetcher)
    }
}
