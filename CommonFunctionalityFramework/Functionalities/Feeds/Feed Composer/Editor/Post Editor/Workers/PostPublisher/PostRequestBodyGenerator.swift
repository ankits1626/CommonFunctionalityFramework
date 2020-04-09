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
            for (index, file) in localUrls.enumerated() {
                body.append(boundary)
                var partContent: Data? = nil
                var partFilename: String? = nil
                var partMimetype: String? = nil
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
        /*if let mediaMap = post.postableMediaMap{
            for (k, v) in mediaMap {
                let image = UIImage(data: v)
                body.append(boundary)
                let partContent: Data? = v
                let partFilename: String? = "postImage_\(k).jpeg"
                let partMimetype: String? = "images"
                if let content = partContent, let filename = partFilename {
                    let dispose = "Content-Disposition: form-data; name=\"img\"; filename=\"\(filename)\"\r\n"
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
        }*/

        if body.count > 0 {
            body.append("--Ju5tH77P15Aw350m3--\r\n"
                .data(using: String.Encoding.utf8)!)
        }
        return body
    }
    
//    func getPostRequestBody(post : EditablePostProtocol, boundary : String) -> Data? {
//        var body = Data()
//        for (paramName, paramValue) in post.getNetworkPostableFormat() {
//            body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
//            body.append(( "Content-Disposition:form-data; name=\"\(paramName)\"").data(using: String.Encoding.utf8)!)
//            body.append(("\r\n\r\n\(paramValue)\r\n").data(using: String.Encoding.utf8)!)
//        }
//
//        if let mediaMap = post.postableMediaMap{
//            for (k, fileData) in mediaMap {
//                let paramSrc = "post_image_\(k).jpeg"
//                 body.append(("; filename=\"\(paramSrc)\"\r\n"
//                 + "Content-Type: \"content-type header\"\r\n\r\n").data(using: String.Encoding.utf8)!)
//                //body.append(("<image data>").data(using: String.Encoding.utf8)!)
//                body.append(fileData)
//                body.append(("\r\n").data(using: String.Encoding.utf8)!)
//            }
//        }
//        body.append(("--\(boundary)\r\n").data(using: String.Encoding.utf8)!)
//        return body
//    }
    
}
