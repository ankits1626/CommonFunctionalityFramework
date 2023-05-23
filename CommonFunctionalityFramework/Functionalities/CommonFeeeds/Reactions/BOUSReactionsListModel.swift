//
//  BOUSReactionsListModel.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

struct BOUSReactionsListData: Decodable {
    var results: [BOUSReactionListDataResponseValues]
    var counts : [BOUSReactionCountDataResponseValues]
}

struct BOUSReactionListDataResponseValues : Decodable {
    enum CodingValue : String, CodingKey { case user_info = "user_info" }
    let user_info : user_info
    let reaction_type : Int
}

struct user_info : Decodable {
    let full_name: String
    let profile_img : String
    let departments : [departmentData]
}

struct departmentData : Decodable {
    let name : String
}

struct BOUSReactionCountDataResponseValues : Decodable {
    let reaction_type : Int
    let reaction_count : Int
}
