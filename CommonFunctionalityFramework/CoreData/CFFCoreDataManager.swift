//
//  CFFCoreDataManager.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 20/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation
import CoreData

class CFFCoreDataManager : NSObject{
    static let sharedInstance = CFFCoreDataManager()
    lazy var manager: GenericCoreDataManager = {
        return GenericCoreDataManager(
            managedObjectModelName: "CommonFunctionalityModel",
            modelBundle: Bundle(for: CFFCoreDataManager.self)
        )
    }()
    private override init() {
        super.init()
    }
}
