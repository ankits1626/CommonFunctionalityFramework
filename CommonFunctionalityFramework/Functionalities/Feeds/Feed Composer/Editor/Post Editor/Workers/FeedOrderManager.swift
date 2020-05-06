//
//  FeedOrderManager.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation
import CoreData

enum FeedInsertDirection : Int{
    case Top = 0
    case Bottom
    
}

class FeedOrderManager {
    func insertFeeds(rawFeeds : [[String : Any]], insertDirection : FeedInsertDirection, completion :(() -> Void)?){
        CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
            rawFeeds.forEach { (aRawFeed) in
                let feed = RawFeed(input: aRawFeed).getManagedObject() as! ManagedPost
                if insertDirection == .Top{
                   self.addAtTop(feed)
                }
            }
            CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                if let unwrappedCompletion = completion{
                    unwrappedCompletion()
                }
            }
        }
    }
    
    private func addAtTop(_ post : ManagedPost) {
        let priorityFetchRequest : NSFetchRequest<ManagedPost> = ManagedPost.fetchRequest()
        var sort = NSSortDescriptor(key: "createdTimeStamp", ascending: false)
        priorityFetchRequest.predicate = NSPredicate(format: "isPriority = 1")
        priorityFetchRequest.sortDescriptors = [sort]
        
        let lastPriorityFeed = CFFCoreDataManager.sharedInstance.manager.fetchManagedObject(
            type: ManagedPost.self,
            fetchRequest: priorityFetchRequest,
            context: CFFCoreDataManager.sharedInstance.manager.privateQueueContext
            ).fetchedObjects?.first
        
        print("<<<<<<<<<< last priority feed = %@", (lastPriorityFeed?.getRawObject() as? RawFeed)?.getFeedTitle())
        
        priorityFetchRequest.predicate = NSPredicate(format: "postId != -1")
        sort = NSSortDescriptor(key: "createdTimeStamp", ascending: true)
        priorityFetchRequest.sortDescriptors = [sort]
        let firstFeed = CFFCoreDataManager.sharedInstance.manager.fetchManagedObject(
        type: ManagedPost.self,
        fetchRequest: priorityFetchRequest,
        context: CFFCoreDataManager.sharedInstance.manager.privateQueueContext
        ).fetchedObjects?.first
        
        print("<<<<<<<<<< last priority feed = %@", (firstFeed?.getRawObject() as? RawFeed)?.getFeedTitle())
        var creationDate = NSDate().timeIntervalSinceNow
        if let unwrappedFirstFeed = firstFeed{
            creationDate = unwrappedFirstFeed.createdTimeStamp.timeIntervalSinceNow
        }
        
        
        if let unwrappedLastPriorityFeed = lastPriorityFeed{
            let lastPriorityFeedTimeStamp = unwrappedLastPriorityFeed.createdTimeStamp
            let delta = creationDate - lastPriorityFeedTimeStamp.timeIntervalSinceNow
            creationDate = creationDate - (delta/1000)
        }else{
            creationDate = creationDate - (1/1000)
        }
        
        post.createdTimeStamp = NSDate(timeIntervalSinceNow: creationDate)
    }
    
}
