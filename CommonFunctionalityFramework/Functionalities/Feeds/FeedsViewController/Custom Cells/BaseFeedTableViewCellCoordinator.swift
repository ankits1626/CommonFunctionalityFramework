//
//  CommonCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class BaseFeedTableViewCellCoordinator: CommonCellCoordinatorProtocol {
    func getCell(_ inputModel: CommonCellCoordinatorCellDequeueInputModel) -> CommonCollectionCellProtocol {
        return inputModel.collectionType.dequeueCell(
            identifier: inputModel.cellType.cellTypeIdentifier,
            indexpath: inputModel.indexpath
        )
    }
    
    func configureCell(_ inputModel: CommonCellCoordinatorCellConfigurationInputModel) throws {
        if let cell = inputModel.cell as? BaseFeedTableViewCell,
            let feedItem : FeedsItemProtocol = inputModel.datasource.getItem(indexpath: inputModel.indexpath){
            cell.userName?.text = feedItem.getUserName()
            cell.departmentName?.text = feedItem.getDepartmentName()
            cell.dateLabel?.text = feedItem.getfeedCreationDate()
        }
    }
    
    func getSizeOfCell(_ inputModel: CommonCellCoordinatorBaseInputModel) -> CGSize {
        return CGSize.zero
    }
    
    
}
