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
            if let mediaItem = feed.getMediaList()?.first,
               let _ = mediaItem.getCoverImageUrl(){
                addFeedViewCornerRadius(cell: cell, feed: feed)
            }else if let gifItem = feed.getGiphy() {
                if !gifItem.isEmpty {
                    addFeedViewCornerRadius(cell: cell, feed: feed)
                }
            }else {
                cell.containerView?.layer.masksToBounds = true
                cell.containerView?.layer.cornerRadius = 8
            }
            addFeedViewCornerRadius(cell: cell, feed: feed)
            let feedTitle = feed.getStrengthData()
            if let unwrappedText = feedTitle["strengthMessage"] as? String{
                let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(feedId: feed.feedIdentifier, description: unwrappedText)
                ASMentionCoordinator.shared.getPresentableMentionText(model?.displayableDescription.string, completion: { (attr) in
                    cell.feedText?.text = nil
                    cell.feedText?.attributedText = attr
                })
            }else{
                cell.feedText?.text = feedTitle["strengthMessage"] as? String ?? ""
            }
            cell.appreciationSubject?.text =  feedTitle["strengthName"] as? String ?? ""
            let backGroundColor = feedTitle["badgeBackgroundColor"] as? String ?? ""
            let backGroundColorLite = feedTitle["background_color_lite"] as? String ?? ""
            if let bgColor = UIColor(hex: backGroundColorLite) {
                cell.containerView?.backgroundColor = bgColor
            }else{
                cell.containerView?.backgroundColor = Rgbconverter.HexToColor(backGroundColorLite)
            }
        }
        return targetCell
    }
    
    func addFeedViewCornerRadius(cell : FeedTitleTableViewCell, feed : FeedsItemProtocol) {
        let seconds = 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            cell.containerView?.clipsToBounds = true
            cell.containerView?.layer.masksToBounds = true
            let path = UIBezierPath(roundedRect: cell.containerView!.bounds, byRoundingCorners:[.topLeft, .topRight], cornerRadii: CGSizeMake(08, 08))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            cell.containerView?.layer.mask = maskLayer
        }
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedTitleTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            let feedTitle = feed.getStrengthData()
            if let unwrappedText = feedTitle["strengthMessage"] as? String{
                let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(feedId: feed.feedIdentifier, description: unwrappedText)
                ASMentionCoordinator.shared.getPresentableMentionText(model?.displayableDescription.string, completion: { (attr) in
                    cell.feedText?.text = nil
                    cell.feedText?.attributedText = attr
                })
            }else{
                cell.feedText?.text = feedTitle["strengthMessage"] as? String ?? ""
            }
            cell.appreciationSubject?.text =  feedTitle["strengthName"] as? String ?? ""
            cell.pointBtn.setTitle("\(feedTitle["points"] as? String ?? "") \("Points".localized)", for: .normal)
            cell.pointBtn.alpha = feedTitle["points"] as? String ?? "0" > "0" ? 1 : 0
            cell.pointBtnHeightConstraints?.constant = feedTitle["points"] as? String ?? "0" > "0" ? 50 : 20
            inputModel.mediaFetcher.fetchImageAndLoad(cell.feedThumbnail, imageEndPoint: feedTitle["illustration"] as? String ?? "")
            let backGroundColor = feedTitle["badgeBackgroundColor"] as? String ?? ""
            let backGroundColorLite = feedTitle["background_color_lite"] as? String ?? ""
            if let bgColor = UIColor(hex: backGroundColorLite) {
                cell.containerView?.backgroundColor = bgColor
            }else{
                cell.containerView?.backgroundColor = Rgbconverter.HexToColor(backGroundColorLite)
            }
        }
    }
    
}
