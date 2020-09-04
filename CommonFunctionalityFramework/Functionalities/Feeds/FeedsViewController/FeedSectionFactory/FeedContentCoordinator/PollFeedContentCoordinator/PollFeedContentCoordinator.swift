//
//  PollFeedContentCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollFeedContentCoordinator  : FeedContentCoordinatorProtocol{
    var feedsDataSource: FeedsDatasource!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    private weak var targetTableView : UITableView?
    private weak var themeManager: CFFThemeManagerProtocol?
    lazy var cachedFeedCellCoordinators: [String : FeedCellCoordinatorProtocol] = {
        return [
            FeedTopTableViewCellType().cellIdentifier : FeedTopTableViewCellCoordinator(),
            FeedTitleTableViewCellType().cellIdentifier : FeedTitleTableViewCellCoordinator(),
            FeedTextTableViewCellType().cellIdentifier : FeedTextTableViewCellCoordinator(),
            PollOptionsTableViewCellType().cellIdentifier : PollOptionsTableViewCellCoordinator(),
            PollSubmitButtonCellType().cellIdentifier : PollSubmitButtonCellCoordinator(),
            PollBottomTableViewCelType().cellIdentifier : PollBottomTableViewCellCoordinator(),
            PollOptionsVotedTableViewCellType().cellIdentifier : PollOptionsVotedTableViewCellCoordinator(),
            FeedBottomTableViewCellType().cellIdentifier : FeedBottomTableViewCellCoordinator()
        ]
    }()

    init(feedsDatasource : FeedsDatasource, mediaFetcher: CFFMediaCoordinatorProtocol!, tableview : UITableView?, themeManager: CFFThemeManagerProtocol?) {
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
    
    
    func getRowsToRepresentAFeed(feedIndex : Int) -> [FeedCellTypeProtocol] {
        let feed = feedsDataSource.getFeedItem(feedIndex)
        var rows = [FeedCellTypeProtocol] ()
        rows.append(FeedTopTableViewCellType())
        if feed.getFeedTitle() != nil {
            rows.append(FeedTitleTableViewCellType())
        }
        if feed.getFeedDescription() != nil{
            rows.append(FeedTextTableViewCellType())
        }
        
        if let unwrappedPoll = feed.getPoll(){
            if unwrappedPoll.isPollActive() && !unwrappedPoll.hasUserVoted(){
                feed.getPoll()?.getPollOptions().forEach { (_) in
                    rows.append(PollOptionsTableViewCellType())
                }
                rows.append(PollSubmitButtonCellType())
            }else{
                feed.getPoll()?.getPollOptions().forEach { (_) in
                    rows.append(PollOptionsVotedTableViewCellType())
                }
            }
        }
        
//        if feed.getPoll()!.isPollActive(){
//            if !feed.getPoll()!.hasUserVoted(){
//                rows.append(PollSubmitButtonCellType())
//            }
//        }
        rows.append(PollBottomTableViewCelType())
        rows.append(FeedBottomTableViewCellType())
//        if let poll = feed.getPoll(),
//            !poll.isPollActive(){
//            rows.append(FeedBottomTableViewCellType())
//        }
        return rows
    }
    
    func getCell(_ inputModel: FeedContentGetCellModel) -> UITableViewCell{
        return getCellCoordinator(indexPath: inputModel.targetIndexpath).getCell(FeedCellDequeueModel(
            targetIndexpath: inputModel.targetIndexpath,
            targetTableView: targetTableView!,
            datasource: feedsDataSource
            )
        )
    }
    
    func configureCell(_ inputModel: FeedContentConfigureCellModel){
        getCellCoordinator(indexPath: inputModel.targetIndexpath).loadDataCell(
            FeedCellLoadDataModel(
                targetIndexpath: inputModel.targetIndexpath,
                targetTableView: targetTableView,
                targetCell: inputModel.targetCell,
                datasource: feedsDataSource,
                mediaFetcher: mediaFetcher,
                delegate: inputModel.delegate,
                selectedoptionMapper: inputModel.selectedoptionMapper,
                themeManager: inputModel.themeManager
            )
        )
    }
    
    func getHeightOfCell(_ inputModel: FeedContentGetHeightOfCellModel) -> CGFloat{
        return getCellCoordinator(indexPath: inputModel.targetIndexpath).getHeight(
            FeedCellGetHeightModel(
                targetIndexpath: inputModel.targetIndexpath,
                datasource: feedsDataSource
            )
        )
    }
    
    private func getCellCoordinator(indexPath : IndexPath) -> FeedCellCoordinatorProtocol {
        let allRowsForFeed = getRowsToRepresentAFeed(feedIndex: indexPath.section)
        let cellType = allRowsForFeed[indexPath.row]
        return cachedFeedCellCoordinators[cellType.cellIdentifier]!
    }
    
    func registerTableViewToRespectiveCellType(cellType: FeedCellTypeProtocol, tableView: UITableView?) {
        print("<<<<<<<<<<<<<<<< registering tableview for \(cellType.cellIdentifier), \(cellType.cellNib)")
        tableView?.register(
            cellType.cellNib,
            forCellReuseIdentifier: cellType.cellIdentifier
        )
    }
    
}
