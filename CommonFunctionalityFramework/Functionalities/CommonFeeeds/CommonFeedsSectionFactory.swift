//
//  CommonFeedsSectionFactory.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 03/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit


protocol CommonFeedsDatasource {
    func getNumberOfItems() -> Int
    func getFeedItem(_ index: Int) -> FeedsItemProtocol
    func getFeedItem() -> FeedsItemProtocol!
    func getClappedByUsers() -> [ClappedByUser]?
    func getCommentProvider() -> FeedsDetailCommentsProviderProtocol?
    func showShowFullfeedDescription() -> Bool
    func shouldShowMenuOptionForFeed() -> Bool
}

protocol CommonFeedsDelegate : class {
    func showFeedEditOptions(targetView : UIView?, feedIdentifier : Int64)
    func showLikedByUsersList()
    func showMediaBrowser(feedIdentifier : Int64,scrollToItemIndex: Int)
    func toggleClapForPost(feedIdentifier : Int64)
    func toggleLikeForComment(commentIdentifier : Int64)
    func selectPollAnswer(feedIdentifier : Int64, pollOption: PollOption)
    func submitPollAnswer(feedIdentifier : Int64)
    func showAllClaps(feedIdentifier : Int64)
    func pinToPost(feedIdentifier : Int64, isAlreadyPinned : Bool)
    func showPostReactions(feedIdentifier : Int64)
    func postReaction(feedId: Int64, reactionType: String)
}

class CommonFeedsSectionFactory{
    private let  feedsDatasource : CommonFeedsDatasource!
    private var mediaFetcher: CFFMediaCoordinatorProtocol!
    private var cachedFeedContentCoordinator = [FeedType : CommonFeedContentCoordinatorProtocol]()
    private weak var targetTableView : UITableView?
    private weak var selectedOptionMapper : SelectedPollAnswerMapper?
    private weak var themeManager: CFFThemeManagerProtocol?
    private var selectedTab : String?

    init(feedsDatasource : CommonFeedsDatasource, mediaFetcher: CFFMediaCoordinatorProtocol!, targetTableView : UITableView?, selectedOptionMapper : SelectedPollAnswerMapper, themeManager: CFFThemeManagerProtocol?, selectedTab: String) {
        self.feedsDatasource = feedsDatasource
        self.mediaFetcher = mediaFetcher
        self.targetTableView = targetTableView
        self.selectedOptionMapper = selectedOptionMapper
        self.themeManager = themeManager
        self.selectedTab = selectedTab
    }
    
    func getNumberOfSections() -> Int {
        return feedsDatasource.getNumberOfItems()
    }
    
    func getNumberOfRows(section : Int) -> Int {
        let feedItem = feedsDatasource.getFeedItem(section)
        return getContentCoordinator(feedType: feedItem.getFeedType()).getRowsToRepresentAFeed(feedIndex: section).count
    }
    
    func getCell(indexPath : IndexPath, tableView: UITableView) -> UITableViewCell {
        let feedItem = feedsDatasource.getFeedItem(indexPath.section)
        let cell = getContentCoordinator(feedType: feedItem.getFeedType()).getCell(
            FeedContentGetCellModel(targetIndexpath: indexPath)
        )
        cell.backgroundColor = .clear
        if let containerdCell = cell as? FeedsCustomCellProtcol{
            containerdCell.containerView?.backgroundColor = .white
        }
        return cell
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath, delegate : CommonFeedsDelegate)  {
        let feedItem = feedsDatasource.getFeedItem(indexPath.section)
        getContentCoordinator(feedType: feedItem.getFeedType()).configureCell(
            CommonFeedContentConfigureCellModel(
                targetIndexpath: indexPath,
                targetCell: cell,
                delegate: delegate,
                selectedoptionMapper: selectedOptionMapper,
                themeManager: themeManager
            )
        )
    }
    
    func getHeightOfCell(indexPath: IndexPath) -> CGFloat {
        let feedItem = feedsDatasource.getFeedItem(indexPath.section)
        return getContentCoordinator(feedType: feedItem.getFeedType()).getHeightOfCell(
            FeedContentGetHeightOfCellModel(targetIndexpath: indexPath)
        )
    }
    
    private func getContentCoordinator(feedType : FeedType) -> CommonFeedContentCoordinatorProtocol{
        if let cachedCoordinator = cachedFeedContentCoordinator[feedType]{
            return cachedCoordinator
        }else{
            let coordinator = getFeedContentCoordinator(feedType: feedType)
            cachedFeedContentCoordinator[feedType] = coordinator
            return coordinator
        }
    }
    
    func getFeedContentCoordinator(feedType : FeedType) -> CommonFeedContentCoordinatorProtocol {
        switch feedType {
        case .Poll:
            return AppreciationFeedContentCoordinator(
                feedsDatasource: feedsDatasource,
                mediaFetcher: mediaFetcher,
                tableview: targetTableView,
                themeManager: themeManager, selectedTab: selectedTab ?? ""
            )
        case .Post:
            return NominationFeedContentCoordinator(
                feedsDatasource: feedsDatasource,
                mediaFetcher: mediaFetcher,
                tableview: targetTableView,
                themeManager: themeManager, selectedTab: selectedTab ?? ""
            )
        case .Greeting:
            return NominationFeedContentCoordinator(
                feedsDatasource: feedsDatasource,
                mediaFetcher: mediaFetcher,
                tableview: targetTableView,
                themeManager: themeManager, selectedTab: selectedTab ?? ""
            )
        }
    }
}

