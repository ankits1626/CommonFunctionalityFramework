//
//  PollsActiveDaysTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 29/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import Loaf
import RewardzCommonComponents

class PollsActiveDaysTableViewCellCoordinator: NSObject, PostEditorCellCoordinatorProtocol, DaySelectorHandlerDelegate {
    
    weak var delegate : PostEditorCellFactoryDelegate?
    var cellType: FeedCellTypeProtocol = PollsActiveDaysTableViewCellType()
    weak var themeManager : CFFThemeManagerProtocol?
    
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        themeManager = inputModel.themeManager
        if let cell = inputModel.targetCell as? PollsActiveDaysTableViewCell{
            cell.activeDaysLabel?.font = .Highlighter2
            cell.activeDaysLabel?.text = "Poll Active for (days) :".localized
            cell.activeDaysStepper?.delegate = self
            cell.activeDaysStepper?.reading = 1
            cell.activeDaysStepper?.incrementIndicatorColor = themeManager?.getStepperActiveColor() ?? .stepperActiveColor
            cell.activeDaysStepper?.decrementIndicatorColor = .stepperInactiveColor
            cell.activeDaysStepper?.middleColor = .stepperMiddleColor
            cell.activeDaysStepper?.curvedBorderedControl()
            cell.containerView?.addBorders(edges: [.bottom, .left, .right], color: .feedCellBorderColor)
            
            cell.daysSelector.inferSizeForFixedNumberOfItems = daySelectorHandler.numberOfItems()
            cell.daysSelector.backgroundColor = UIColor.white
            cell.daysSelector.selectedBubbleColor = UIColor.getSelectedBubbleColor()
            cell.daysSelector.selectedBubbleTextColor = UIColor.getSelectedBubbleTextColor()
            cell.daysSelector.unSelectedBubbleColor = UIColor.getUnSelectedBubbleColor()
            cell.daysSelector.unSelectedBubbleTextColor = UIColor.getUnSelectedBubbleTextColor()
            cell.daysSelector.setDelegate(daySelectorHandler)
            cell.daysSelector.setDatasource(daySelectorHandler)
            cell.daysSelector.loadData(daySelectorHandler.indexOfDefaultSelectdYear())
            cell.daysSelector.isFromPoll = true
        }

    }
    
    private lazy var daySelectorHandler: DaySelectorHandler = {
        return DaySelectorHandler(self)
    }()
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return 118
    }
    
    func didFinishedSelection(selectedDay: Int) {
        delegate?.activeDaysForPollChanged(selectedDay)
    }

}

extension PollsActiveDaysTableViewCellCoordinator : StepperDelegate{
    func stepperDidChanged(sender: Stepper) {
        if let minVal = sender.minVal?.intValue{
            if sender.reading == minVal{
                sender.decrementIndicatorColor = .stepperInactiveColor
                showMessage("Poll must be active for more than".localized + " \(minVal) \(minVal == 1 ? "day".localized : "days".localized).")
            }else{
                sender.decrementIndicatorColor = themeManager?.getStepperActiveColor() ?? .stepperActiveColor// .stepperActiveColor
            }
        }
        
        if let maxVal = sender.maxVal?.intValue{
            if sender.reading == maxVal{
                sender.incrementIndicatorColor = .stepperInactiveColor
                showMessage("Poll cannot be active for more than".localized + " \(maxVal) \(maxVal == 1 ? "day".localized : "days".localized).")
            }else{
                sender.incrementIndicatorColor = themeManager?.getStepperActiveColor() ?? .stepperActiveColor //.stepperActiveColor
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
