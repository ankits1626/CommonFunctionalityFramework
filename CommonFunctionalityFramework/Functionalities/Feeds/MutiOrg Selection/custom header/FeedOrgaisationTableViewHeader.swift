//
//  FeedOrgaisationTableViewHeader.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents

class FeedOrgaisationTableViewHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var headerContainer: UIView?
    @IBOutlet weak var organisationLbl: UILabel?
    @IBOutlet weak var selectionDetailLbl: UILabel?
    @IBOutlet weak var expandCollapseBtn: BlockButton?
//    @IBOutlet weak var checkBox : ASCheckBox!
    @IBOutlet weak var selectAllDepartment: BlockButton?
    @IBOutlet weak var selectAllJobFamiles : BlockButton?
    
    @IBOutlet weak var selectAllDepartmentLabel: UILabel?
    @IBOutlet weak var selectAllJobFamilesLabel : UILabel?
    
    @IBOutlet weak var selectJobFamilyContainerView : UIView?
    @IBOutlet weak var selectAllDepartmentView : UIView?
    @IBOutlet weak var selectAllStackView : UIStackView?
}
