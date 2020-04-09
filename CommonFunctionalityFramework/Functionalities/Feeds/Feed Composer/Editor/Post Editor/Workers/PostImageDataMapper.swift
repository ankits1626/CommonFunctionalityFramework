//
//  PostImageDataMapper.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import Photos

class PostImageDataMapperError {
    static let MediaItemNotAvailable = NSError(
        domain: "com.rewardz.PostImageDataMapperError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unable to find asset for attached media item"]
    )
    
    static let ErrorFetchingImageFromLibrary = NSError(
        domain: "com.rewardz.PostImageDataMapperError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unable to find asset error from library"]
    )
}

class PostImageDataMapper {
    private weak var localMediaManager : LocalMediaManager?
    private var imageMap : [Int : Data] = [Int : Data]()
    private let group = DispatchGroup()
    init(_ localMediaManager : LocalMediaManager? ) {
        self.localMediaManager = localMediaManager
    }
    
    func prepareMediaMapForPost(_ post : EditablePostProtocol, completion :  @escaping (([Int : Data]?) -> Void)) throws {
        if let unwrappedMediaItems  = post.selectedMediaItems{
            //var currentlyProcessedImage = 0
            for (index, anItem) in unwrappedMediaItems.enumerated(){
                if let asset = anItem.asset{
                    group.enter()
                    PHImageManager.default().requestImage(
                        for: asset,
                        targetSize: PHImageManagerMaximumSize,
                        contentMode: PHImageContentMode.aspectFill,
                        options: nil) {[weak self] (image, nil) in
                            if let unwrappedImage = image,
                                let imageData = unwrappedImage.jpegData(compressionQuality: 1.0){
                                
                                self?.imageMap[index] = imageData
                            }
                            self?.group.leave()
                    }
                    //                    PHCachingImageManager().requestImageData(for:asset, options: nil) { (data, _, _, _) in
                    //                        if let unwrappedData = data{
                    //                            self.imageMap[index] = unwrappedData
                    //                        }else{
                    //                        }
                    //                        self.group.leave()
                    //                    }
                }else{
                    throw PostImageDataMapperError.MediaItemNotAvailable
                }
            }
            group.notify(queue: .main) {
                completion(self.imageMap)
            }
        }else{
            completion(nil)
        }
    }
    
    
    
    func prepareMediaUrlMapForPost(_ post : EditablePostProtocol, completion :  @escaping ((_ images : [URL]?, _ error : Error?) -> Void))  {
        if let unwrappedMediaItems  = post.selectedMediaItems{
            //var currentlyProcessedImage = 0
            var images = [UIImage]()
            var selectedAssets = [String]()
            unwrappedMediaItems.forEach { (anItem) in
                selectedAssets.append(anItem.identifier)
            }
            let photoAsset = PHAsset.fetchAssets(withLocalIdentifiers: selectedAssets, options: nil)
            let contentMode: PHImageContentMode = PHImageContentMode.aspectFit
            photoAsset.enumerateObjects ({ (object, index, stop) in
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.deliveryMode = .highQualityFormat
                PHImageManager.default().requestImage(for: object as PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: contentMode, options: options) {
                    image, info in
                    images.append(image!)
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
            completion(imageURLs, error)
        }else{
            completion(nil, nil)
        }
        
    }
    
    fileprivate func saveImageToDocumentsDirectory(_ sourceImage : UIImage) -> (imageURL:URL?, error:Error?){
        let directoryPath =  NSHomeDirectory().appending("/Documents/postImages/")
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
            try sourceImage.jpegData(compressionQuality: 1.0)?.write(to: url, options: .atomic)
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
