//
//  GreetingsAnniAndBday.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 19/02/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation

struct GreetingAnniAndBday: Decodable {
    let date: String
    let department_name: String
    let profile_pic: String
    let thumbnail: String
    let type: String
    let userPk: Int
    let user_email: String
    let user_first_name: String
    let user_last_name: String
    var yearCompleted : Int?
}
