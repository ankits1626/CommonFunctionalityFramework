//
//  PollsActiveDaysTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 29/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollsActiveDaysTableViewCellCoordinator: NSObject, PostEditorCellCoordinatorProtocol {
    var cellType: FeedCellTypeProtocol = PollsActiveDaysTableViewCellType()
    
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        if let cell = inputModel.targetCell as? PollsActiveDaysTableViewCell{
            cell.activeDaysLabel?.font = .Highlighter2
            cell.activeDaysLabel?.text = "Poll Active for (days) :"
            cell.activeDaysStepper?.reading = 1
            cell.activeDaysStepper?.indicatorColor = .stepperIndicatorColor()
            cell.activeDaysStepper?.curvedBorderedControl()
            cell.containerView?.addBorders(edges: [.bottom, .left, .right], color: UIColor.getGeneralBorderColor())
        }
    }
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return 118
    }
    
    weak var delegate : PostEditorCellFactoryDelegate?
    
}

extension PollsActiveDaysTableViewCellCoordinator : StepperDelegate{
    func stepperDidChanged(sender: Stepper) {
        delegate?.activeDaysForPollChanged(sender.reading)
    }
}
