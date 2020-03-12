//
//  FeedEditorLocalMediaCollectionCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

struct InitFeedEditorLocalMediaCollectionCoordinatorModel {
    let datasource : PostEditorCellFactoryDatasource
    var mediaManager : LocalMediaManager?
    var delegate: PostEditorCellFactoryDelegate
}

class FeedEditorLocalMediaCollectionCoordinator : NSObject {
    let input : InitFeedEditorLocalMediaCollectionCoordinatorModel
    var targetCollectionView: UICollectionView?
    
    init(_ input : InitFeedEditorLocalMediaCollectionCoordinatorModel) {
        self.input = input
    }
    
    func loadCollectionView(targetCollectionView : UICollectionView?) {
        self.targetCollectionView = targetCollectionView
        targetCollectionView?.register(
            UINib(nibName: "MediaItemCollectionViewCell", bundle: Bundle(for: MediaItemCollectionViewCell.self)),
            forCellWithReuseIdentifier: "MediaItemCollectionViewCell"
        )
        targetCollectionView?.dataSource = self
        targetCollectionView?.delegate = self
        targetCollectionView?.reloadData()
    }
    
    func removedLocalMedia(index : Int) {
        targetCollectionView?.reloadData()
        //targetCollectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
}

extension FeedEditorLocalMediaCollectionCoordinator : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return input.datasource.getTargetPost()?.selectedMediaItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "MediaItemCollectionViewCell",
        for: indexPath) as! MediaItemCollectionViewCell
        cell.removeButton?.isHidden = false
        cell.removeButton?.handleControlEvent(
            event: .touchUpInside,
            buttonActionBlock: {
                self.input.delegate.removeSelectedMedia(index: indexPath.item)
        })
        if let asset = input.datasource.getTargetPost()?.selectedMediaItems?[indexPath.row].asset{
            input.mediaManager?.fetchImageForAsset(asset: asset, size: (cell.mediaCoverImageView?.bounds.size)!, completion: { (_, fetchedImage) in
                cell.mediaCoverImageView?.image = fetchedImage
            })
        }
        cell.mediaCoverImageView?.curvedCornerControl()
        return cell
    }
}

extension FeedEditorLocalMediaCollectionCoordinator : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let selectedMediaItem = input.datasource.getTargetPost()?.selectedMediaItems
        
        if selectedMediaItem!.count == 2{
            return CGSize(width: 120, height: 90)
        }else{
            return CGSize(width: 83, height: 57)
        }
    }
}
