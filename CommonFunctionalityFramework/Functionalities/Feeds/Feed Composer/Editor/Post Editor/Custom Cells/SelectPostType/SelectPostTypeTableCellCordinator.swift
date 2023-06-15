//
//  SelectPostTypeTableCellCordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 12/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Loaf

class SelectPostTypeTableCellCordinator: NSObject, PostEditorCellCoordinatorProtocol {
    var cellType: FeedCellTypeProtocol = SelectPostTypeTableViewCellType()
    weak var themeManager : CFFThemeManagerProtocol?
    weak var mainAppCoordinator : CFFMainAppInformationCoordinator?
    
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        themeManager = inputModel.themeManager
        mainAppCoordinator = inputModel.mainAppCoordinator
        if let cell = inputModel.targetCell as? SelectPostTypeTableViewCell{
            cell.posttoDepartment?.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
            if self.mainAppCoordinator?.isMultiOrgPostEnabled() == true {
                cell.containerView?.isHidden = true
            }
        }
    }
    
    @objc func switchValueDidChange(_ sender: UISwitch) {
        self.delegate?.createdPostType(sender.isOn)
        print(sender.isOn)
    }
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return 76
    }
    
    weak var delegate : PostEditorCellFactoryDelegate?
    
}
