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
            cell.selectedOrgDepartmentLbl?.text = "My organisation".localized
        case .MyDepartment:
            cell.selectedOrgDepartmentLbl?.text = "My department".localized
        case .JobFamilies:
            cell.selectedOrgDepartmentLbl?.text = "My Job Families".localized
        case .MultiOrg:
            let displayable = datasource.getPostSharedWithOrgAndDepartment()!.displayables()[targetIndexpath.row]
            if displayable.contains("jobfamily") {
                let jobFamilyData = displayable.replacingOccurrences(of: "jobfamily", with: "")
                cell.selectedOrgDepartmentLbl?.text = jobFamilyData
                cell.selectedOrgDepartmentLbl?.textColor = UIColor(red: 52/255, green: 170/255, blue: 220/255, alpha: 1.0)
                cell.bubble?.backgroundColor = UIColor(red: 52/255, green: 170/255, blue: 220/255, alpha: 0.1)
            }else {
                cell.selectedOrgDepartmentLbl?.text = displayable
                cell.selectedOrgDepartmentLbl?.textColor = .getControlColor()
                cell.bubble?.backgroundColor = .grayBackGroundColor()
            }
        }
        
        cell.selectedOrgDepartmentLbl?.backgroundColor = .clear
        cell.selectedOrgDepartmentLbl?.font = .Caption3
        
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
