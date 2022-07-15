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
    enum CodingKeys : String, CodingKey { case nomination = "nomination" }
    let nomination : nomination
}

struct nomination : Decodable {
    let nominator_name: String
}
