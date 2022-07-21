//
//  BOUSApprovalsDetailModel.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 20/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

struct BOUSApprovalsDetailData: Decodable {
    enum CodingValue : String, CodingKey {
        case user_strength = "user_strength"
        case nominationKey = "nomination"
        case user = "user"
        case created_by_user_info = "created_by_user_info"
    }
    let user_strength : userStrength
    let nomination : nominationKey
    let user : user
    let description : String
    let created_on : String
    let created_by_user_info : created_by_user_info
    
}

struct userStrength : Decodable {
    let name: String
    let message : String
    let background_color: String
}

struct nominationKey : Decodable {
    let message_to_reviewer : String
    let nominator_name : String
    enum CodingValue : String, CodingKey {
        case badge = "badges"
        case nominated_team_member = "nominated_team_member"
    }
    let badges : badge
    let nominated_team_member : nominated_team_member
    
}

struct badge : Decodable {
    let name: String
    let icon : String
    let award_points : String
}

struct user : Decodable {
    let full_name: String
    let profile_img : String
}

struct nominated_team_member : Decodable {
    let full_name: String
    let profile_img : String
}

struct created_by_user_info : Decodable {
    let full_name: String
    let profile_img : String
}
