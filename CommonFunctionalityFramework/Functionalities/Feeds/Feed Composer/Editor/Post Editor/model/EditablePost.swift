//
//  EditablePost.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import Photos

protocol EditablePostProtocol {
    var deletedRemoteMediaArray : [Int] {set get}
    var title : String? {set get}
    var postDesciption : String? {set get}
    var pollOptions : [String]? {get set}
    var selectedMediaItems : [LocalSelectedMediaItem]? {set get}
    var attachedGif : RawGif?{set get}
    var postType : FeedType {set get}
    func getNetworkPostableFormat() -> [String : Any]
    var postableMediaMap : [Int : Data]? { get set}
    var postableLocalMediaUrls : [URL]? { get set}
    var remoteAttachedMedia: [MediaItemProtocol]?{get set}
    var remotePostId : String?{get}
    func getEditablePostNetworkModel(_ baseUrl : String) -> EditablePostNetworkModel
    var isShareWithSameDepartmentOnly : Bool {set get}
    var pollActiveDays : Int {set get}
    func getCleanPollOptions() -> [String]?
    func isGifAttached() -> Bool
    var selectedEcardMediaItems : EcardListResponseValues? {set get}
    func isECardAttached() -> Bool
    var attachedGiflyGif : String?{set get}
}


enum DepartmentSharedChoice : Int {
    case SelfDepartment = 10
    case AllDepartment = 20
}
struct EditablePost : EditablePostProtocol{
    var selectedEcardMediaItems: EcardListResponseValues?
    var attachedGiflyGif : String?
    
    
    
    func isECardAttached() -> Bool {
        return selectedEcardMediaItems != nil
    }
    
    func isGifAttached() -> Bool {
        if let gif = attachedGiflyGif ,
            !gif.isEmpty {
            return true
        }
        return false
    }
    
    func getCleanPollOptions() -> [String]? {
        return pollOptions?.filter { (anOption) -> Bool in
            return !anOption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    var pollActiveDays: Int = 1
    var isShareWithSameDepartmentOnly: Bool
    var deletedRemoteMediaArray = [Int]()
    var postableLocalMediaUrls: [URL]?
    var postableMediaMap: [Int : Data]?
    var attachedGif : RawGif?
    
    func getNetworkPostableFormat() -> [String : Any] {
        switch postType {
        case .Poll:
            return getPollDictionary()
        case .Post:
            return getPostDictionary()
        }
    }
    
    private func getPollDictionary() -> [String : Any]{
        var pollDictionary = [String : Any]()
        if let unwrappedTitle = title{
            pollDictionary["title"] = unwrappedTitle
        }
        if let options = getCleanPollOptions(){
           pollDictionary["answers"] = options
        }
        pollDictionary["shared_with"] = isShareWithSameDepartmentOnly ? DepartmentSharedChoice.SelfDepartment.rawValue : DepartmentSharedChoice.AllDepartment.rawValue
        pollDictionary["active_days"] = pollActiveDays
        return pollDictionary
    }
    
    private func getPostDictionary() -> [String : Any]{
        var postDictionary = [String : Any]()
        if let unwrappedTitle = title{
            postDictionary["title"] = unwrappedTitle
        }
        if let unwrappedDescription = postDesciption{
            postDictionary["description"] = unwrappedDescription
        }
        
        if let unwrappedGif = attachedGiflyGif, !unwrappedGif.isEmpty {
            postDictionary["gif"] = unwrappedGif
        }else{
            postDictionary["gif"] = ""
        }
        
        if let unwrappedECard = selectedEcardMediaItems{
            postDictionary["ecard"] = "\(unwrappedECard.pk)"
        }else{
            postDictionary["ecard"] = ""
        }
        
        if !deletedRemoteMediaArray.isEmpty{
            postDictionary["delete_image_ids"] = (deletedRemoteMediaArray.map{String($0)}).joined(separator: ",")
        }
        postDictionary["shared_with"] = isShareWithSameDepartmentOnly ? DepartmentSharedChoice.SelfDepartment.rawValue : DepartmentSharedChoice.AllDepartment.rawValue
        return postDictionary
    }
    
    var postType: FeedType
    
    var pollOptions: [String]?
    
    var title: String?
    
    var postDesciption: String?
    
    var remoteAttachedMedia: [MediaItemProtocol]?
    
    var selectedMediaItems : [LocalSelectedMediaItem]?
    
    let remotePostId : String?
    
    func getEditablePostNetworkModel(_ baseUrl : String) -> EditablePostNetworkModel{
        return EditablePostNetworkModel(
            url: getEditablePostNetworkUrl(baseUrl),
            method: getEditablePostNetworkMethod(),
            postHttpBodyDict: getNetworkPostableFormat() as NSDictionary
        )
    }
    
    private func getEditablePostNetworkUrl(_ baseUrl : String) -> URL?{
        if let unwrappedRemotePostId = remotePostId{
            switch postType {
            case .Poll:
                return nil
            case .Post:
                return URL(string: baseUrl + "feeds/api/posts/\(unwrappedRemotePostId)/")
            }
        }else{
            switch postType {
            case .Poll:
                return URL(string: baseUrl + "feeds/api/posts/create_poll/")
            case .Post:
                return URL(string: baseUrl + "feeds/api/posts/")
            }
        }
    }
    
    private func getEditablePostNetworkMethod () -> HTTPMethod{
        return  remotePostId == nil ? .POST : .PUT
    }
    
}


struct EditablePostNetworkModel {
    var url : URL?
    var method : HTTPMethod
    var postHttpBodyDict : NSDictionary?
}
