//
//  FeedTitleTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
//import TTTAttributedLabel

class FeedTitleTableViewCellCoordinator: NSObject, FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return FeedTitleTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        let targetCell = inputModel.targetTableView.dequeueReusableCell(
        withIdentifier: cellType.cellIdentifier,
        for: inputModel.targetIndexpath)
        if let cell  = targetCell as? FeedTitleTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.feedTitle?.enabledTypes  = [.url]
            let attributes : [NSAttributedString.Key: Any] = [
                .font : UIFont.Title1,
                .foregroundColor : UIColor.getTitleTextColor()
            ]
            if let title = feed.getFeedTitle(){
                cell.feedTitle?.attributedText = NSAttributedString(
                    string: title,
                    attributes: attributes
                )
            }else{
                cell.feedTitle?.attributedText = nil
            }
            cell.feedTitle?.URLColor = .urlColor
            cell.feedTitle?.handleURLTap({ (targetUrl) in
                print("<<<<<<<< open \(targetUrl)")
                if !targetUrl.absoluteString.hasPrefix("http"),
                    let modifiedUrl = URL(string: "http://\(targetUrl.absoluteString)"){
                    UIApplication.shared.open(
                        modifiedUrl,
                        options: [:],
                        completionHandler: nil
                    )
                }else{
                    UIApplication.shared.open(
                        targetUrl,
                        options: [:],
                        completionHandler: nil
                    )
                }
            })
            cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
        }
        return targetCell
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedTitleTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.feedTitle?.text = feed.getFeedTitle()
            cell.feedTitle?.font = UIFont.Title1
            cell.feedTitle?.textColor = UIColor.getTitleTextColor()
            cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
        }
    }
    
}

//extension FeedTitleTableViewCellCoordinator : TTTAttributedLabelDelegate{
//    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
//        UIApplication.shared.open(
//            url,
//            options: [:],
//            completionHandler: nil
//        )
//    }
//}
