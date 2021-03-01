//
//  FeedTopTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

struct FeedCellDequeueModel {
    var targetIndexpath : IndexPath
    var targetTableView : UITableView
    var datasource: FeedsDatasource
}

struct FeedCellLoadDataModel {
    var targetIndexpath : IndexPath
    var targetTableView: UITableView?
    var targetCell : UITableViewCell
    var datasource: FeedsDatasource
    var mediaFetcher: CFFMediaCoordinatorProtocol
    var delegate : FeedsDelegate?
    weak var selectedoptionMapper : SelectedPollAnswerMapper?
    weak var themeManager: CFFThemeManagerProtocol?
}

struct FeedCellGetHeightModel {
    var targetIndexpath : IndexPath
    var datasource: FeedsDatasource
}

protocol FeedCellCongiguratorProtocol {
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell
}

class FeedTopTableViewCellCoordinator: FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return FeedTopTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 80
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedTopTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.userName?.text = feed.getUserName()
            cell.userName?.font = UIFont.Body2
            cell.userName?.textColor = UIColor.getTitleTextColor()
            cell.departmentName?.text = feed.getDepartmentName()
            cell.departmentName?.font = UIFont.Caption1
            cell.departmentName?.textColor = UIColor.getSubTitleTextColor()
            cell.dateLabel?.text = feed.getfeedCreationDate()
            cell.dateLabel?.font = UIFont.Caption1
            cell.dateLabel?.textColor = UIColor.getSubTitleTextColor()
            cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: AppliedCornerRadius.standardCornerRadius)
            cell.containerView?.addBorders(edges: [.top, .left, .right], color: .feedCellBorderColor)
            cell.containerView?.clipsToBounds = true
            if !inputModel.datasource.shouldShowMenuOptionForFeed(){
                cell.editFeedButton?.isHidden = true
            }else{
                cell.editFeedButton?.isHidden = !feed.isActionsAllowed()
            }
            
            cell.editFeedButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    inputModel.delegate?.showFeedEditOptions(
                        targetView: cell.editFeedButton,
                        feedIdentifier: feed.feedIdentifier
                    )
            })
            if let profileImageEndpoint = feed.getUserImageUrl(){
                inputModel.mediaFetcher.fetchImageAndLoad(cell.profileImage, imageEndPoint: profileImageEndpoint)
            }else{
                cell.profileImage?.image = nil
            }
        }
    }
    
}
