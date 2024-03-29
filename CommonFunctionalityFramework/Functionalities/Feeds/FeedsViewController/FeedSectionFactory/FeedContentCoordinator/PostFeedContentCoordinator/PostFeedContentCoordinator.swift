//
//  PostFeedContentCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PostFeedContentCoordinator  : FeedContentCoordinatorProtocol{
    var feedsDataSource: FeedsDatasource!
    var selectedTab = ""
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    private weak var themeManager: CFFThemeManagerProtocol?
    private weak var targetTableView : UITableView?
    private weak var mainAppCoordinator : CFFMainAppInformationCoordinator?
    lazy var cachedFeedCellCoordinators: [String : FeedCellCoordinatorProtocol] = {
        return [
            PostPollTopTableViewCellTableViewCellType().cellIdentifier : PostPollTableViewCellCordinator(),
            PostPollTitleTableViewCellType().cellIdentifier : PostPollTitleCellCordinator(),
            FeedTextTableViewCellType().cellIdentifier : FeedTextTableViewCellCoordinator(),
            SingleImageTableViewCellType().cellIdentifier : SingleImageTableViewCellCoordinator(),
            SingleVideoTableViewCellType().cellIdentifier : SingleVideoTableViewCellCoordinator(),
            MultipleMediaTableViewCellType().cellIdentifier : MultipleMediaTableViewCellCoordinator(),
            FeedGifTableViewCellType().cellIdentifier : FeedAttachedGifTableViewCellCoordinator(),
//            FeedBottomTableViewCellType().cellIdentifier : FeedBottomTableViewCellCoordinator(),
            PostPollLikeTableViewCellType().cellIdentifier : PostPollLikeTableViewCordinator(),
            BOUSTwoImageDetailTableViewCellType().cellIdentifier : BOUSTwoImageDetailCoordinator(),
            BOUSThreeImageDetailTableViewCellType().cellIdentifier : BOUSThreeImageDetailCoordinator(),
            BOUSAnniversaryTableViewCellType().cellIdentifier :
                BOUSAnniversaryBirthdayImageTableViewCellCoordinator()
//            BOUSFeedGrayDividerCellType().cellIdentifier : BOUSGrayDividerCoordinator()
        ]
    }()

    init(feedsDatasource : FeedsDatasource, mediaFetcher: CFFMediaCoordinatorProtocol!, tableview : UITableView?, themeManager: CFFThemeManagerProtocol?, selectedTab: String, mainAppCoordinator : CFFMainAppInformationCoordinator?) {
        self.feedsDataSource = feedsDatasource
        self.selectedTab = selectedTab
        self.mediaFetcher = mediaFetcher
        self.targetTableView = tableview
        self.themeManager = themeManager
        registerTableViewForAllPossibleCellTypes(tableview)
        self.mainAppCoordinator = mainAppCoordinator
    }
    
    internal func registerTableViewForAllPossibleCellTypes(_ tableView : UITableView? ){
        cachedFeedCellCoordinators.forEach { (cellCoordinator) in
            self.registerTableViewToRespectiveCellType(cellType: cellCoordinator.value.cellType, tableView: tableView)
        }
    }
    
    
    func getRowsToRepresentAFeed(feedIndex : Int) -> [FeedCellTypeProtocol] {
        let feed = feedsDataSource.getFeedItem(feedIndex)
        var rows = [FeedCellTypeProtocol] ()
        rows.append(PostPollTopTableViewCellTableViewCellType())
        
        if selectedTab == "GreetingsFeed" {
            let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(
            feedId: feed.feedIdentifier,
            description: feed.getFeedDescription())
            if let disaplyableDescription = model?.displayableDescription.string.trimmingCharacters(in: .whitespaces),
                !disaplyableDescription.isEmpty{
    //        if feed.getFeedDescription() != nil{
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
                case .Document:
                    break
                }
            case .TwoMediaItemPresent:
                rows.append(BOUSTwoImageDetailTableViewCellType())
            case .MoreThanTwoMediItemPresent:
                rows.append(BOUSThreeImageDetailTableViewCellType())
            }
            
            if let unwrappedGify = feed.getGiphy(),
                !unwrappedGify.isEmpty {
                rows.append(FeedGifTableViewCellType())
            }
        }else {
            if feed.getPostType() == .Greeting {
                rows.append(BOUSAnniversaryTableViewCellType())
            }else {
                if feed.getFeedTitle() != nil {
                    rows.append(PostPollTitleTableViewCellType())
                }
                let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(
                feedId: feed.feedIdentifier,
                description: feed.getFeedDescription())
                if let disaplyableDescription = model?.displayableDescription.string.trimmingCharacters(in: .whitespaces),
                    !disaplyableDescription.isEmpty{
        //        if feed.getFeedDescription() != nil{
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
                    case .Document:
                        break
                    }
                case .TwoMediaItemPresent:
                    rows.append(BOUSTwoImageDetailTableViewCellType())
                case .MoreThanTwoMediItemPresent:
                    rows.append(BOUSThreeImageDetailTableViewCellType())
                }
                
                if let unwrappedGify = feed.getGiphy(),
                    !unwrappedGify.isEmpty {
                    rows.append(FeedGifTableViewCellType())
                }
            }
            rows.append(PostPollLikeTableViewCellType())
        }
        return rows
    }
    
    func getCell(_ inputModel: FeedContentGetCellModel) -> UITableViewCell{
        return getCellCoordinator(indexPath: inputModel.targetIndexpath).getCell(FeedCellDequeueModel(
            targetIndexpath: inputModel.targetIndexpath,
            targetTableView: targetTableView!,
            datasource: feedsDataSource,
            isFeedDetailPage: false,
            themeManager: themeManager,
            mainAppCoordinator: mainAppCoordinator
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
                themeManager: themeManager,
                mainAppCoordinator: mainAppCoordinator, isFeedDetailPage: false, selectedTab: selectedTab
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
