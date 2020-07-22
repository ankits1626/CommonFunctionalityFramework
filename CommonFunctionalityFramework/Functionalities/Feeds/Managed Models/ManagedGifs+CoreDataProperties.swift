//
//  ManagedGifs+CoreDataProperties.swift
//  
//
//  Created by Rewardz on 10/07/20.
//
//

import Foundation
import CoreData


extension ManagedGifs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedGifs> {
        return NSFetchRequest<ManagedGifs>(entityName: "ManagedGifs")
    }

    @NSManaged public var rawGif: NSObject?
    @NSManaged public var identifier: Int64
    @NSManaged public var createdTimeStamp: Date?

}
