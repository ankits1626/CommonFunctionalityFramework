//
//  FeedsEcardListResponseValues.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 12/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation

struct EcardList: Decodable {
    var results: [EcardListResponseValues]
}

struct EcardListResponseValues : Decodable {
    let category: Int
    let image: String
    let pk : Int
   // let organization: Int
}

struct EcardCategory: Decodable {
    var results: [EcardCategoryResponseValues]
}

struct EcardCategoryResponseValues : Decodable {
    let pk: Int
    let name: String
    let organization: Int?
}
