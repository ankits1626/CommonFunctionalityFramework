//
//  NominationFeedContentCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 03/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class NominationFeedContentCoordinator  : CommonFeedContentCoordinatorProtocol{
        
    var feedsDataSource: CommonFeedsDatasource!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    private weak var targetTableView : UITableView?
    private weak var themeManager: CFFThemeManagerProtocol?
    var selectedTab = ""
    lazy var cachedFeedCellCoordinators: [String : CommonFeedCellCoordinatorProtocol] = {
        return [
            CommonFeedsTopTableViewCellType().cellIdentifier : CommonFeedTopTableViewCellCoordinator(),
            CommonAppreciationSubjectTableViewCellType().cellIdentifier : CommonAppreciationSubjectTableViewCellCoordinator(),
            CommonFeedDescriptionTableViewCellType().cellIdentifier : CommonFeedDescriptionTableViewCellCoordinator(),
            CommonLikesSectionTableViewCellType().cellIdentifier : LikesSectionTableViewCellCoordinator(),
            ImageViewTableViewCellType().cellIdentifier : ImageViewSectionTableViewCellCoordinator(),
            CommonPressLikeButtonTableViewCellType().cellIdentifier : CommonLikesTableViewCellCoordinator(),
            CommonOutastandingImageTableViewCellType().cellIdentifier : OutsandingImageTableViewCellCoordinator(),
            BOUSFeedGrayDividerCellType().cellIdentifier :
                BOUSGrayDividerCoordinator(),
            BOUSSingleImageTableViewCellType().cellIdentifier : BOUSSingleImageTableViewCellCoordinator(),
            BOUSMultipleImageTableViewCellType().cellIdentifier : BOUSMultipleImageTableViewCellCoordinator(),
            BOUSTwoImageTableViewCellType().cellIdentifier : BOUSTwoImageTableViewCellCoordinator(),
            BOUSThreeImagesTableViewCellType().cellIdentifier : BOUSThreeImagesTableViewCellCoordinator()
        ]
    }()

    init(feedsDatasource : CommonFeedsDatasource, mediaFetcher: CFFMediaCoordinatorProtocol!, tableview : UITableView?, themeManager: CFFThemeManagerProtocol?, selectedTab: String) {
        self.feedsDataSource = feedsDatasource
        self.mediaFetcher = mediaFetcher
        self.targetTableView = tableview
        self.themeManager = themeManager
        registerTableViewForAllPossibleCellTypes(tableview)
        self.selectedTab = selectedTab
    }
    
    internal func registerTableViewForAllPossibleCellTypes(_ tableView : UITableView? ){
        cachedFeedCellCoordinators.forEach { (cellCoordinator) in
            self.registerTableViewToRespectiveCellType(cellType: cellCoordinator.value.cellType, tableView: tableView)
        }
    }
    
    
    func getRowsToRepresentAFeed(feedIndex : Int) -> [CommonFeedCellTypeProtocol] {
        let feed = feedsDataSource.getFeedItem(feedIndex)
        var rows = [CommonFeedCellTypeProtocol] ()
        
        print(feed.getPostType())
        
        if feed.getPostType() == .Nomination {
            rows.append(CommonFeedsTopTableViewCellType())
            rows.append(CommonOutastandingImageTableViewCellType())
            //rows.append(CommonLikesSectionTableViewCellType())
            rows.append(CommonPressLikeButtonTableViewCellType())
            rows.append(BOUSFeedGrayDividerCellType())
        }else {
            rows.append(CommonFeedsTopTableViewCellType())
            rows.append(CommonAppreciationSubjectTableViewCellType())
           // rows.append(ImageViewTableViewCellType())
            switch feed.getMediaCountState() {
            case .None:
                break
            case .OneMediaItemPresent(let mediaType):
                switch mediaType {
                case .Image:
                    rows.append(BOUSSingleImageTableViewCellType())
                case .Video:
                    rows.append(BOUSSingleImageTableViewCellType())
                }
            case .TwoMediaItemPresent:
                rows.append(BOUSTwoImageTableViewCellType())
            case .MoreThanTwoMediItemPresent:
                rows.append(BOUSThreeImagesTableViewCellType())
                //rows.append(BOUSMultipleImageTableViewCellType())
            }
            
            if let gif = feed.getGiphy() {
                if !gif.isEmpty {
                    rows.append(BOUSSingleImageTableViewCellType())
                }
            }
            
            //rows.append(CommonLikesSectionTableViewCellType())
            rows.append(CommonPressLikeButtonTableViewCellType())
            rows.append(BOUSFeedGrayDividerCellType())
        }
        
       
//        if feedIndex == 0 {
//            rows.append(CommonFeedsTopTableViewCellType())
//            rows.append(CommonAppreciationSubjectTableViewCellType())
//           // rows.append(ImageViewTableViewCellType())
//            rows.append(CommonLikesSectionTableViewCellType())
//            rows.append(CommonPressLikeButtonTableViewCellType())
//        }else if feedIndex == 1 {
//            rows.append(CommonFeedsTopTableViewCellType())
//            rows.append(CommonOutastandingImageTableViewCellType())
//
//        }else {
//            rows.append(CommonFeedsTopTableViewCellType())
//            rows.append(CommonAppreciationSubjectTableViewCellType())
//           // rows.append(ImageViewTableViewCellType())
//            rows.append(CommonLikesSectionTableViewCellType())
//            //rows.append(CommonPressLikeButtonTableViewCellType())
//        }
//        rows.append(CommonFeedsTopTableViewCellType())
//        rows.append(CommonAppreciationSubjectTableViewCellType())
//        //rows.append(ImageViewTableViewCellType())
//        rows.append(CommonLikesSectionTableViewCellType())
//        rows.append(CommonPressLikeButtonTableViewCellType())
        //rows.append(CommonOutastandingImageTableViewCellType())
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
                isFeedDetailPage: false, selectedTab: selectedTab
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


