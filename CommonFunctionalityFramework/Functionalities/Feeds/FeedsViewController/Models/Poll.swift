//
//  Poll.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

enum PollState {
    case NotActive
    case Active(hasVoted : Bool)
}


class PollOption : Equatable {
    static func == (lhs: PollOption, rhs: PollOption) -> Bool {
        return lhs.answerID == rhs.answerID
    }
    
    var title : String{
        return rawPollOption["answer_text"] as? String ?? ""
    }
    let hasVoted : Bool
    private let rawPollOption : [String : Any]
    private let answerID : Int64
    var optionColor : UIColor!
    
    init(_ rawPollOption : [String : Any]) {
        self.rawPollOption = rawPollOption
        hasVoted = rawPollOption["has_voted"] as? Bool ?? false
        answerID = rawPollOption["id"] as! Int64
    }
    
    func getNewtowrkPostableAnswer() -> [String: Any] {
        return ["answer_id" :  answerID] 
    }
    
    func getPercentage() -> Int {
        return rawPollOption["percentage"] as?  Int ?? 0
    }
}

struct Poll {
    private let rawPoll : [String : Any]
    
    init(rawPoll : [String : Any]) {
        self.rawPoll = rawPoll
    }
    
    func getPollOptions() -> [PollOption] {
        var options = [PollOption]()
        
        if
            let rawOptions = rawPoll["answers"] as? [[String : Any]]{
            rawOptions.forEach { (aRwaOption) in
                options.append(PollOption(aRwaOption))
            }
            var maxPercentage = 0
            options.forEach { (anOption) in
                anOption.optionColor = .progressTrackLightColor
                if anOption.getPercentage() > maxPercentage{
                    maxPercentage = anOption.getPercentage()
                }
            }
            if !isPollActive(){
                let maxPercentageOptions = options.filter { (anOption) -> Bool in
                    return anOption.getPercentage() == maxPercentage
                }
                if maxPercentageOptions.count == options.count{
                    maxPercentageOptions.forEach { (anOption) in
                        anOption.optionColor = .progressTrackLightColor
                    }
                }else{
                    maxPercentageOptions.forEach { (anOption) in
                        anOption.optionColor = .progressTrackMaxColor
                    }
                }
            }
        }
        return options
    }
    
//    func getPollState() -> PollState{
//        if isPollActive(){
//            return .Active(hasVoted: hasUserVoted())
//        }else{
//            return .NotActive
//        }
//    }
    
    func isPollActive() -> Bool{
        return rawPoll["is_poll_active"] as? Bool ?? false
    }
    
    func hasUserVoted() -> Bool{
        return rawPoll["user_has_voted"] as? Bool ?? false
    }
    
    func getPollInfo() -> String? {
        var pollInfos = [String]()
        if let totalVotes = rawPoll["total_votes"] as? Int64{
            pollInfos.append("\(totalVotes) vote\(totalVotes == 1 ? "" : "s")")
        }
        if !isPollActive(){
            pollInfos.append("Final Result")
        }
        if let pollRemainingTime = rawPoll["poll_remaining_time"] as? String{
            pollInfos.append("\(pollRemainingTime) left")
        }
        return pollInfos.joined(separator:  " . ")
    }
    
    func getPollId() -> Int64 {
        return rawPoll["id"] as? Int64 ?? -1
    }
    
}
