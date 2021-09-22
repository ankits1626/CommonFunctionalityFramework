//
//  PollSubmitButtonCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollSubmitButtonCellCoordinator:  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return PollSubmitButtonCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return 44
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? PollSubmitButtonCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.containerView?.backgroundColor = UIColor.optionContainerBackGroundColor
            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
                cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
            }else{
                cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            }
            cell.submitButton?.backgroundColor = inputModel.themeManager?.getControlActiveColor() ?? .black
            cell.submitButton?.setTitle("SUBMIT".localized, for: .normal)
            cell.submitButton?.setTitleColor(.white, for: .normal)
            cell.submitButton?.titleLabel?.font = .Highlighter1
            let delegate = inputModel.delegate
            let feedIdentifier = feed.feedIdentifier
            cell.submitButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {[weak delegate] in
                    delegate?.submitPollAnswer(feedIdentifier: feedIdentifier)
            })
        }
    }
    
}
