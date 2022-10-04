//
//  AttachmentDataManager.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 04/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import UIKit
import RewardzCommonComponents

class AttachmentDataManager{
    private var attachedImages = [LocalSelectedMediaItem]()
    private var attachmentDocuments = [MediaItemProtocol]()
    
    func addSelectedDocument(documentUrl: URL, completion: (() -> Void)?){
        let doc = CommentAttachedDocument([
            "name" : "\(documentUrl.lastPathComponent)",
            "localUrl" : documentUrl
        ])
        attachmentDocuments = [doc]
        attachedImages = []
        completion?()
    }
    
    func addSelectedImages(images: [LocalSelectedMediaItem]?, completion: (() -> Void)?){
        if let unwrappedImages = images{
            attachedImages = unwrappedImages
        }else{
            attachedImages = []
        }
        attachmentDocuments = []
        completion?()
    }
    
    func getRequiredAttachmentHeight() -> Int?{
        if !attachmentDocuments.isEmpty{
            return 65
        } else if !attachedImages.isEmpty{
            return 105
        }
        return nil
        
    }
    
    func deleteSelectedDocument(_ index : Int, completion : () -> Void){
        attachmentDocuments.remove(at: index)
        completion()
    }
    
    func deleteSelectedImage(_ index : Int, completion : () -> Void){
        attachedImages.remove(at: index)
        completion()
    }
}

extension AttachmentDataManager{
    
    func getNumberOfAttachments() -> Int{
        if !attachmentDocuments.isEmpty{
            return attachmentDocuments.count
        } else if !attachedImages.isEmpty{
            return attachedImages.count
        }
        return 0
    }
    
    func getCurrentAttachmentType() -> FeedMediaItemType {
        if !attachmentDocuments.isEmpty{
            return .Document
        } 
        return .Image
    }
    
    func getAttachedDocument(index: Int) -> MediaItemProtocol{
        return attachmentDocuments[index]
    }
    
    func getAttachedImage(index: Int) -> LocalSelectedMediaItem{
        return attachedImages[index]
    }
}

