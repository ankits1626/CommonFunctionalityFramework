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
   // let changes : changeDetails
}

struct actorDetails : Decodable {
    let email: String
    let department_name : String
    let profile_pic_url : String
    let first_name : String
    let last_name : String
}

struct changeDetails : Decodable {
    let category: String
}
