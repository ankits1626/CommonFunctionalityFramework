//
//  RawRepresentable.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 20/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation
import CoreData

protocol RawRepresentable {
    func getRawObject() -> RawObjectProtocol
}

protocol RawObjectProtocol {
    init(input : [String : Any])
    init(managedObject : NSManagedObject)
    func getManagedObject() -> NSManagedObject
}
