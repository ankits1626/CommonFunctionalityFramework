//
//  FeedDetailSectionFactory.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

enum FeedDetailCellType : Int {
    case Profile = 0
    case Title
    case Description
    case Media
    case ClappByUsers
    case Comments
}


class FeedDetailSectionFactory {
    let feedDataSource : FeedsDatasource
    private var mediaFetcher: CFFMediaCoordinatorProtocol!
    private weak var targetTableView : UITableView?
    lazy var cachedCellCoordinators: [String : FeedCellCoordinatorProtocol] = {
        return [
            FeedTopTableViewCellType().cellIdentifier : FeedTopTableViewCellCoordinator(),
            FeedTitleTableViewCellType().cellIdentifier : FeedTitleTableViewCellCoordinator(),
            FeedTextTableViewCellType().cellIdentifier : FeedTextTableViewCellCoordinator(),
            SingleImageTableViewCellType().cellIdentifier : SingleImageTableViewCellCoordinator(),
            SingleVideoTableViewCellType().cellIdentifier : SingleVideoTableViewCellCoordinator(),
            MultipleMediaTableViewCellType().cellIdentifier : MultipleMediaTableViewCellCoordinator(),
            PollOptionsTableViewCellType().cellIdentifier : PollOptionsTableViewCellCoordinator(),
            ClappedByTableViewCellType().cellIdentifier : ClappedByTableViewCellCoordinator(),
            FeedBottomTableViewCellType().cellIdentifier : FeedBottomTableViewCellCoordinator(),
            FeedCommentTableViewCellType().cellIdentifier : FeedCommentTableViewCellCoordinator()
        ]
    }()
    
    
    init(_ feedDataSource : FeedsDatasource, mediaFetcher: CFFMediaCoordinatorProtocol!, targetTableView : UITableView?) {
        self.feedDataSource = feedDataSource
        self.mediaFetcher = mediaFetcher
        self.targetTableView = targetTableView
        registerTableViewForAllPossibleCellTypes(targetTableView)
    }
    
    internal func registerTableViewForAllPossibleCellTypes(_ tableView : UITableView? ){
        cachedCellCoordinators.forEach { (cellCoordinator) in
            tableView?.register(
                cellCoordinator.value.cellType.cellNib,
                forCellReuseIdentifier: cellCoordinator.value.cellType.cellIdentifier
            )
        }
    }
        
    func getNumberOfSectionsForFeedDetailView() -> Int {
        return getAvailablefeedSections().count
    }
    
    func numberOfRowsInSection(_ section : Int) -> Int {
        let cellMap = getRowsToRepresentFeedDetail()
        switch getAvailablefeedSections()[section] {
        case .FeedInfo:
            return cellMap[FeedDetailSection.FeedInfo]?.count ?? 0
        case .ClapsSection:
            return feedDataSource.getClappedByUsers()?.count ?? 0
        case .Comments:
            return feedDataSource.getComments()?.count ?? 0
        }
    }
    
    func getCellCoordinator(_ indexpath : IndexPath) -> FeedCellCoordinatorProtocol {
        let cellMap = getRowsToRepresentFeedDetail()
        switch getAvailablefeedSections()[indexpath.section] {
        case .FeedInfo:
            let feedInfo = cellMap[.FeedInfo]
            let cellType =  feedInfo?[indexpath.row]
            return cachedCellCoordinators[cellType!.cellIdentifier]!
            //return cellMap[FeedDetailSection.FeedInfo]?.count ?? 0
        case .ClapsSection:
            return cachedCellCoordinators[ClappedByTableViewCellType().cellIdentifier]!
        case .Comments:
            return cachedCellCoordinators[FeedCommentTableViewCellType().cellIdentifier]!
        }
    }
    
    func getCell(indexPath : IndexPath, tableView: UITableView) -> UITableViewCell {
        return getCellCoordinator(indexPath).getCell(FeedCellDequeueModel(
            targetIndexpath: indexPath,
            targetTableView: tableView,
            datasource: feedDataSource
            )
        )
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath, delegate: FeedsDelegate)  {
        getCellCoordinator(indexPath).loadDataCell(
            FeedCellLoadDataModel(
                targetIndexpath: indexPath,
                targetCell: cell,
                datasource: feedDataSource,
                mediaFetcher: mediaFetcher,
                delegate: delegate
        )
        )
    }
    
    func getHeightOfCell(indexPath: IndexPath) -> CGFloat {
        return getCellCoordinator(indexPath).getHeight(
            FeedCellGetHeightModel(
                targetIndexpath: indexPath,
                datasource: feedDataSource
            )
        )
    }
    
}

extension FeedDetailSectionFactory{
    private func getAvailablefeedSections() -> [FeedDetailSection]{
        var sections = [FeedDetailSection.FeedInfo]
        if let clappedByUsers = feedDataSource.getClappedByUsers(),
        !clappedByUsers.isEmpty{
             sections.append(FeedDetailSection.ClapsSection)
        }
        if let comments = feedDataSource.getComments(),
        !comments.isEmpty{
            sections.append(FeedDetailSection.Comments)
        }
        return sections
    }
    
    func getRowsToRepresentFeedDetail() -> [FeedDetailSection :  [FeedCellTypeProtocol]] {
        let feed = feedDataSource.getFeedItem()
        var map = [FeedDetailSection :  [FeedCellTypeProtocol]]()
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
        feed.getPollOptions()?.forEach { (_) in
            rows.append(PollOptionsTableViewCellType())
        }
        map[.FeedInfo] = rows
        if feedDataSource.getFeedItem().getFeedDescription() != nil{
            
            //profileCellTypeMap.append(.Description)
        }
        if feedDataSource.getFeedItem().getMediaList() != nil{
            //profileCellTypeMap.append(.Media)
        }
        
        return map
    }
    
}
