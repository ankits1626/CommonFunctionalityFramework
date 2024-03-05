//
//  NominationAttachmentCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 31/01/24.
//  Copyright © 2024 Rewardz. All rights reserved.
//

import UIKit

class NominationAttachmentCellCoordinator :  FeedCellCoordinatorProtocol{
    let serverUrl = UserDefaults.standard.value(forKey: "base_url_for_image_height") as? String ?? ""
    var cellType: FeedCellTypeProtocol{
        return NominationAttachmentTableViewCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
        if  let feedNominationData = feed.getUserEnteredAnsers()?[inputModel.targetIndexpath.row - 2] {
            if !feedNominationData.supportingDoc.isEmpty {
                return 180
            }
        }
        return 48
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? NominationQuestionTableViewCell{
            cell.noDatalabel?.text = "No document attached".localized
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            if  let feedNominationData = feed.getUserEnteredAnsers()?[inputModel.targetIndexpath.row - 2] {
                if !feedNominationData.supportingDoc.isEmpty {
                    cell.noDatalabel?.isHidden = true
                    inputModel.mediaFetcher.fetchImageAndLoad(cell.attachmentImage, imageEndPoint: URL(string: serverUrl+feedNominationData.supportingDoc))
                }else {
                    cell.noDatalabel?.isHidden = false
                    cell.attachmentImage?.image = nil
                }
                
                if feed.getQuestionLabel()[inputModel.targetIndexpath.row - 2].count > 0 {
                    cell.attachmentName?.text = feed.getQuestionLabel()[inputModel.targetIndexpath.row - 2]
                }
            }
        }
    }
}
