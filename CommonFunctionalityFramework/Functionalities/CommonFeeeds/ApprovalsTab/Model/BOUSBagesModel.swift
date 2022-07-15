//
//  BOUSBagesModel.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 14/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

struct BOUSBagesModelData: Decodable {
    var results: [BOUSApprovalDataResponseValues]
}

struct BOUSBagesModelDataResponseValues : Decodable {
    enum CodingKeys : String, CodingKey {
        case badges = "badges"
    }
    let badges : badges
    
}

struct badges : Decodable {
    let name: String
    let icon : String
    let points : String
}
