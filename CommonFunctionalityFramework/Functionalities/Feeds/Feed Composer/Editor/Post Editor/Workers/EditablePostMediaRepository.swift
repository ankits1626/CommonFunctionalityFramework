//
//  EditablePostMediaMapper.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 27/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

struct EditablePostMediaMapperInitModel {
    weak var datasource : PostEditorCellFactoryDatasource?
    weak var localMediaManager : LocalMediaManager?
    weak var mediaFetcher: CFFMediaCoordinatorProtocol?
    weak var themeManager: CFFThemeManagerProtocol?
}

class EditablePostMediaRepository {
    private var input : EditablePostMediaMapperInitModel
    
    init(input : EditablePostMediaMapperInitModel) {
        self.input = input
    }
    
    func shouldDisplayMediaSection(_ post : EditablePostProtocol?) -> Bool {
        return getMediaCount(post) > 0
    }
    
    func getMediaCount(_ post : EditablePostProtocol?) -> Int {
        var totalMedia = 0
        totalMedia = totalMedia + (post?.remoteAttachedMedia?.count ?? 0)
        totalMedia = totalMedia + (post?.selectedMediaItems?.count ?? 0)
        return totalMedia
    }
    
    func getNumberOfMediaItemsForPost(_ post : EditablePostProtocol?, section : EditableMediaSection) -> Int {
        switch section {
        case .Remote:
            return post?.remoteAttachedMedia?.count ?? 0
        case .Local:
            return post?.selectedMediaItems?.count ?? 0
        }
    }
    
    func loadImage(indexpath : IndexPath, imageView: UIImageView?){
        switch EditableMediaSection(rawValue: indexpath.section)! {
        case .Remote:
            loadRemoteImage(index: indexpath.item, imageView: imageView)
        case .Local:
            loadLocalImage(index: indexpath.item, imageView: imageView)
        }
    }
    
    private func loadLocalImage(index : Int, imageView: UIImageView?){
        if let mediaItem = input.datasource?.getTargetPost()?.selectedMediaItems?[index]{
            if let croppedImage = mediaItem.croppedImage{
                imageView?.image = croppedImage
                imageView?.contentMode = .scaleAspectFit
            }else if let asset = mediaItem.asset{
                input.localMediaManager?.fetchImageForAsset(asset: asset, size: (imageView?.bounds.size)!, completion: { (str, fetchedImage) in
                    imageView?.image = fetchedImage
                })
            }
        }
    }
    
    private func loadRemoteImage(index : Int, imageView: UIImageView?){
        if let mediaItemUrl = input.datasource?.getTargetPost()?.remoteAttachedMedia?[index].getCoverImageUrl(){
            input.mediaFetcher?.fetchImageAndLoad(imageView, imageEndPoint: mediaItemUrl)
        }
    }

}

extension EditablePostMediaRepository{
    func getMediaListForPreview(_ post : EditablePostProtocol?) -> [MediaItemProtocol]? {
        var mediaItems = [MediaItemProtocol]()
        if let remoteItems = post?.remoteAttachedMedia{
            mediaItems = remoteItems
        }
        
        if let unwrappedLocalMediaUrls = post?.postableLocalMediaUrls{
            for localMediaUrl in unwrappedLocalMediaUrls {
                mediaItems.append(PreviewableLocalMediaItem(localMediaUrl))
            }
        }
        
        return mediaItems.isEmpty ? nil : mediaItems
    }
}
