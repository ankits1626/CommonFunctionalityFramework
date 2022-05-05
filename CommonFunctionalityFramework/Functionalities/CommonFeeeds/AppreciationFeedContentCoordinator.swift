//
//  AppreciationFeedContentCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 03/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class AppreciationFeedContentCoordinator  : CommonFeedContentCoordinatorProtocol{
        
    var feedsDataSource: CommonFeedsDatasource!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    private weak var targetTableView : UITableView?
    private weak var themeManager: CFFThemeManagerProtocol?
    lazy var cachedFeedCellCoordinators: [String : CommonFeedCellCoordinatorProtocol] = {
        return [
            CommonFeedsTopTableViewCellType().cellIdentifier : CommonFeedTopTableViewCellCoordinator(),
            CommonAppreciationSubjectTableViewCellType().cellIdentifier : CommonAppreciationSubjectTableViewCellCoordinator(),
            CommonLikesSectionTableViewCellType().cellIdentifier : LikesSectionTableViewCellCoordinator(),
            CommonPressLikeButtonTableViewCellType().cellIdentifier : CommonLikesTableViewCellCoordinator()
        ]
    }()

    init(feedsDatasource : CommonFeedsDatasource, mediaFetcher: CFFMediaCoordinatorProtocol!, tableview : UITableView?, themeManager: CFFThemeManagerProtocol?) {
        self.feedsDataSource = feedsDatasource
        self.mediaFetcher = mediaFetcher
        self.targetTableView = tableview
        self.themeManager = themeManager
        registerTableViewForAllPossibleCellTypes(tableview)
    }
    
    internal func registerTableViewForAllPossibleCellTypes(_ tableView : UITableView? ){
        cachedFeedCellCoordinators.forEach { (cellCoordinator) in
            self.registerTableViewToRespectiveCellType(cellType: cellCoordinator.value.cellType, tableView: tableView)
        }
    }
    
    
    func getRowsToRepresentAFeed(feedIndex : Int) -> [CommonFeedCellTypeProtocol] {
        let feed = feedsDataSource.getFeedItem(feedIndex)
        var rows = [CommonFeedCellTypeProtocol] ()
        rows.append(CommonFeedsTopTableViewCellType())
        rows.append(CommonAppreciationSubjectTableViewCellType())
        rows.append(CommonLikesSectionTableViewCellType())
        rows.append(CommonPressLikeButtonTableViewCellType())
        
//        if feed.getFeedTitle() != nil {
//            rows.append(FeedTitleTableViewCellType())
//        }
//        if feed.getFeedDescription() != nil{
//            rows.append(FeedTextTableViewCellType())
//        }
//
//        if let unwrappedPoll = feed.getPoll(){
//            if unwrappedPoll.isPollActive() && !unwrappedPoll.hasUserVoted(){
//                feed.getPoll()?.getPollOptions().forEach { (_) in
//                    rows.append(PollOptionsTableViewCellType())
//                }
//                rows.append(PollSubmitButtonCellType())
//            }else{
//                feed.getPoll()?.getPollOptions().forEach { (_) in
//                    rows.append(PollOptionsVotedTableViewCellType())
//                }
//            }
//        }
        
//        if feed.getPoll()!.isPollActive(){
//            if !feed.getPoll()!.hasUserVoted(){
//                rows.append(PollSubmitButtonCellType())
//            }
//        }
//        rows.append(PollBottomTableViewCelType())
//        rows.append(FeedBottomTableViewCellType())
//        if let poll = feed.getPoll(),
//            !poll.isPollActive(){
//            rows.append(FeedBottomTableViewCellType())
//        }
        return rows
    }
    
    func getCell(_ inputModel: FeedContentGetCellModel) -> UITableViewCell{
        return getCellCoordinator(indexPath: inputModel.targetIndexpath).getCell(CommonFeedCellDequeueModel(
            targetIndexpath: inputModel.targetIndexpath,
            targetTableView: targetTableView!,
            datasource: feedsDataSource,
            isFeedDetailPage: false,
            themeManager: themeManager
            )
        )
    }
    
    func configureCell(_ inputModel: CommonFeedContentConfigureCellModel){
        getCellCoordinator(indexPath: inputModel.targetIndexpath).loadDataCell(
            CommonFeedCellLoadDataModel(
                targetIndexpath: inputModel.targetIndexpath,
                targetTableView: targetTableView,
                targetCell: inputModel.targetCell,
                datasource: feedsDataSource,
                mediaFetcher: mediaFetcher,
                delegate: inputModel.delegate,
                selectedoptionMapper: inputModel.selectedoptionMapper,
                themeManager: inputModel.themeManager,
                isFeedDetailPage: false
            )
        )
    }
    
    func getHeightOfCell(_ inputModel: FeedContentGetHeightOfCellModel) -> CGFloat{
        return getCellCoordinator(indexPath: inputModel.targetIndexpath).getHeight(
            CommonFeedCellGetHeightModel(
                targetIndexpath: inputModel.targetIndexpath,
                datasource: feedsDataSource
            )
        )
    }
    
    private func getCellCoordinator(indexPath : IndexPath) -> CommonFeedCellCoordinatorProtocol {
        let allRowsForFeed = getRowsToRepresentAFeed(feedIndex: indexPath.section)
        let cellType = allRowsForFeed[indexPath.row]
        return cachedFeedCellCoordinators[cellType.cellIdentifier]!
    }
    
    func registerTableViewToRespectiveCellType(cellType: CommonFeedCellTypeProtocol, tableView: UITableView?) {
        print("<<<<<<<<<<<<<<<< registering tableview for \(cellType.cellIdentifier), \(cellType.cellNib)")
        tableView?.register(
            cellType.cellNib,
            forCellReuseIdentifier: cellType.cellIdentifier
        )
    }
    
}

