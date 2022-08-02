//
//  FeedsMediaCollectionCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents

struct InitFeedsMediaCollectionCoordinatorModel {
    let feedsDatasource : FeedsDatasource
    let feedItemIndex : Int
    let mediaFetcher : CFFMediaCoordinatorProtocol
    let delegate : FeedsDelegate?
}

class FeedsMediaCollectionCoordinator : NSObject {
    let input : InitFeedsMediaCollectionCoordinatorModel
    var mediaCollectionView : UICollectionView?
    var currentPage : Int = 0
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

extension FeedsMediaCollectionCoordinator : UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return input.feedsDatasource.getFeedItem(input.feedItemIndex).getMediaList()?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        mediaCollectionView = collectionView
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "MediaItemCollectionViewCell",
        for: indexPath) as! MediaItemCollectionViewCell
        let mediaItemUrl = input.feedsDatasource.getFeedItem(input.feedItemIndex).getMediaList()?[indexPath.row].getCoverImageUrl()
        input.mediaFetcher.fetchImageAndLoad(cell.mediaCoverImageView, imageEndPoint: mediaItemUrl ?? "")
//        cell.mediaCoverImageView?.clipsToBounds = true
//        cell.mediaCoverImageView?.layer.cornerRadius = 12
//        cell.mediaCoverImageView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cell.pageControl?.numberOfPages = input.feedsDatasource.getFeedItem(input.feedItemIndex).getMediaList()?.count ?? 0
        
        cell.pageControl?.currentPage = indexPath.row
        cell.pageControl.currentPageIndicatorTintColor = UIColor.getControlColor()
        
        if let mediaType = input.feedsDatasource.getFeedItem(input.feedItemIndex).getMediaList()?[indexPath.row].getMediaType(),
        mediaType == .Video{
             cell.playButton?.isHidden = false
        }else{
            cell.playButton?.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.input.delegate?.showMediaBrowser(
            feedIdentifier: self.input.feedsDatasource.getFeedItem(self.input.feedItemIndex).feedIdentifier,
            scrollToItemIndex: indexPath.item
        )
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard let pageWidth = self.mediaCollectionView?.frame.size.width else {
            return print("pageWidth not found") }
        currentPage = Int((self.mediaCollectionView?.contentOffset.x)! / pageWidth)
        print(Int((self.mediaCollectionView?.contentOffset.x)! / pageWidth))
    }
}

extension FeedsMediaCollectionCoordinator : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let feedItem = input.feedsDatasource.getFeedItem(input.feedItemIndex)
        if feedItem.hasOnlyMedia(){
            return CGSize(width: collectionView.frame.width, height: 90)
        }else{
            switch feedItem.getMediaCountState() {
            case .None:
                fallthrough
            case .OneMediaItemPresent(_):
                return CGSize.zero
            case .TwoMediaItemPresent:
                return CGSize(width: collectionView.frame.width, height: 176)
            case .MoreThanTwoMediItemPresent:
                return CGSize(width: collectionView.frame.width, height: 176)
            }
        }
    }
}
