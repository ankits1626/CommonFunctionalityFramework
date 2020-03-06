//
//  FeedsMediaCollectionCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

struct InitFeedsMediaCollectionCoordinatorModel {
    let feedsDatasource : FeedsDatasource
    let feedItemIndex : Int
    let mediaFetcher : CFFMediaCoordinatorProtocol
}

class FeedsMediaCollectionCoordinator : NSObject {
    let input : InitFeedsMediaCollectionCoordinatorModel
    init(_ input : InitFeedsMediaCollectionCoordinatorModel) {
        self.input = input
    }
    
    func loadCollectionView(targetCollectionView : UICollectionView?) {
        targetCollectionView?.register(
            UINib(nibName: "MediaItemCollectionViewCell", bundle: Bundle(for: MediaItemCollectionViewCell.self)),
            forCellWithReuseIdentifier: "MediaItemCollectionViewCell"
        )
        targetCollectionView?.dataSource = self
        targetCollectionView?.delegate = self
        targetCollectionView?.reloadData()
    }
}

extension FeedsMediaCollectionCoordinator : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return input.feedsDatasource.getFeedItem(input.feedItemIndex).getMediaList()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "MediaItemCollectionViewCell",
        for: indexPath) as! MediaItemCollectionViewCell
        let mediaItemUrl = input.feedsDatasource.getFeedItem(input.feedItemIndex).getMediaList()?[indexPath.row].getCoverImageUrl()
        input.mediaFetcher.fetchImageAndLoad(cell.mediaCoverImageView, imageEndPoint: mediaItemUrl ?? "")
        cell.mediaCoverImageView?.curvedCornerControl()
        return cell
    }
}

extension FeedsMediaCollectionCoordinator : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let feedItem = input.feedsDatasource.getFeedItem(input.feedItemIndex)
        switch feedItem.getMediaCountState() {
        case .None:
            fallthrough
        case .OneMediaItemPresent(_):
            return CGSize.zero
        case .TwoMediaItemPresent:
            return CGSize(width: 120, height: 90)
        case .MoreThanTwoMediItemPresent:
            return CGSize(width: 83, height: 57)
        }
    }
}
