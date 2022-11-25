//
//  FeedEditorLocalMediaCollectionCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

struct InitFeedEditorLocalMediaCollectionCoordinatorModel {
    weak var datasource : PostEditorCellFactoryDatasource?
    var mediaManager : LocalMediaManager?
    weak var delegate: PostEditorCellFactoryDelegate?
    weak var postImageMapper : EditablePostMediaRepository?
}

public enum EditableMediaSection : Int, CaseIterable{
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
        return input.postImageMapper?.getNumberOfMediaItemsForPost(input.datasource?.getTargetPost(), section: EditableMediaSection(rawValue: section)!) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "MediaItemCollectionViewCell",
        for: indexPath) as! MediaItemCollectionViewCell
        cell.removeButton?.isHidden = false
        cell.editTransparentView?.isHidden = false
        cell.curvedCornerControl()
        cell.removeButton?.handleControlEvent(
            event: .touchUpInside,
            buttonActionBlock: {[weak self] in
                self?.input.delegate?.removeSelectedMedia(
                    index: indexPath.item,
                    mediaSection: EditableMediaSection(rawValue: indexPath.section)!
                )
        })
        input.postImageMapper?.loadImage(indexpath: indexPath, imageView: cell.mediaCoverImageView)
        cell.mediaCoverImageView?.curvedCornerControl()
        return cell
    }
}

extension FeedEditorLocalMediaCollectionCoordinator : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let mediaCount = input.postImageMapper?.getMediaCount(input.datasource?.getTargetPost())
        if mediaCount == 0 {
            return CGSize(width: 0, height: 0)
        }
        if mediaCount == 1{
            return CGSize(width: UIScreen.main.bounds.width - ( 2 * (16 + 12)), height: 273 - 16 - 16)
        }
        if mediaCount == 2{
            return CGSize(width: 120, height: 90)
        }
        return CGSize(width: 83, height: 57)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var edgeInset = UIEdgeInsets()
        if section > 0{
            edgeInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
        return edgeInset
    }
}
