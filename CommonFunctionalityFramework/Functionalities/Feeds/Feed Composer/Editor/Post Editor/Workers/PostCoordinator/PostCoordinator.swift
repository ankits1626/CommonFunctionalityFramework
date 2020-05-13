//
//  PostCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

protocol PostObserver {
    func mediaAttachedToPost()
    func attachedMediaUpdated()
    func allAttachedMediaRemovedFromPost()
    func removedAttachedMediaitemAtIndex(index : Int)
}

class PostCoordinatorError {
    static let PollNotReadyToBePosted = NSError(
           domain: "com.rewardz.EventDetailCellTypeError",
           code: 1,
           userInfo: [NSLocalizedDescriptionKey: "Poll is not ready to be posted. Please fill all the required fields."]
       )
    
    static let PostNotReadyToBePosted = NSError(
        domain: "com.rewardz.EventDetailCellTypeError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Post is not ready to be posted. Please fill all the required fields."]
    )
}

class PostCoordinator {
    private var currentPost : EditablePostProtocol
    var postObsever : PostObserver?
    let postType: FeedType
    
    init(postObsever : PostObserver?, postType: FeedType, editablePost : EditablePostProtocol?) {
        self.postObsever = postObsever
        self.postType = postType
        if let unwrappedPost = editablePost{
            currentPost = unwrappedPost
        }else{
            currentPost = EditablePost(isShareWithSameDepartmentOnly: false, postType: postType, remotePostId: nil)
        }
        
    }
    
    func getCurrentPost() -> EditablePostProtocol {
        return currentPost
    }
    
    func updateAttachedMediaItems(_ selectedMediaItems : [LocalSelectedMediaItem]?) {
        if let _ = selectedMediaItems{
            if currentPost.selectedMediaItems == nil{
                // insert
                currentPost.selectedMediaItems = selectedMediaItems
                postObsever?.mediaAttachedToPost()
            }else{
                //update
                currentPost.selectedMediaItems = selectedMediaItems
                postObsever?.attachedMediaUpdated()
            }
        }else{
            if currentPost.selectedMediaItems != nil{
                //delete
                currentPost.selectedMediaItems = selectedMediaItems
                postObsever?.allAttachedMediaRemovedFromPost()
            }
        }
    }
    
    func updatePostTile(title: String?) {
        currentPost.title = title
    }
    
    func updatePostDescription(decription: String?) {
        currentPost.postDesciption = decription
    }
    
    func removeMedia(index : Int, mediaSection: EditableMediaSection){
        switch mediaSection {
        case .Remote:
            removeRemoteMedia(index: index)
        case .Local:
            removeLocalSelectedMedia(index: index)
        }
    }
    
    private func removeRemoteMedia(index: Int){
        if let mediaItem = currentPost.remoteAttachedMedia?[index]{
            currentPost.deletedRemoteMediaArray.append(mediaItem.getRemoteId())
        }
        currentPost.remoteAttachedMedia?.remove(at: index)
        
        if let items = currentPost.remoteAttachedMedia{
           if items.count == 0{
                currentPost.remoteAttachedMedia = nil
            }
        }
        postObsever?.allAttachedMediaRemovedFromPost()
    }
    
    private func removeLocalSelectedMedia(index: Int){
        currentPost.selectedMediaItems?.remove(at: index)
        if let items = currentPost.selectedMediaItems{
            if items.count == 1{
                postObsever?.attachedMediaUpdated()
            }
            else if items.count == 0{
                currentPost.selectedMediaItems = nil
                postObsever?.allAttachedMediaRemovedFromPost()
            }else{
                postObsever?.removedAttachedMediaitemAtIndex(index: index)
            }
            
        }else{
            postObsever?.removedAttachedMediaitemAtIndex(index: index)
        }
    }
    
    private var optionsMap = [Int : String?]()
    func savePostOption(index : Int, option: String?){
        optionsMap[index] = option
        var options = [String]()
        optionsMap.keys.sorted(by: { (first, second) -> Bool in
            return first < second
        }).forEach { (aKey) in
            if let value = optionsMap[aKey],
                let unwrappedOption = value{
                options.append(unwrappedOption)
            }
        }
        currentPost.pollOptions = options.isEmpty ? nil : options
    }
    
    func saveMediaDataMap(map :[Int : Data]?) {
        currentPost.postableMediaMap = map
    }
    
    func saveLocalMediUrls(_ urls : [URL]) {
        currentPost.postableLocalMediaUrls = urls
    }
    
    func isPostWithSameDepartment() -> Bool {
        return currentPost.isShareWithSameDepartmentOnly
    }
    func isDepartmentSharedWithEditable() -> Bool{
        return getCurrentPost().remotePostId == nil
    }
    
    func updatePostWithSameDepartment(_ flag: Bool) {
        currentPost.isShareWithSameDepartmentOnly = flag
    }
    
    func updateActiveDayForPoll(_ days: Int) {
        currentPost.pollActiveDays = days
    }
    
}

extension PostCoordinator{
    func checkIfPostReadyToPublish() throws {
        switch postType {
        case .Poll:
            try checkIfPollReadyToBePosted()
        case .Post:
            try checkIfPostReadyToBePosted()
        }
    }
    
    private func  checkIfPollReadyToBePosted() throws{
        if let _ = currentPost.pollOptions{
            
        }else{
            throw PostCoordinatorError.PollNotReadyToBePosted
        }
    }
    
    private func  checkIfPostReadyToBePosted() throws{
        if let _ = currentPost.pollOptions{
            return
        }
        else if let _  = currentPost.postDesciption{
            return
        }else if let mediaItems  = currentPost.selectedMediaItems,
        !mediaItems.isEmpty{
            return
        }
        else{
            throw PostCoordinatorError.PostNotReadyToBePosted
        }
        
    }
}
