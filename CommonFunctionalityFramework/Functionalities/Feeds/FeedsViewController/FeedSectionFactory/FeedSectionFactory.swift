//
//  FeedSectionFactory.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

protocol FeedsCustomCellProtcol {
    var containerView : UIView?{set get}
}

protocol FeedsDatasource : AnyObject {
    func getNumberOfItems() -> Int
    func getFeedItem(_ index: Int) -> FeedsItemProtocol
    func getFeedItem() -> FeedsItemProtocol!
    func getClappedByUsers() -> [ClappedByUser]?
    func getCommentProvider() -> FeedsDetailCommentsProviderProtocol?
    func showShowFullfeedDescription() -> Bool
    func shouldShowMenuOptionForFeed() -> Bool
    func getPostShareOption() -> SharePostOption
    func getPostSharedWithOrgAndDepartment() -> FeedOrganisationDepartmentSelectionDisplayModel?
}

protocol FeedsDelegate : AnyObject {
    func showFeedEditOptions(targetView : UIView?, feedIdentifier : Int64)
    func showLikedByUsersList()
    func showPostReactions()
    func showMediaBrowser(feedIdentifier : Int64,scrollToItemIndex: Int)
    func toggleClapForPost(feedIdentifier : Int64)
    func toggleLikeForComment(commentIdentifier : Int64)
    func selectPollAnswer(feedIdentifier : Int64, pollOption: PollOption)
    func submitPollAnswer(feedIdentifier : Int64)
    func showAllClaps(feedIdentifier : Int64)
    func pinToPost(feedIdentifier : Int64, isAlreadyPinned : Bool)
    func postReaction(feedId: Int64, reactionType: String)
    func showPostReactions(feedIdentifier : Int64)
    func deleteComment(commentIdentifier : Int64)
    func editComment(commentIdentifier : Int64, chatMessage : String, commentedByPk : Int)
}

class FeedSectionFactory{
    private let  feedsDatasource : FeedsDatasource!
    private var  selectedTab = ""
    private var mediaFetcher: CFFMediaCoordinatorProtocol!
    private var cachedFeedContentCoordinator = [FeedType : FeedContentCoordinatorProtocol]()
    private weak var targetTableView : UITableView?
    private weak var selectedOptionMapper : SelectedPollAnswerMapper?
    private weak var themeManager: CFFThemeManagerProtocol?
    private weak var mainAppCoordinator : CFFMainAppInformationCoordinator?

    init(feedsDatasource : FeedsDatasource, mediaFetcher: CFFMediaCoordinatorProtocol!, targetTableView : UITableView?, selectedOptionMapper : SelectedPollAnswerMapper, themeManager: CFFThemeManagerProtocol?, selectedTab: String, mainAppCoordinator : CFFMainAppInformationCoordinator?) {
        self.feedsDatasource = feedsDatasource
        self.selectedTab = selectedTab
        self.mediaFetcher = mediaFetcher
        self.targetTableView = targetTableView
        self.selectedOptionMapper = selectedOptionMapper
        self.themeManager = themeManager
        self.mainAppCoordinator = mainAppCoordinator
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
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath, delegate : FeedsDelegate)  {
        let feedItem = feedsDatasource.getFeedItem(indexPath.section)
        getContentCoordinator(feedType: feedItem.getFeedType()).configureCell(
            FeedContentConfigureCellModel(
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
        switch feedType {
        case .Poll:
            return PollFeedContentCoordinator(
                feedsDatasource: feedsDatasource,
                mediaFetcher: mediaFetcher,
                tableview: targetTableView,
                themeManager: themeManager, selectedTab: selectedTab
            )
        case .Post:
            return PostFeedContentCoordinator(
                feedsDatasource: feedsDatasource,
                mediaFetcher: mediaFetcher,
                tableview: targetTableView,
                themeManager: themeManager, selectedTab: selectedTab, mainAppCoordinator: mainAppCoordinator
            )
        
        case .Greeting:
            return PostFeedContentCoordinator(
                feedsDatasource: feedsDatasource,
                mediaFetcher: mediaFetcher,
                tableview: targetTableView,
                themeManager: themeManager, selectedTab: selectedTab, mainAppCoordinator: mainAppCoordinator
            )
        }
    }
}
