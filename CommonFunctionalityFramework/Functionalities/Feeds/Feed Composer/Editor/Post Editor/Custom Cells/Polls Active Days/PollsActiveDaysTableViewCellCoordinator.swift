//
//  PollsActiveDaysTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 29/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import Loaf

class PollsActiveDaysTableViewCellCoordinator: NSObject, PostEditorCellCoordinatorProtocol {
    var cellType: FeedCellTypeProtocol = PollsActiveDaysTableViewCellType()
    
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        if let cell = inputModel.targetCell as? PollsActiveDaysTableViewCell{
            cell.activeDaysLabel?.font = .Highlighter2
            cell.activeDaysLabel?.text = "Poll Active for (days) :"
            cell.activeDaysStepper?.delegate = self
            cell.activeDaysStepper?.reading = 1
            cell.activeDaysStepper?.incrementIndicatorColor = .stepperActiveColor
            cell.activeDaysStepper?.decrementIndicatorColor = .stepperInactiveColor
            cell.activeDaysStepper?.middleColor = .stepperMiddleColor
            cell.activeDaysStepper?.curvedBorderedControl()
            cell.containerView?.addBorders(edges: [.bottom, .left, .right], color: .feedCellBorderColor)
        }
    }
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return 118
    }
    
    weak var delegate : PostEditorCellFactoryDelegate?
    
}

extension PollsActiveDaysTableViewCellCoordinator : StepperDelegate{
    func stepperDidChanged(sender: Stepper) {
        if let minVal = sender.minVal?.intValue{
            if sender.reading == minVal{
                sender.decrementIndicatorColor = .stepperInactiveColor
                showMessage("Poll must be active for more than \(minVal) \(minVal == 1 ? "day" : "days").")
            }else{
                sender.decrementIndicatorColor = .stepperActiveColor
            }
        }
        
        if let maxVal = sender.maxVal?.intValue{
            if sender.reading == maxVal{
                sender.incrementIndicatorColor = .stepperInactiveColor
                showMessage("Poll cannot be active for more than \(maxVal) \(maxVal == 1 ? "day" : "days").")
            }else{
                sender.incrementIndicatorColor = .stepperActiveColor
            }
        }
        
        delegate?.activeDaysForPollChanged(sender.reading)
    }
    
    private func showMessage(_ message : String){
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            Loaf(message, sender: topController).show()
        }
    }
}
