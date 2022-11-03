//
//  PostPreviewSectionFactory.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 29/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents

struct PostPreviewSectionFactoryInitModel{
    weak var feedDataSource : FeedsDatasource?
    weak var themeManager: CFFThemeManagerProtocol?
    weak var targetTableView : UITableView?
    var mediaFetcher: CFFMediaCoordinatorProtocol!
}

class PostPreviewSectionFactory {
    private var cachedCellCoordinators: [String : FeedCellCoordinatorProtocol]!    
    private var rowsForDetails : [FeedCellTypeProtocol]!
    private let initModel : PostPreviewSectionFactoryInitModel
    
    init(_ initModel : PostPreviewSectionFactoryInitModel){
        self.initModel = initModel
        cachedCellCoordinators = [
            FeedTopTableViewCellType().cellIdentifier : FeedTopTableViewCellCoordinator(),
            FeedTitleTableViewCellType().cellIdentifier : FeedTitleTableViewCellCoordinator(),
            FeedTextTableViewCellType().cellIdentifier : FeedTextTableViewCellCoordinator(),
            SingleImageTableViewCellType().cellIdentifier : SingleImageTableViewCellCoordinator(),
            SingleVideoTableViewCellType().cellIdentifier : SingleVideoTableViewCellCoordinator(),
            MultipleMediaTableViewCellType().cellIdentifier : MultipleMediaTableViewCellCoordinator(),
            FeedGifTableViewCellType().cellIdentifier : FeedAttachedGifTableViewCellCoordinator(),
            PollOptionsTableViewCellType().cellIdentifier : PollOptionsTableViewCellCoordinator(),
            PollSubmitButtonCellType().cellIdentifier : PollSubmitButtonCellCoordinator(),
            PollBottomTableViewCelType().cellIdentifier : PollBottomTableViewCellCoordinator()
        ]
    }
    
    func cleanup(){
        cachedCellCoordinators = nil
    }
    
    func setupTableView(_ targetTable : UITableView?){
        cachedCellCoordinators.forEach { (cellCoordinator) in
            targetTable?.register(
                cellCoordinator.value.cellType.cellNib,
                forCellReuseIdentifier: cellCoordinator.value.cellType.cellIdentifier
            )
        }
    }
    
    func getNumberOfRowsFor(section : PostPreviewSection, post : FeedsItemProtocol) -> Int{
        switch section {
        case .PostInfo:
            return getRowsToRepresentFeedDetail(feed: post).count
        case .ShareWithInfoSection:
            return 0
        }
    }
    
    func getCellCoordinator(_ indexpath : IndexPath) -> FeedCellCoordinatorProtocol {
        var cellType : FeedCellTypeProtocol!
        switch PostPreviewSection(rawValue: indexpath.section)!{
        case .PostInfo:
            cellType =  getRowsToRepresentFeedDetail(feed: initModel.feedDataSource!.getFeedItem())[indexpath.row]
        case .ShareWithInfoSection:
            cellType =  getRowsToRepresentFeedDetail(feed: initModel.feedDataSource!.getFeedItem())[indexpath.row]
        }
        return cachedCellCoordinators[cellType.cellIdentifier]!
    }
    
    func getCell(tableView : UITableView, indexpath : IndexPath, post : FeedsItemProtocol) -> UITableViewCell{
        let cell = getCellCoordinator(indexpath).getCell(FeedCellDequeueModel(
            targetIndexpath: indexpath,
            targetTableView: tableView,
            datasource: initModel.feedDataSource!,
            isFeedDetailPage: true,
            themeManager: initModel.themeManager
            )
        )
        cell.backgroundColor = .clear
        if let containerdCell = cell as? FeedsCustomCellProtcol{
            containerdCell.containerView?.backgroundColor = .white
        }
        return cell
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath)  {
        getCellCoordinator(indexPath).loadDataCell(
            FeedCellLoadDataModel(
                targetIndexpath: indexPath,
                targetTableView: initModel.targetTableView,
                targetCell: cell,
                datasource: initModel.feedDataSource!,
                mediaFetcher: initModel.mediaFetcher,
                delegate: nil,
                selectedoptionMapper: nil,
                themeManager: initModel.themeManager,
                isFeedDetailPage: true
            )
        )
    }
    
    func getHeightOfCell(indexPath: IndexPath) -> CGFloat {
        return getCellCoordinator(indexPath).getHeight(
            FeedCellGetHeightModel(
                targetIndexpath: indexPath,
                datasource: initModel.feedDataSource!
            )
        )
    }
}

extension PostPreviewSectionFactory{
    private func getRowsToRepresentFeedDetail(feed: FeedsItemProtocol) ->  [FeedCellTypeProtocol] {
        if rowsForDetails == nil{
            var rows = [FeedCellTypeProtocol] ()
            rows.append(FeedTopTableViewCellType())
            if feed.getFeedTitle() != nil {
                rows.append(FeedTitleTableViewCellType())
            }
            let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(
                feedId: feed.feedIdentifier,
                description: feed.getFeedDescription()
            )
            if model?.displayableDescription.string != nil{
                if let disaplyableDescription = model?.displayableDescription.string.trimmingCharacters(in: .whitespaces),
                   !disaplyableDescription.isEmpty{
                    rows.append(FeedTextTableViewCellType())
                }
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
                case .Document:
                    debugPrint("documents not supported")
                }
            case .TwoMediaItemPresent:
                fallthrough
            case .MoreThanTwoMediItemPresent:
                rows.append(MultipleMediaTableViewCellType())
            }
            
            if model?.attachedGif != nil{
                rows.append(FeedGifTableViewCellType())
            }
            
            
            if let poll = feed.getPoll(){
                if poll.isPollActive() && !poll.hasUserVoted(){
                    poll.getPollOptions().forEach { (_) in
                        rows.append(PollOptionsTableViewCellType())
                    }
                    rows.append(PollSubmitButtonCellType())
                }else{
                    poll.getPollOptions().forEach { (_) in
                        rows.append(PollOptionsVotedTableViewCellType())
                    }
                    
                }
                
                rows.append(PollBottomTableViewCelType())
            }
            rowsForDetails = rows
        }
        
        return rowsForDetails
    }
}

