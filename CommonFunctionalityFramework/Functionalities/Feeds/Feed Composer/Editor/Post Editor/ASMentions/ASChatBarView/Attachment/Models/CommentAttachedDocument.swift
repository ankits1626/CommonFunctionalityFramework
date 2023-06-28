//
//  CommentAttachedDocument.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 04/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import RewardzCommonComponents

class CommentAttachedDocument : MediaItemProtocol{
    func getGiphy() -> String? {
        return ""
    }
    
    func getImagePK() -> Int? {
        return 0
    }
    
    let rawAttachedDocument: [String : Any]
    
    init( _ rawAttachedDocument: [String : Any]){
        self.rawAttachedDocument = rawAttachedDocument
    }
    
    func getMediaType() -> FeedMediaItemType {
        return .Document
    }
    
    func getCoverImageUrl() -> String? {
        return nil
    }
    
    func getRemoteId() -> Int {
        return -1
    }
    
    
    
    func getFileName() -> String?{
        if let url = rawAttachedDocument["name"] as? String{
            return url.components(separatedBy: "/").last
        }
        return nil
    }
    
    func getFileUrl() -> URL?{
        return rawAttachedDocument["localUrl"] as? URL
    }
    
    
}

public struct NetworkPostableCommentModel{
    public let commentText : String?
    public let postableLocalMediaUrls: [URL]?
    public let postableLocalDocumentUrls: [URL]?
}
