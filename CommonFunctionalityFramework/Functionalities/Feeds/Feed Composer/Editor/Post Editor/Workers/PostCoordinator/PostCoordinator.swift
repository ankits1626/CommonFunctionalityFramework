//
//  PostCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

protocol PostObserver : AnyObject {
    func mediaAttachedToPost()
    func attachedMediaUpdated()
    func attachedECardMediaUpdated()
    func allAttachedMediaRemovedFromPost()
    func removedAttachedMediaitemAtIndex(index : Int)
}

class PostCoordinatorError {
    static let PollNotReadyToBePosted = NSError(
           domain: "com.rewardz.EventDetailCellTypeError",
           code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Cannot create an empty Poll.".localized]
       )
    static let PollWithLessThan2ValidOptionsNotReadyToBePosted = NSError(
        domain: "com.rewardz.EventDetailCellTypeError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Cannot create a poll with less than 2 valid options.".localized]
    )
    static let PostNotReadyToBePosted = NSError(
        domain: "com.rewardz.EventDetailCellTypeError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Cannot create an empty Post.".localized]
    )
}

class PostCoordinator {
    private var currentPost : EditablePostProtocol
    weak var postObsever : PostObserver?
    let postType: FeedType
    
    init(postObsever : PostObserver?, postType: FeedType, editablePost : EditablePostProtocol?) {
        self.postObsever = postObsever
        self.postType = postType
        if let unwrappedPost = editablePost{
            currentPost = unwrappedPost
            print("&&&&&&&&&&&&& PostCoordinator \(currentPost.parentFeedItem) \(editablePost?.parentFeedItem)")
        }else{
            currentPost = EditablePost(postSharedChoice: .MyOrg, postType: postType)
        }
        
    }
    
    func getCurrentPost() -> EditablePostProtocol {
        return currentPost
    }
    
    func updateAttachedMediaItems(_ selectedMediaItems : [LocalSelectedMediaItem]?) {
        currentPost.attachedGif = nil
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
    
    func attachedEcardItems(_selectedECard : EcardListResponseValues) {
        currentPost.attachedGif = nil
        currentPost.selectedEcardMediaItems = _selectedECard
        postObsever?.attachedECardMediaUpdated()
    }
    
    func attachGifItem(_ selectedGif: RawGif) {
        currentPost.selectedMediaItems = nil
        currentPost.selectedEcardMediaItems = nil
        deleteAllRemoteAttachedMediaItems()
        currentPost.attachedGif = selectedGif
        postObsever?.allAttachedMediaRemovedFromPost()
    }
    
    func attachGifyGifItem(_ selectedGif: String) {
        currentPost.selectedMediaItems = nil
        currentPost.selectedEcardMediaItems = nil
        deleteAllRemoteAttachedMediaItems()
        currentPost.attachedGiflyGif = selectedGif
        postObsever?.allAttachedMediaRemovedFromPost()
    }
    
    func removeAttachedECard() {
        currentPost.selectedEcardMediaItems = nil
    }
    
    func removeAttachedGif() {
        currentPost.attachedGif = nil
    }
    
    func removeAttachedGiflyGif() {
        currentPost.attachedGiflyGif = nil
    }
    
    func updatePostTitle(title: String?) {
        currentPost.title = title
    }
    
    func updatePostDescription(decription: String?) {
        currentPost.postDesciption = decription
    }
    
    func getRemoteMediaCount() -> Int {
        return currentPost.remoteAttachedMedia?.count ?? 0
    }
    
    func removeMedia(index : Int, mediaSection: EditableMediaSection){
        switch mediaSection {
        case .Remote:
            removeRemoteMedia(index: index)
        case .Local:
            removeLocalSelectedMedia(index: index)
        }
    }
    
    private func deleteAllRemoteAttachedMediaItems(){
        currentPost.remoteAttachedMedia?.forEach({ (aMediaItem) in
            currentPost.deletedRemoteMediaArray.append(aMediaItem.getRemoteId())
        })
        currentPost.remoteAttachedMedia = nil
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
    
    func saveLocalMediaUrls(_ urls : [URL]) {
        currentPost.postableLocalMediaUrls = urls
    }
    
    func isPostWithSameDepartment() -> Bool {
        return currentPost.postSharedChoice == .MyDepartment
    }
    
    func isDepartmentSharedWithEditable() -> Bool{
        return false// getCurrentPost().remotePostId == nil
    }
    
    func updatePostWithSameDepartment(_ flag: Bool) {
        if flag {
            currentPost.postSharedChoice = .MyDepartment
        }else {
            currentPost.postSharedChoice = .MyOrg
        }
        currentPost.isShareWithSameDepartmentOnly = flag
    }
    
    func updatePostShareOption(_ shareOption: SharePostOption, selectedOrganisationsAndDepartments: FeedOrganisationDepartmentSelectionModel?){
        currentPost.postSharedChoice = shareOption
        currentPost.selectedOrganisationsAndDepartments = selectedOrganisationsAndDepartments
    }
    
    func updateActiveDayForPoll(_ days: Int) {
        currentPost.pollActiveDays = days
    }
    
    func getPostSuccessMessage() -> String {
        switch currentPost.postType {
        case .Poll:
            return "Poll successfully created.".localized
        case .Post:
            if currentPost.remotePostId == nil{
                return "Post successfully created.".localized
            }else{
                return "Post edited successfully.".localized
            }
        case .Greeting:
            return ""
        }
    }
}

extension PostCoordinator{
    func checkIfPostReadyToPublish() throws {
        switch postType {
        case .Poll:
            try checkIfPollReadyToBePosted()
        case .Post:
            try checkIfPostReadyToBePosted()
        case .Greeting:
            try checkIfPostReadyToBePosted()
        }
    }
    
    private func  checkIfPollReadyToBePosted() throws{
        if currentPost.title == nil{
            throw PostCoordinatorError.PollNotReadyToBePosted
        }
        
        if let title  = currentPost.title,
            title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw PostCoordinatorError.PollNotReadyToBePosted
        }
        if currentPost.pollOptions == nil{
            throw PostCoordinatorError.PollWithLessThan2ValidOptionsNotReadyToBePosted
        }
        else if let options = currentPost.getCleanPollOptions(){
            if options.count < 2{
                throw PostCoordinatorError.PollWithLessThan2ValidOptionsNotReadyToBePosted
            }
        }
    }
    
    private func  checkIfPostReadyToBePosted() throws{
        if let _ = currentPost.pollOptions{
            return
        }
        else if currentPost.attachedGif != nil{
            return
        }
        else if let title  = currentPost.title,
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        else if let description  = currentPost.postDesciption,
            !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            return
        }else if let mediaItems  = currentPost.selectedMediaItems,
            !mediaItems.isEmpty{
            return
        }else if let remoteMediaItems  = currentPost.remoteAttachedMedia,
            !remoteMediaItems.isEmpty{
            return
        }else if let remoteEcardItems  = currentPost.selectedEcardMediaItems,
                 remoteEcardItems.pk != 0{
                 return
        }else if let remoteGifItems  = currentPost.attachedGiflyGif,
                 !remoteGifItems.isEmpty{
                 return
        }
        else{
            throw PostCoordinatorError.PostNotReadyToBePosted
        }
        
    }
}

