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
    func getCellCoordinator() -> FeedCellCoordinatorProtocol
}

protocol FeedCellCoordinatorProtocol {
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell
    func loadDataCell(_ inputModel: FeedCellLoadDataModel)
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat
}

struct FeedContentGetCellModel {
    var targetIndexpath : IndexPath
    var targetTableView : UITableView
}

struct FeedContentConfigureCellModel {
    var targetIndexpath : IndexPath
    var targetCell : UITableViewCell
}

struct FeedContentGetHeightOfCellModel {
    var targetIndexpath : IndexPath
}

protocol FeedContentCoordinatorProtocol {
    var feedsDataSource : FeedsDatasource! {set get}
    func getRowsToRepresentAFeed(feedIndex : Int) -> [FeedCellTypeProtocol]
    func getCell(_ inputModel: FeedContentGetCellModel) -> UITableViewCell
    func configureCell(_ inputModel: FeedContentConfigureCellModel)
    func getHeightOfCell(_ inputModel: FeedContentGetHeightOfCellModel) -> CGFloat
}


class PostFeedContentCoordinator  : FeedContentCoordinatorProtocol{
    var feedsDataSource: FeedsDatasource!
    private var cachedFeedCellCoordinators = [String : FeedCellCoordinatorProtocol]()
    init(feedsDatasource : FeedsDatasource) {
        self.feedsDataSource = feedsDatasource
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
        let allRowsForFeed = getRowsToRepresentAFeed(feedIndex: inputModel.targetIndexpath.section)
        let cellType = allRowsForFeed[inputModel.targetIndexpath.row]
        return getCellCoordinator(indexPath: inputModel.targetIndexpath, tableView: inputModel.targetTableView).getCell(FeedCellDequeueModel(
            targetIndexpath: inputModel.targetIndexpath,
            targetTableView: inputModel.targetTableView,
            cellIdentifier: cellType.cellIdentifier
            )
        )
    }
    
    func configureCell(_ inputModel: FeedContentConfigureCellModel){
        getCellCoordinator(indexPath: inputModel.targetIndexpath, tableView: nil).loadDataCell(
            FeedCellLoadDataModel(
                targetIndexpath: inputModel.targetIndexpath,
                targetCell: inputModel.targetCell,
                datasource: feedsDataSource
            )
        )
    }
    
    func getHeightOfCell(_ inputModel: FeedContentGetHeightOfCellModel) -> CGFloat{
        return getCellCoordinator(indexPath: inputModel.targetIndexpath, tableView: nil).getHeight(
            FeedCellGetHeightModel(
                targetIndexpath: inputModel.targetIndexpath,
                datasource: feedsDataSource
            )
        )
    }
    
    private func getCellCoordinator(indexPath : IndexPath, tableView: UITableView?) -> FeedCellCoordinatorProtocol {
        let allRowsForFeed = getRowsToRepresentAFeed(feedIndex: indexPath.section)
        let cellType = allRowsForFeed[indexPath.row]
        if let cacehedCoordinator = cachedFeedCellCoordinators[cellType.cellIdentifier]{
            return cacehedCoordinator
        }else{
            let coordinator = cellType.getCellCoordinator()
            registerTableViewToRespectiveCellType(cellType: cellType, tableView: tableView)
            cachedFeedCellCoordinators[cellType.cellIdentifier] = coordinator
            return coordinator
        }
    }
    
    func registerTableViewToRespectiveCellType(cellType: FeedCellTypeProtocol, tableView: UITableView?) {
        print("<<<<<<<<<<<<<<<< registering tableview for \(cellType.cellIdentifier), \(cellType.cellNib)")
        tableView?.register(
            cellType.cellNib,
            forCellReuseIdentifier: cellType.cellIdentifier
        )
    }
    
}
