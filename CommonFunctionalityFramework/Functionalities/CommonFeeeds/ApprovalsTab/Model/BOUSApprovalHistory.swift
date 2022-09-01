//
//  BOUSApprovalHistory.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 29/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

struct BOUSApprovalHistory: Decodable {
    var results: [BOUSApprovalHistoryDataResponseValues]
}

struct BOUSApprovalHistoryDataResponseValues : Decodable {
    let actor : actorDetails
    let action : String?
    let changes : changeDetails?
    let timestamp : String?
}

struct actorDetails : Decodable {
    let email: String
    let department_name : String
    let profile_pic_url : String
    let first_name : String
    let last_name : String
}

struct changeDetails : Decodable {
    let badges: badgesChanges?
    let shared_with: privacyChanges?
}

struct badgesChanges : Decodable {
    let old_badge: String
    let new_badge: String
}

struct privacyChanges : Decodable {
    let old: String
    let new: String
}