extension PostCoordinator {
    private func getPollAmplifyInputModel() -> AmplifyRequestHelperProtocol?{
        if let title = currentPost.title,
           !title.isEmpty{
            return PollAmplifyInputModel(userText: title)
        }else{
            return nil
        }
    }
    
    private func getPostAmplifyInputModel() -> AmplifyRequestHelperProtocol?{
        if let description = currentPost.postDesciption,
           !description.isEmpty{
            return PostAmplifyInputModel(userText: currentPost.title ?? "", userInputText2: description)
        }else{
            return nil
        }
        
    }
    
    private func getGreetingAmplifyInputModel() -> AmplifyRequestHelperProtocol?{
        return nil
    }
    
    func getAmplifyInputModel() -> AmplifyRequestHelperProtocol?{
        switch postType{
        case .Poll:
            return getPollAmplifyInputModel()
        case .Post:
            return getPostAmplifyInputModel()
        case .Greeting:
            return getGreetingAmplifyInputModel()
        }
    }
    
    
    private func parsePoll(_ amplifiedText: String){
        let quotesRemoved = amplifiedText.replacingOccurrences(of: "\"", with: "")
        let components = quotesRemoved.components(separatedBy: "#")
        updatePostTitle(title: components.first)
        let pollOptions = Array(components[1...]).prefix(4)
        for (index , pollOption) in pollOptions.enumerated(){
            if !pollOption.isEmpty{
                savePostOption(index: index, option: pollOption)
            }
        }
    }
    
    private func parsePost(_ amplifiedText: String){
        let components = amplifiedText.components(separatedBy: "#")
        updatePostTitle(title:components.count == 2 ? components.first : nil)
        updatePostDescription(decription: components.count == 2 ? components[safe: 1] : components.first)
    }
    
    private func parseGreeting(_ amplifiedText: String){
        
    }
        
    func parseAmplifiedtext(_ amplifiedText: String, completion: () -> Void){
        switch postType{
        case .Poll:
            parsePoll(amplifiedText)
            completion()
        case .Post:
            parsePost(amplifiedText)
        case .Greeting:
            parseGreeting(amplifiedText)
        }
    }
}
