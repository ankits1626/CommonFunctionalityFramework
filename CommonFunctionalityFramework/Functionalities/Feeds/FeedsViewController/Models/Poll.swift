//
//  Poll.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

enum PollState {
    case NotActive
    case Active(hasVoted : Bool)
}


struct PollOption {
    var title : String{
        return rawPollOption["answer_text"] as? String ?? ""
    }
    let hasVoted : Bool
    private let rawPollOption : [String : Any]
    init(_ rawPollOption : [String : Any]) {
        self.rawPollOption = rawPollOption
        hasVoted = rawPollOption["has_voted"] as? Bool ?? false
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
    
    private func hasUserVoted() -> Bool{
        return rawPoll["user_has_voted"] as? Bool ?? false
    }
    
    func getPollInfo() -> String? {
        var pollInfos = [String]()
        if let totalVotes = rawPoll["total_votes"] as? Int64{
            pollInfos.append("\(totalVotes) vote\(totalVotes == 1 ? "" : "s")")
        }
        if let pollRemainingTime = rawPoll["poll_remaining_time"] as? String{
            pollInfos.append("\(pollRemainingTime) left")
        }
        return pollInfos.joined(separator:  " . ")
    }
    
}
