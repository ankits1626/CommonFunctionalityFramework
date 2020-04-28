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
    var postImageMapper : EditablePostMediaRepository
}

enum EditableMediaSection : Int, CaseIterable{
    case Remote = 0
    case Local
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
    }
}

extension FeedEditorLocalMediaCollectionCoordinator : UICollectionViewDataSource, UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return EditableMediaSection.allCases.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return input.postImageMapper.getNumberOfMediaItemsForPost(input.datasource.getTargetPost(), section: EditableMediaSection(rawValue: section)!)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "MediaItemCollectionViewCell",
        for: indexPath) as! MediaItemCollectionViewCell
        cell.removeButton?.isHidden = false
        cell.removeButton?.handleControlEvent(
            event: .touchUpInside,
            buttonActionBlock: {
                self.input.delegate.removeSelectedMedia(
                    index: indexPath.item,
                    mediaSection: EditableMediaSection(rawValue: indexPath.section)!
                )
        })
        input.postImageMapper.loadImage(indexpath: indexPath, imageView: cell.mediaCoverImageView)
        cell.mediaCoverImageView?.curvedCornerControl()
        return cell
    }
}

extension FeedEditorLocalMediaCollectionCoordinator : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let mediaCount = input.postImageMapper.getMediaCount(input.datasource.getTargetPost())
        if mediaCount == 0 {
            return CGSize(width: 0, height: 0)
        }
        if mediaCount == 1{
            return CGSize(width: UIScreen.main.bounds.width, height: 205)
        }
        if mediaCount == 2{
            return CGSize(width: 120, height: 90)
        }
        return CGSize(width: 83, height: 57)
    }
}
