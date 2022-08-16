//
//  FeedTextTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit


class FeedTextTableViewCellCoordinator : NSObject,  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return FeedTextTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        let targetCell = inputModel.targetTableView.dequeueReusableCell(
        withIdentifier: cellType.cellIdentifier,
        for: inputModel.targetIndexpath)
        if let cell  = targetCell as? FeedTextTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            if inputModel.datasource.showShowFullfeedDescription(){
                cell.feedText?.numberOfLines = 0
                cell.feedText?.lineBreakMode = NSLineBreakMode.byClipping
            }
            cell.feedText?.enabledTypes  = [.url]
            if let unwrappedText = feed.getFeedDescription(){
                let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(feedId: feed.feedIdentifier, description: unwrappedText)
                //cell.feedText?.text = model?.displayableDescription.string
                 ASMentionCoordinator.shared.getPresentableMentionText(model?.displayableDescription.string, completion: { (attr) in
                    cell.feedText?.text = nil
                    cell.feedText?.attributedText = attr
                })
            }else{
                cell.feedText?.text = feed.getFeedDescription()
            }
            //cell.feedText?.text = feed.getFeedDescription()
            cell.feedText?.URLColor = .urlColor
            cell.feedText?.font = UIFont.Body1
            
            //cell.feedText?.textColor = UIColor.getTitleTextColor()
            cell.feedText?.handleMentionTap({ (mention) in
                print("tapped on  \(mention)")
            })
            cell.feedText?.handleURLTap({ (targetUrl) in
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
            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
                //cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
            }else{
                //cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            }
            cell.readMorebutton?.titleLabel?.attributedText = NSAttributedString(string: "Read More".localized,attributes: [NSAttributedString.Key.underlineStyle : 1])
            if inputModel.datasource.showShowFullfeedDescription(){
                cell.readMorebutton?.isHidden = true
            }else{
               cell.readMorebutton?.isHidden = !(cell.feedText?.isTruncated ?? false)
                cell.readMorebutton?.setAttributedTitle(cell.readMorebutton?.titleLabel?.attributedText, for: .normal)
            }
            cell.readMorebutton?.isUserInteractionEnabled = false
        }
        return targetCell
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
    }
    
}
