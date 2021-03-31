//
//  ManagedPost+Init.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 20/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

extension ManagedPost : RawRepresentable{
    public func getRawObject() -> RawObjectProtocol{
        return RawFeed(managedObject: self)
    }
    
}
