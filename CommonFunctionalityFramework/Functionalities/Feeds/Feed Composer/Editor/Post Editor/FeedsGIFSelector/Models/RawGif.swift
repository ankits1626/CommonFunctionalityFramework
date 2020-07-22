//
//  RawGif.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 10/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import CoreData

public struct RawGif : RawObjectProtocol{
    private var rawGif : [String : Any]
    private var gifSourceUrl : String?
    init(input: [String : Any]) {
        self.rawGif = input
    }
    
    init( sourceUrl : String?) {
        gifSourceUrl = sourceUrl
        rawGif = [String : Any]()
    }
    
    init(managedObject: NSManagedObject) {
        self.rawGif = (managedObject as! ManagedGifs).rawGif as! [String : Any]
    }
    
    var gifIdentifier: Int64{
        if let unwrappedID = rawGif["id"] as? String{
            return Int64(unwrappedID) ?? -1
        }
        
        return -1
    }
    
    func getGifMarkup() -> String?{
        if let gifSourceUrl = getGifSourceUrl(){
            return "<gif>\(gifSourceUrl)</gif>"
        }else{
            return nil
        }
    }
    
    func getGifSourceUrl() -> String?  {
        if let unwrappedGifSourceUrl = gifSourceUrl{
            return unwrappedGifSourceUrl
        }
        return (((rawGif["media"] as? [[String : Any]])?.first?["gif"]) as? [String : Any])?["url"] as? String
    }
    
    func getGifIconSourceUrl() -> String?  {
        if let unwrappedGifSourceUrl = gifSourceUrl{
            return unwrappedGifSourceUrl
        }
        return (((rawGif["media"] as? [[String : Any]])?.first?["tinygif"]) as? [String : Any])?["url"] as? String
    }
    
    func getManagedObject() -> NSManagedObject {
        let managedGif : ManagedGifs!
        let fetchRequest : NSFetchRequest<ManagedGifs> = ManagedGifs.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier = %d && identifier != -1", self.gifIdentifier)
        
        let fetchedGifs = CFFCoreDataManager.sharedInstance.manager.fetchManagedObject(
            type: ManagedGifs.self,
            fetchRequest: fetchRequest,
            context: CFFCoreDataManager.sharedInstance.manager.privateQueueContext
        )
        if let firstFetchedManagedGif = fetchedGifs.fetchedObjects?.first{
            print("<<<<<<<<< updated with identifier \(firstFetchedManagedGif.identifier)")
            managedGif = firstFetchedManagedGif
        }else{
            managedGif = CFFCoreDataManager.sharedInstance.manager.insertManagedObject(type: ManagedGifs.self)
            managedGif.createdTimeStamp = Date()
        }
        managedGif.rawGif = rawGif as NSDictionary
        managedGif.identifier = gifIdentifier
        return managedGif
    }
    
}
