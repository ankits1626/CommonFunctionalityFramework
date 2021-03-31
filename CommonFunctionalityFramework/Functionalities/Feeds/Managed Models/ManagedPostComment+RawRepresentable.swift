//
//  ManagedPostComment+RawRepresentable.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 22/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

extension ManagedPostComment : RawRepresentable{
    public func getRawObject() -> RawObjectProtocol{
        return  FeedComment(managedObject: self)
    }
}
