//
//  SelectedPollAnswerMapper.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

class SelectedPollAnswerMapper {
    private var selectedPollAnswerMap =  [Int64 : PollOption]()
    
    func toggleOptionSelection(pollId : Int64, selectedOption : PollOption) {
        if let alReadyselectedOption = selectedPollAnswerMap[pollId],
            alReadyselectedOption == selectedOption{
            print("<<<<<<<<<<<<< deselect option")
            selectedPollAnswerMap.removeValue(forKey: pollId)
        }else{
            selectedPollAnswerMap[pollId] = selectedOption
        }
    }
    
    func isOptionSelected(_ option : PollOption) -> Bool {
        return selectedPollAnswerMap.values.contains(option)
    }
    
    func getSelectedOption(feedIdentifier : Int64) -> PollOption? {
        return selectedPollAnswerMap[feedIdentifier]
    }
    
    func removeSelectedOptionAfterAnswerIsPosted(feedIdentifier : Int64) {
        selectedPollAnswerMap.removeValue(forKey: feedIdentifier)
    }
}
