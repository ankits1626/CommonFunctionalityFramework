//
//  AttachmentDataManager.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 04/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation


class AttachmentDataManager{
    var attachments = [MediaItemProtocol]()
    
    func addSelectedDocument(documentUrl: URL, completion: (() -> Void)?){
        let doc = CommentAttachedDocument([
            "name" : "\(documentUrl.lastPathComponent)",
            "localUrl" : documentUrl
        ])
        attachments = [doc]
        completion?()
    }
}
