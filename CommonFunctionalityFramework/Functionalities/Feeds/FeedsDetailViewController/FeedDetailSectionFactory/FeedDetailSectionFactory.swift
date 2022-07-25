//
//  FeedDetailSectionFactory.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

//enum FeedDetailCellType : Int {
//    case Profile = 0
//    case Title
//    case Description
//    case Media
//    case ClappByUsers
//    case Comments
//}


class FeedDetailSectionFactory {
    let feedDataSource : FeedsDatasource
    private weak var feedDetailDelegate: FeedsDelegate?
    private var mediaFetcher: CFFMediaCoordinatorProtocol!
    private weak var selectedOptionMapper : SelectedPollAnswerMapper?
    private weak var targetTableView : UITableView?
    private var isLikedByCellIndexpath : IndexPath!
    private weak var themeManager: CFFThemeManagerProtocol?
    lazy var cachedCellCoordinators: [String : FeedCellCoordinatorProtocol] = {
        return [
            FeedTopTableViewCellType().cellIdentifier : FeedTopTableViewCellCoordinator(),
            FeedTitleTableViewCellType().cellIdentifier : FeedTitleTableViewCellCoordinator(),
            FeedTextTableViewCellType().cellIdentifier : FeedTextTableViewCellCoordinator(),
            SingleImageTableViewCellType().cellIdentifier : SingleImageTableViewCellCoordinator(),
            SingleVideoTableViewCellType().cellIdentifier : SingleVideoTableViewCellCoordinator(),
            MultipleMediaTableViewCellType().cellIdentifier : MultipleMediaTableViewCellCoordinator(),
            FeedGifTableViewCellType().cellIdentifier : FeedAttachedGifTableViewCellCoordinator(),
            PollOptionsTableViewCellType().cellIdentifier : PollOptionsTableViewCellCoordinator(),
            PollSubmitButtonCellType().cellIdentifier : PollSubmitButtonCellCoordinator(),
            PollOptionsVotedTableViewCellType().cellIdentifier : PollOptionsVotedTableViewCellCoordinator(),
            PollBottomTableViewCelType().cellIdentifier : PollBottomTableViewCellCoordinator(),
            ClappedByTableViewCellType().cellIdentifier : ClappedByTableViewCellCoordinator(),
            FeedBottomTableViewCellType().cellIdentifier : FeedBottomTableViewCellCoordinator(),
            FeedCommentTableViewCellType().cellIdentifier : FeedCommentTableViewCellCoordinator(),
            FeedDetailOutstandingTableViewCellType().cellIdentifier :
                BOUSDetailFeedOutstandingTableViewCellCoordinator()
        ]
    }()
    
    private lazy var headerCoordinator: FeedDetailHeaderCoordinator = {
        return FeedDetailHeaderCoordinator(dataSource: feedDataSource, delegate: feedDetailDelegate, themeManager: themeManager)
    }()
    
    
    init(_ feedDataSource : FeedsDatasource, feedDetailDelegate: FeedsDelegate, mediaFetcher: CFFMediaCoordinatorProtocol!, targetTableView : UITableView?, themeManager: CFFThemeManagerProtocol?, selectedOptionMapper : SelectedPollAnswerMapper?) {
        self.feedDataSource = feedDataSource
        self.feedDetailDelegate = feedDetailDelegate
        self.mediaFetcher = mediaFetcher
        self.targetTableView = targetTableView
        self.themeManager = themeManager
        self.selectedOptionMapper = selectedOptionMapper
        registerTableViewForAllPossibleCellTypes(targetTableView)
        registerTableViewForHeaderView(targetTableView)
    }
    
    internal func registerTableViewForAllPossibleCellTypes(_ tableView : UITableView? ){
        cachedCellCoordinators.forEach { (cellCoordinator) in
            tableView?.register(
                cellCoordinator.value.cellType.cellNib,
                forCellReuseIdentifier: cellCoordinator.value.cellType.cellIdentifier
            )
        }
    }
    
    private func registerTableViewForHeaderView(_ tableView : UITableView?){
        tableView?.register(
            UINib(nibName: "FeedDetailHeader", bundle: Bundle(for: FeedDetailHeader.self)),
            forHeaderFooterViewReuseIdentifier: "FeedDetailHeader"
        )
    }
    
    func getNumberOfSectionsForFeedDetailView() -> Int {
        return getAvailableFeedSections().count
    }
    
    func numberOfRowsInSection(_ section : Int) -> Int {
        let cellMap = getRowsToRepresentFeedDetail()
        switch getAvailableFeedSections()[section] {
        case .FeedInfo:
            return cellMap[FeedDetailSection.FeedInfo]?.count ?? 0
        case .ClapsSection:
            if let clappedUserCount = feedDataSource.getClappedByUsers()?.count,
                clappedUserCount > 0{
                return 1
            }
            return 0
        case .Comments:
            return feedDataSource.getCommentProvider()?.getNumberOfComments() ?? 0
        }
    }
    
