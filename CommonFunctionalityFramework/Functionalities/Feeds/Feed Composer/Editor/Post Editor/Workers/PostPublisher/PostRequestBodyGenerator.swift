//
//  PostRequestGenerator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 31/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PostRequestBodyGenerator {
    
    func getPostRequestBody(post : EditablePostProtocol, boundary : String) -> Data? {
        var body = Data()
        let boundary = "--Ju5tH77P15Aw350m3\r\n"
            .data(using: String.Encoding.utf8)!
        for (k, v) in post.getNetworkPostableFormat() {
            let valueToSend: Any = v is NSNull ? "null" : v
            body.append(boundary)
            body.append("Content-Disposition: form-data; name=\"\(k)\"\r\n\r\n"
                .data(using: String.Encoding.utf8)!)
            body.append("\(valueToSend)\r\n".data(using: String.Encoding.utf8)!)
        }
        if let localUrls = post.postableLocalMediaUrls{
            for (_, file) in localUrls.enumerated() {
                body.append(boundary)
                var partContent: Data? = nil
                var partFilename: String? = nil
                let partMimetype: String? = nil
                partFilename = file.lastPathComponent
                if let URLContent = try? Data(contentsOf: file) {
                    partContent = URLContent
                }
                if let content = partContent, let filename = partFilename {
                    let dispose = "Content-Disposition: form-data; name=\"images\"; filename=\"\(filename)\"\r\n"
                    body.append(dispose.data(using: String.Encoding.utf8)!)
                    if let type = partMimetype {
                        body.append(
                            "Content-Type: \(type)\r\n\r\n".data(using: String.Encoding.utf8)!)
                    } else {
                        body.append("\r\n".data(using: String.Encoding.utf8)!)
                    }
                    body.append(content)
                    body.append("\r\n".data(using: String.Encoding.utf8)!)
                }
            }
        }
        if body.count > 0 {
            body.append("--Ju5tH77P15Aw350m3--\r\n"
                .data(using: String.Encoding.utf8)!)
        }
        return body
    }
}
