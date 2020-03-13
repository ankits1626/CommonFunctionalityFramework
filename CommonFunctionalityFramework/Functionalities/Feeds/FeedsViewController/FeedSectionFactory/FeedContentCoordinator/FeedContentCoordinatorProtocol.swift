//
//  FeedContentCoordinatorProtocol.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

protocol FeedCellTypeProtocol {
    var cellNib : UINib?{get}
    var cellIdentifier : String {get}
}

protocol FeedCellCoordinatorProtocol {
    var cellType : FeedCellTypeProtocol {get}
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell
    func loadDataCell(_ inputModel: FeedCellLoadDataModel)
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat
}

extension FeedCellCoordinatorProtocol{
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
}

struct FeedContentGetCellModel {
    var targetIndexpath : IndexPath
}

struct FeedContentConfigureCellModel {
    var targetIndexpath : IndexPath
    var targetCell : UITableViewCell
    var delegate : FeedsDelegate
}

struct FeedContentGetHeightOfCellModel {
    var targetIndexpath : IndexPath
}

protocol FeedContentCoordinatorProtocol {
    var feedsDataSource : FeedsDatasource! {set get}
    func registerTableViewForAllPossibleCellTypes(_ tableView : UITableView? )
    func getRowsToRepresentAFeed(feedIndex : Int) -> [FeedCellTypeProtocol]
    func getCell(_ inputModel: FeedContentGetCellModel) -> UITableViewCell
    func configureCell(_ inputModel: FeedContentConfigureCellModel)
    func getHeightOfCell(_ inputModel: FeedContentGetHeightOfCellModel) -> CGFloat
}


class PostFeedContentCoordinator  : FeedContentCoordinatorProtocol{
    var feedsDataSource: FeedsDatasource!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    private weak var targetTableView : UITableView?
    lazy var cachedFeedCellCoordinators: [String : FeedCellCoordinatorProtocol] = {
        return [
            FeedTopTableViewCellType().cellIdentifier : FeedTopTableViewCellCoordinator(),
            FeedTitleTableViewCellType().cellIdentifier : FeedTitleTableViewCellCoordinator(),
            FeedTextTableViewCellType().cellIdentifier : FeedTextTableViewCellCoordinator(),
            SingleImageTableViewCellType().cellIdentifier : SingleImageTableViewCellCoordinator(),
            SingleVideoTableViewCellType().cellIdentifier : SingleVideoTableViewCellCoordinator(),
            MultipleMediaTableViewCellType().cellIdentifier : MultipleMediaTableViewCellCoordinator(),
            FeedBottomTableViewCellType().cellIdentifier : FeedBottomTableViewCellCoordinator()
        ]
    }()

    init(feedsDatasource : FeedsDatasource, mediaFetcher: CFFMediaCoordinatorProtocol!, tableview : UITableView?) {
        self.feedsDataSource = feedsDatasource
        self.mediaFetcher = mediaFetcher
        self.targetTableView = tableview
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
        switch feed.getMediaCountState() {
        case .None:
            break
        case .OneMediaItemPresent(let mediaType):
            switch mediaType {
            case .Image:
                rows.append(SingleImageTableViewCellType())
            case .Video:
                rows.append(SingleVideoTableViewCellType())
            }
        case .TwoMediaItemPresent:
            fallthrough
        case .MoreThanTwoMediItemPresent:
            rows.append(MultipleMediaTableViewCellType())
        }
        rows.append(FeedBottomTableViewCellType())
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
                targetCell: inputModel.targetCell,
                datasource: feedsDataSource,
                mediaFetcher: mediaFetcher,
                delegate: inputModel.delegate
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
