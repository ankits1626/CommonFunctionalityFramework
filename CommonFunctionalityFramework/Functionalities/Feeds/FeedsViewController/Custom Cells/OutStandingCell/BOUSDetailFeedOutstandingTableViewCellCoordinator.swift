//
//  BOUSDetailFeedOutstandingTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSDetailFeedOutstandingTableViewCellCoordinator :  FeedCellCoordinatorProtocol{
    
    let serverUrl = UserDefaults.standard.value(forKey: "base_url_for_image_height") as? String ?? ""

    var cellType: FeedCellTypeProtocol{
        return FeedDetailOutstandingTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }

    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? BOUSDetailFeedOutstandingTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            
            let feedNominationData = feed.getStrengthData()
            let bagesData = feed.getBadgesData()
            cell.strengthLabel?.text = feedNominationData["strengthName"] as? String ?? ""
            cell.strengthHeightConstraints?.constant = cell.strengthLabel?.text?.isEmpty ?? true ? -20 : 20
            cell.strength1HeightConstraints?.constant = cell.strengthLabel?.text?.isEmpty ?? true ? -20 : 20
            if let unwrappedText = feed.getNominationDescription(){
                let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(feedId: feed.feedIdentifier, description: unwrappedText)
                ASMentionCoordinator.shared.getPresentableMentionText(model?.displayableDescription.string, completion: { (attr) in
                    cell.nominationMessage?.text = nil
                    cell.nominationMessage?.attributedText = attr
                })
            }else{
                cell.nominationMessage?.text = feedNominationData["strengthMessage"] as? String ?? ""
            }
            cell.awardLabel?.text = bagesData["badgeName"] as! String
            cell.nominationImageView?.backgroundColor =  Rgbconverter.HexToColor(bagesData["badgeBackgroundColor"] as! String, alpha: 1)
            cell.imageContainer?.backgroundColor = Rgbconverter.HexToColor(bagesData["badgeBackgroundColor"] as! String, alpha: 1)
            cell.nominationConatiner?.backgroundColor = Rgbconverter.HexToColor(bagesData["badgeBackgroundColor"] as! String, alpha: 0.2)
            inputModel.mediaFetcher.fetchImageAndLoad(cell.badgeImageView, imageEndPoint:  bagesData["badgeIcon"] as! String)
            
            let strengthIcon = feedNominationData["strengthIcon"] as? String ?? ""
            if !strengthIcon.isEmpty {
                inputModel.mediaFetcher.fetchImageAndLoad(cell.strengthIcon, imageEndPoint: URL(string: serverUrl+strengthIcon))
            }else {
                cell.strengthIcon?.image = UIImage(named: "")
            }
            
            if !strengthIcon.isEmpty {
                inputModel.mediaFetcher.fetchImageAndLoad(cell.categoryImageView, imageEndPoint: URL(string: serverUrl+strengthIcon))
            }else {
                cell.categoryImageView?.image = UIImage(named: "PlaceHolderImage")
            }
            cell.teamLabel?.text = "As a Group".localized
            cell.categoryName?.text = feed.getCategoryName()?.name
            cell.badgeName?.text = bagesData["badgeName"] as? String ?? ""
            cell.badgePoints?.text = "\(bagesData["points"] as? String ?? "") \("Points".localized)"
            
            if let unwrappedGroupData = feed.getCategoryName(),
               unwrappedGroupData.isGroupEnabled {
                cell.teamView?.isHidden = false
                cell.teamViewHeightConstraints?.constant = 17
            }else {
                cell.teamView?.isHidden = true
                cell.teamViewHeightConstraints?.constant = 0
            }
            
            if let unwrappedCategoryImg =  feed.getCategoryName(),
               !unwrappedCategoryImg.image.isEmpty{
                inputModel.mediaFetcher.fetchImageAndLoad(cell.categoryImageView, imageEndPoint: URL(string: serverUrl+unwrappedCategoryImg.image))
            }else {
                cell.categoryImageView?.image = UIImage(named: "PlaceHolderImage")
            }
            
            cell.groupNominationAction?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {
                inputModel.delegate?.showTeamInfo()
            })
        }
    }
}
