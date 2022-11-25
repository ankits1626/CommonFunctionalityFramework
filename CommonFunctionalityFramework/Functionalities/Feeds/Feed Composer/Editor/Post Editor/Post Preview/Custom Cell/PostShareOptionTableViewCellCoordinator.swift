//
//  PostShareOptionTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 03/11/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class PostShareOptionTableViewCellCoordinator:  FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return PostShareOptionTableCellType()
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        let targetCell = inputModel.targetTableView.dequeueReusableCell(
        withIdentifier: cellType.cellIdentifier,
        for: inputModel.targetIndexpath)
        if let cell  = targetCell as? PostShareOptionTableViewCell{
            setupShareOptionCell(
                inputModel.datasource,
                cell,
                targetIndexpath: inputModel.targetIndexpath
            )
        }
        return targetCell
    }
    
    
    fileprivate func setupShareOptionCell(_ datasource: FeedsDatasource, _ cell: PostShareOptionTableViewCell, targetIndexpath: IndexPath) {
        switch datasource.getPostShareOption(){
            
        case .MyOrg:
            cell.selectedOrgDepartmentLbl?.text = "My organisation"
        case .MyDepartment:
            cell.selectedOrgDepartmentLbl?.text = "My department"
        case .MultiOrg:
            let displayable = datasource.getPostSharedWithOrgAndDepartment()!.displayables()[targetIndexpath.row]
            cell.selectedOrgDepartmentLbl?.text = displayable
        }
        
        cell.selectedOrgDepartmentLbl?.backgroundColor = .clear
        cell.selectedOrgDepartmentLbl?.font = .Caption3
        cell.selectedOrgDepartmentLbl?.textColor = .getControlColor()
        
        cell.bubble?.backgroundColor = .white
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? PostShareOptionTableViewCell,
           let datasource = inputModel.datasource{
            setupShareOptionCell(
                datasource,
                cell,
                targetIndexpath: inputModel.targetIndexpath
            )
            cell.bubble?.curvedCornerControl()
        }
    }
}
