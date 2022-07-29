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
            //cell.feedText?.enabledTypes  = [.url]
//            let attributes : [NSAttributedString.Key: Any] = [
//                .font : UIFont.Title1,
//                .foregroundColor : UIColor.getTitleTextColor()
//            ]
//            if let title = feed.getFeedTitle(){
//                cell.feedText?.attributedText = NSAttributedString(
//                    string: title,
//                    attributes: nil
//                )
//            }else{
//                cell.feedText?.attributedText = nil
//            }
            
            let feedTitle = feed.getStrengthData()
            cell.feedText?.text = feedTitle["strengthMessage"] as! String
            cell.appreciationSubject?.text =  feedTitle["strengthName"] as! String
            //inputModel.mediaFetcher.fetchImageAndLoad(cell.feedThumbnail, imageEndPoint: feedTitle["strengthIcon"] as! String)
            cell.containerView?.backgroundColor = Rgbconverter.HexToColor(feedTitle["badgeBackgroundColor"] as! String, alpha: 1.0)
            //cell.feedTitle?.URLColor = .urlColor
//            cell.feedTitle?.handleURLTap({ (targetUrl) in
//                print("<<<<<<<< open \(targetUrl)")
//                if !targetUrl.absoluteString.hasPrefix("http"),
//                    let modifiedUrl = URL(string: "http://\(targetUrl.absoluteString)"){
//                    UIApplication.shared.open(
//                        modifiedUrl,
//                        options: [:],
//                        completionHandler: nil
//                    )
//                }else{
//                    UIApplication.shared.open(
//                        targetUrl,
//                        options: [:],
//                        completionHandler: nil
//                    )
//                }
//            })
//            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
//                cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
//            }else{
//                cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
//            }
            
            if let mediaItem = feed.getMediaList()?.first,
                let _ = mediaItem.getCoverImageUrl(){
                cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: 8)
            }else if let gifItem = feed.getGiphy() {
                if !gifItem.isEmpty {
                    cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: 8)
                }
            }else {
                cell.containerView?.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8)
            }
        }
        return targetCell
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedTitleTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
 //           cell.feedText?.text = feed.getFeedTitle()
//            cell.feedTitle?.font = UIFont.Title1
//            cell.feedTitle?.textColor = UIColor.getTitleTextColor()
//            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
//                cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
//            }else{
//                cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
//            }
            let feedTitle = feed.getStrengthData()
            cell.feedText?.text = feedTitle["strengthMessage"] as! String
            cell.appreciationSubject?.text =  feedTitle["strengthName"] as! String
            cell.pointBtn.setTitle(feedTitle["points"] as! String, for: .normal)
            inputModel.mediaFetcher.fetchImageAndLoad(cell.feedThumbnail, imageEndPoint: feedTitle["strengthIcon"] as! String)
            cell.containerView?.backgroundColor = Rgbconverter.HexToColor(feedTitle["badgeBackgroundColor"] as! String, alpha: 1.0)
            
            if let mediaItem = feed.getMediaList()?.first,
                let _ = mediaItem.getCoverImageUrl(){
                cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: 8)
            }else if let gifItem = feed.getGiphy() {
                if !gifItem.isEmpty {
                    cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: 8)
                }
            }else {
                cell.containerView?.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8)
            }
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
