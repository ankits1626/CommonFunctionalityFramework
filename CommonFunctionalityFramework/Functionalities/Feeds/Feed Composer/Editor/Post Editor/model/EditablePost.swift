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
    var postType : FeedType {set get}
    func getNetworkPostableFormat() -> [String : Any]
    var postableMediaMap : [Int : Data]? { get set}
    var postableLocalMediaUrls : [URL]? { get set}
    var remoteAttachedMedia: [MediaItemProtocol]?{get set}
    var remotePostId : String?{get}
    func getEditablePostNetworkModel() -> EditablePostNetworkModel
    var isShareWithSameDepartmentOnly : Bool {set get}
    var pollActiveDays : Int {set get}
}

struct LocalSelectedMediaItem : Equatable {
    static func ==(_ lhs: LocalSelectedMediaItem, _ rhs: LocalSelectedMediaItem) -> Bool {
      return lhs.identifier == rhs.identifier
    }
    var identifier : String
    var asset: PHAsset?
    var mediaType : PHAssetMediaType
}
enum DepartmentSharedChoice : Int {
    case SelfDepartment = 10
    case AllDepartment = 20
}
struct EditablePost : EditablePostProtocol{
    var pollActiveDays: Int = 1
    var isShareWithSameDepartmentOnly: Bool
    var deletedRemoteMediaArray = [Int]()
    var postableLocalMediaUrls: [URL]?
    var postableMediaMap: [Int : Data]?
    
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
        if let options = pollOptions{
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
    
    func getEditablePostNetworkModel() -> EditablePostNetworkModel{
        return EditablePostNetworkModel(
            url: getEditablePostNetworkUrl(),
            method: getEditablePostNetworkMethod(),
            postHttpBodyDict: getNetworkPostableFormat() as NSDictionary
        )
    }
    
    private func getEditablePostNetworkUrl() -> URL?{
        if let unwrappedRemotePostId = remotePostId{
            switch postType {
            case .Poll:
                return nil
            case .Post:
                return URL(string: "https://demo.flabulessdev.com/feeds/api/posts/\(unwrappedRemotePostId)/")
            }
        }else{
            switch postType {
            case .Poll:
                return URL(string: "https://demo.flabulessdev.com/feeds/api/posts/create_poll/")
            case .Post:
                return URL(string: "https://demo.flabulessdev.com/feeds/api/posts/")
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
