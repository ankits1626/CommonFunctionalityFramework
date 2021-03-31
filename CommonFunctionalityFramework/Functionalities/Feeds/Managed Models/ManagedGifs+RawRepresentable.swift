//
//  ManagedGifs+RawRepresentable.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 10/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

extension ManagedGifs : RawRepresentable{
    public func getRawObject() -> RawObjectProtocol{
        return RawGif(managedObject: self)
    }
    
}