    func getCellCoordinator(_ indexpath : IndexPath) -> FeedCellCoordinatorProtocol {
        let cellMap = getRowsToRepresentFeedDetail()
        switch getAvailableFeedSections()[indexpath.section] {
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
        let cell = getCellCoordinator(indexPath).getCell(FeedCellDequeueModel(
            targetIndexpath: indexPath,
            targetTableView: tableView,
            datasource: feedDataSource,
            isFeedDetailPage: true,
            themeManager: themeManager
            )
        )
        cell.backgroundColor = .clear
        if let containerdCell = cell as? FeedsCustomCellProtcol{
          //  containerdCell.containerView?.backgroundColor = .white
        }
        return cell
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath)  {
        getCellCoordinator(indexPath).loadDataCell(
            FeedCellLoadDataModel(
                targetIndexpath: indexPath,
                targetTableView: targetTableView,
                targetCell: cell,
                datasource: feedDataSource,
                mediaFetcher: mediaFetcher,
                delegate: feedDetailDelegate,
                selectedoptionMapper: selectedOptionMapper,
                themeManager: themeManager,
                isFeedDetailPage: true
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
    
    func getViewForHeaderInSection(section: Int, tableView: UITableView) -> UIView? {
        return headerCoordinator.getHeader(input: GetFeedDetailtableHeaderInput(
            section: FeedDetailSection(rawValue: section)!,
            table: tableView)
        )
    }
    
    func getHeightOfViewForSection(section: Int) -> CGFloat {
        return headerCoordinator.getHeight(section: FeedDetailSection(rawValue: section)!)
    }
    
    func refreshCommentsSection() {
        targetTableView?.reloadData()
        //        for (index, aSection) in getAvailablefeedSections().enumerated() {
        //            if aSection == .Comments{
        //                targetTableView?.reloadSections(IndexSet(integer: index), with: .none)
        //            }
        //        }
    }
    
    func reloadToShowLikeAndCommentCountUpdate() {
        targetTableView?.reloadRows(at: [isLikedByCellIndexpath], with: .none)
    }
    
    func reloadToCommentCountHeader() {
        if let header = targetTableView?.headerView(forSection: FeedDetailSection.Comments.rawValue) as? FeedDetailHeader{
            headerCoordinator.configureHeader(ConfigureHeaderInput(view: header, section: FeedDetailSection.Comments))
            //headerCoordinator.configureHeader(header, section: FeedDetailSection.Comments)
        }
    }
    
    func getCommentsSectionIndex() -> Int {
        return getAvailableFeedSections().firstIndex(of: .Comments)!
    }
    
}

extension FeedDetailSectionFactory{
    private func getAvailableFeedSections() -> [FeedDetailSection]{
        return [FeedDetailSection.FeedInfo,.ClapsSection,  .Comments]
    }
    
    func getRowsToRepresentFeedDetail() -> [FeedDetailSection :  [FeedCellTypeProtocol]] {
        let feed = feedDataSource.getFeedItem()
        var map = [FeedDetailSection :  [FeedCellTypeProtocol]]()
        var rows = [FeedCellTypeProtocol] ()
        rows.append(FeedTopTableViewCellType())
        //if feed!.getFeedTitle() != nil {
        
        if feed!.getPostType() == .Nomination {
            rows.append(FeedDetailOutstandingTableViewCellType())
        }else {
            rows.append(FeedTitleTableViewCellType())
        }
        //}
//        if feed!.getFeedDescription() != nil{
//            rows.append(FeedTextTableViewCellType())
//        }
//        if
//            let unwrappedFeed = feed{
//            let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(
//                feedId: unwrappedFeed.feedIdentifier,
//                description: unwrappedFeed.getFeedDescription())
//            if model?.displayableDescription.string != nil{
//                if let disaplyableDescription = model?.displayableDescription.string.trimmingCharacters(in: .whitespaces),
//                            !disaplyableDescription.isEmpty{
//                //        if feed.getFeedDescription() != nil{
//                            //rows.append(FeedTextTableViewCellType())
//                        }
//            }
//        }
        
        switch feed!.getMediaCountState() {
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
        
        if let gif = feed!.getGiphy() {
            if !gif.isEmpty {
                rows.append(SingleImageTableViewCellType())
            }
        }
        
        if
            let unwrappedFeed = feed{
            let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(
                feedId: unwrappedFeed.feedIdentifier,
                description: unwrappedFeed.getFeedDescription())
            if model?.attachedGif != nil{
                rows.append(FeedGifTableViewCellType())
            }
        }
        
//        if let poll = feed?.getPoll(){
//            if poll.isPollActive() && !poll.hasUserVoted(){
//                poll.getPollOptions().forEach { (_) in
//                    rows.append(PollOptionsTableViewCellType())
//                }
//                rows.append(PollSubmitButtonCellType())
//            }else{
//                poll.getPollOptions().forEach { (_) in
//                    rows.append(PollOptionsVotedTableViewCellType())
//                }
//
//            }
////            poll.getPollOptions().forEach { (_) in
////                rows.append(PollOptionsVotedTableViewCellType())
////            }
//            rows.append(PollBottomTableViewCelType())
//        }
        rows.append(FeedBottomTableViewCellType())
        isLikedByCellIndexpath = IndexPath(row: rows.count - 1 , section: FeedDetailSection.FeedInfo.rawValue)
        map[.FeedInfo] = rows
        return map
    }
    
}
