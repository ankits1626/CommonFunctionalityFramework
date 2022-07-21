//
//  BOUSApprovalsModel.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 13/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

struct BOUSApprovalData: Decodable {
    var results: [BOUSApprovalDataResponseValues]
}

struct BOUSApprovalDataResponseValues : Decodable {
    let id : Int
    let time_left : String
    enum CodingValue : String, CodingKey { case nomination = "nomination" }
    let nomination : nomination
}

struct nomination : Decodable {
    let nominator_name: String
    let created : String
    enum CodingValue : String, CodingKey {
        case badges = "badges"
        case user_strength = "user_strength"
        case nominated_teamMember = "nominated_team_member"
    }
    let badges : badges
    let user_strength : user_strength
    let nominated_team_member : nominated_teamMember
}

struct badges : Decodable {
    let name: String
    let icon : String
    let points : String
}

struct user_strength : Decodable {
    let name: String
    let message : String
}


struct nominated_teamMember : Decodable {
    let full_name: String
    let profile_img : String
}
