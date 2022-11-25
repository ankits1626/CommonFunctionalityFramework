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
import Photos

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
    
    func clearDataManager(){
        self.attachedImages = []
        self.attachmentDocuments = []
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
    
    func getAllAttachedDocumentUrl() -> [URL]?{
        var urls = [URL]()
        for doc in attachmentDocuments {
            if let c = doc.getFileUrl(){
                urls.append(c)
            }
    
        }
        return urls.isEmpty ? nil : urls
    }
    
    func getAllAttachedImageUrl() -> [URL]?{
        
        var images = [UIImage]()
        var selectedAssets = [String]()
        for anImage in attachedImages{
            if let croppedImage = anImage.croppedImage{
                images.append(croppedImage)
            }else{
                selectedAssets.append(anImage.identifier)
            }
        }
        let photoAsset = PHAsset.fetchAssets(withLocalIdentifiers: selectedAssets, options: nil)
        let contentMode: PHImageContentMode = PHImageContentMode.aspectFit
        photoAsset.enumerateObjects ({ (object, index, stop) in
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.deliveryMode = .highQualityFormat
            PHImageManager.default().requestImage(for: object as PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: contentMode, options: options) {
                image, info in
                if let unwrapped = image {
                    images.append(unwrapped)
                }else{
                    print("Issue on image")
                }
                
            }
        })
        var imageURLs = [URL]()
        var error : Error?
        
        for anImage in images{
            let saveImageResult = self.saveImageToDocumentsDirectory(anImage)
            if let unwrappedURL = saveImageResult.imageURL{
                imageURLs.append(unwrappedURL)
            }
            if let unwrappedError = saveImageResult.error{
                error = unwrappedError
            }
        }
        return imageURLs.isEmpty && error == nil ? nil : imageURLs
    }
    
    fileprivate func saveImageToDocumentsDirectory(_ sourceImage : UIImage) -> (imageURL:URL?, error:Error?){
        let directoryPath =  NSHomeDirectory().appending("/Documents/feedbackImages/")
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        let filename = String(format: "%@.jpg",randomString(length: 10))
        let filepath = directoryPath.appending(filename)
        let url = NSURL.fileURL(withPath: filepath)
        do {
            try sourceImage.jpegData(compressionQuality: 0.6)?.write(to: url, options: .atomic)
            return (url, nil)
            
        } catch {
            print(error)
            print("file cant not be save at path \(filepath), with error : \(error)");
            return (nil , error)
        }
    }
    
    private func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}

